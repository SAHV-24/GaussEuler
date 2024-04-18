-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									TRIGGERS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- TRIGGER QUE CUANDO SE INGRESE UN COMENTARIO SE CAMBIE EL ESTADO A 'En proceso'
DROP TRIGGER IF EXISTS Comentario_en_proceso;
DELIMITER || 
CREATE TRIGGER Comentario_en_proceso BEFORE INSERT ON comentario
FOR EACH ROW

BEGIN
 
	IF new.idSolicitud NOT IN (SELECT idSolicitud FROM comentario) 
    AND getEstadoSolicitud(NEW.idSolicitud) = 'pendiente' THEN
		UPDATE solicitud SET estado = 'en proceso' WHERE idSolicitud=NEW.idSolicitud;
	END IF;
    
    IF new.IdUsuario NOT IN (
		SELECT idUsuario FROM solicitud where idSolicitud = NEW.idSolicitud
        UNION 
        SELECT idFuncionario FROM solicitud WHERE idSolicitud = NEW.idSolicitud    
    ) THEN
    
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Verificar el Usuario, este no pertenece a la solicitud';
    
    end if;
    
END
|| DELIMITER ; 

DROP TRIGGER IF EXISTS verificarPagos;

DELIMITER //
CREATE TRIGGER verificarPagos BEFORE INSERT ON pago
FOR EACH ROW 
BEGIN
	IF getEstadoSolicitud(new.idSolicitud) != 'en proceso' THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
	END IF;
END
// DELIMITER ;

-- Triggers en solicitud

-- TRIGGERS QUE HACE QUE EXISTA LA RELACIÓN 1 A 1 EN LA TABLA USUARIO Y PAGO


DROP TRIGGER IF EXISTS relacionUnoAUnoPagoINS;

DELIMITER // 
CREATE TRIGGER relacionUnoAUnoPagoINS BEFORE INSERT ON pago
FOR EACH ROW
BEGIN
	IF NEW.idSolicitud IN (SELECT idSolicitud FROM pago) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar un nuevo pago puesto que ya existe un Pago Activo para esta Solicitud';
	END IF;
END
// DELIMITER ; 

-- Trigger que hace que no se inserte un nombre diferente al de una cédula, ejemplo: Si inserto una cédula "1110289035" no puedo tener dos registros con 
-- Alguien que se llame Sergio y luego que se llame Juan David, tiene que tener consistencia esa identificación!

drop trigger if exists verificar_ident_Usuario;
DELIMITER //
CREATE TRIGGER verificar_ident_Usuario BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
	DECLARE elNombre VARCHAR(50);
    DECLARE elApellido VARCHAR(50);
    
    IF NEW.identificacion IN (SELECT DISTINCT(identificacion) from usuario) THEN 
		SELECT DISTINCT(nombre) INTO elNombre FROM usuario WHERE identificacion=NEW.identificacion;
		SELECT DISTINCT(apellido) INTO elApellido FROM usuario WHERE identificacion=NEW.identificacion;
        IF elNombre != NEW.nombre OR elApellido != NEW.apellido AND elApellido IS NOT NULL AND elNombre IS NOT NULL THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR, EL USUARIO DEBE DE TENER EL MISMO NOMBRE Y APELLIDO PARA ESTA IDENTIFICACIÓN';
		END IF;
	END IF;
	END
// DELIMITER ; 

-- Apenas se inserte un nuevo funcionario, verificará si este es de tipo 'Administrador' en la tabla Usuario
DROP TRIGGER IF EXISTS verificar_funcionario_administrador_insert;

DELIMITER //
CREATE TRIGGER verificar_funcionario_administrador_insert BEFORE INSERT ON solicitud
FOR EACH ROW
BEGIN
	DECLARE tipoUsuario VARCHAR(50);
		
	SELECT tipo INTO tipoUsuario
	FROM usuario
	WHERE idUsuario = NEW.idFuncionario;
		
	IF tipoUsuario != 'Administrativo' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El usuario asignado como funcionario no es un Administrativo';
	END IF;
END //
 
DELIMITER ;


-- Apenas se Actualice un nuevo funcionario, verificará si este es de tipo 'Administrador' en la tabla Usuario
DROP TRIGGER IF EXISTS verificar_funcionario_administrador_UPDATE;

DELIMITER //
CREATE TRIGGER verificar_funcionario_administrador_update BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN
	DECLARE tipoUsuario VARCHAR(50);
		
	SELECT tipo INTO tipoUsuario
	FROM usuario
	WHERE idUsuario = NEW.idFuncionario;
		
	IF tipoUsuario != 'Administrativo' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El usuario asignado como funcionario no es un Administrativo';
	END IF;
END //
DELIMITER ;

-- TRIGGERS PARA CAMBIAR EL MONTO DEL PAGO DE DE UN DOCUMENTO 'TRAMITADO'


DROP trigger IF EXISTS INSERT_MONTO_SDOC_SOLICITADO;
	
DELIMITER //
CREATE TRIGGER INSERT_MONTO_SDOC_SOLICITADO BEFORE INSERT ON pago
FOR EACH ROW 
BEGIN
	DECLARE id INT;
    SET id = NEW.idSolicitud;
    
    IF id IN(SELECT idSolicitud FROM solicitud) AND NEW.monto IS NULL THEN 
		SET NEW.monto=(SELECT costo FROM tramite JOIN solicitud USING(idTramite) WHERE idSolicitud=id);
	END IF;
    IF id NOT IN (SELECT idSolicitud FROM solicitud) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe';
    END IF;
    
END //
DELIMITER ;

-- TRIGGERS PARA QUE CUANDO SE INSERTE EL DOCUMENTO SOLICITADO CAMBIE EL ESTADO DE LA SOLICITUD.

DROP TRIGGER IF EXISTS insert_doc_solicitado;
DELIMITER //
CREATE TRIGGER insert_doc_solicitado BEFORE INSERT on documento
FOR EACH ROW
	BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
	END //
DELIMITER ; 

-- 	Lo mismo pero para un UPDATE
DROP TRIGGER IF EXISTS update_doc_solicitado;
DELIMITER 
CREATE TRIGGER update_doc_solicitado BEFORE UPDATE on documento
FOR EACH ROW
	BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
	END //
DELIMITER ; 

-- TRIGGER PARA VERIFICAR LA FECHA DE CANCELACIÓN
DROP TRIGGER IF EXISTS  verificarFechaDeCancelacion;

DELIMITER //
CREATE TRIGGER verificarFechaDeCancelacion BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
	IF NEW.fechaDeCancelacion IS NOT NULL AND NEW.fechaDeCancelacion NOT BETWEEN NEW.fechaInicio AND NEW.fechaLimite THEN
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'NO ES POSIBLE INSERTAR ESTA FECHA DE CANCELACIÓN PORQUE HAY UN ERROR CON LAS FECHAS';
    END IF;
    
END
// DELIMITER ;

-- TRIGGER que NO permite que se agreguen más comentarios luego de que se cerró la solicitud.

DROP TRIGGER IF EXISTS estadoSolicitud_en_comentario;

DELIMITER //
CREATE TRIGGER estadoSolicitud_en_comentario BEFORE INSERT ON comentario
FOR EACH ROW
BEGIN
	DECLARE laId INT;
	SET laId = New.idSolicitud;
	IF getEstadoSolicitud(laId)='cerrado' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='ERROR, LA SOLICITUD ESTÁ CERRADA';
	END IF;
END // 
DELIMITER ;

-- TRIGGER QUE VERIFICA SI YA EXISTE UN DOCUMENTO DE RECIBO DE PAGO ACTIVO.
DROP TRIGGER IF EXISTS verificar_reciboDePago;
DELIMITER //

CREATE TRIGGER verificar_reciboDePago BEFORE INSERT ON documento
FOR EACH ROW

BEGIN
	DECLARE laID INT;
    DECLARE cant INT;
	SET laId = NEW.idSOLICITUD;
                
    SET cant = (
SELECT COUNT(*) FROM documento WHERE idSolicitud= laID and ESTADOdocumento='Activo' and tipoDocumento='ReciboDePago');

		IF new.tipoDocumento ='reciboDePago' AND cant=1 THEN

				SIGNAL SQLSTATE '45000' 
				SET MESSAGE_TEXT='ERROR, YA EXISTE UN RECIBO DE PAGO ACTIVO, DEBE DESACTIVARLO ANTES DE INSERTAR UN RECIBO DE PAGO';
		END IF;
END //

DELIMITER ;

-- TRIGGER QUE VERIFICA SI EL idUsuario y el idFuncionario son IGUALES.

DROP TRIGGER IF EXISTS verificarUsuarioYFuncionario;

DELIMITER // 
CREATE TRIGGER verificarUsuarioYFuncionario BEFORE INSERT ON solicitud
FOR EACH ROW
BEGIN
	IF new.idUsuario=new.idFuncionario THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: NO PUEDE INGRESARSE UN MISMO USUARIO Y FUNCIONARIO';
	END IF;
END;
// DELIMITER ;  

-- AUDITORIA CANCELACIONES: 

-- Mandar a auditoria las solicitudes canceladas por el usuario
DROP TRIGGER IF EXISTS registrar_cancelacionxUsuario;

DELIMITER //
CREATE TRIGGER registrar_cancelacionxUsuario AFTER UPDATE ON solicitud
FOR EACH ROW
BEGIN

	DECLARE id INT;
	SET id = NEW.idSolicitud;
   
	IF getEstadoSolicitud(id)='cancelado' AND verificarFecha(id)=0 THEN
		
        INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (id, "USUARIO", NOW());
        
    END IF;
    
    IF getEstadoSolicitud(id)='cancelado' AND  verificarFecha(id)=1 THEN
		
        INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (id, "SISTEMA", NOW());
        
    END IF;    
    
END // 
DELIMITER ;


DROP TRIGGER IF EXISTS update_estado_limite_fecha;

DELIMITER //
CREATE TRIGGER update_estado_limite_fecha BEFORE UPDATE ON pago
FOR EACH ROW

BEGIN

	DECLARE id INT;
	SET id = OLD.idSolicitud;
    
	IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='en proceso' THEN
		UPDATE solicitud SET estado='cancelado' WHERE idSolicitud = id;
        -- INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (id, "SISTEMA", NOW());
        
    END IF;
END // 
DELIMITER ; 


-- Trigger para reforzar relación 1:1 entre cancelacion y solicitud

DROP TRIGGER IF EXISTS one2oneSolicitudxCancelacion;

DELIMITER //
CREATE TRIGGER one2oneSolicitudxCancelacion BEFORE INSERT ON cancelacion
FOR EACH ROW

BEGIN
	DECLARE id INT;
    SET id = (NEW.idSolicitud);
    
    IF id IN (SELECT idSolicitud FROM cancelacion) THEN
    
		SIGNAL 	
			SQLSTATE '45000' 
            SET MESSAGE_TEXT = "Esta solicitud ya fue cancelada";
    
    END IF;   
    
    
END //
DELIMITER ;