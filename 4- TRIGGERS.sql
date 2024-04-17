-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									TRIGGERS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Triggers SOLICITUD

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



-- TRIGGERS PAGO

-- TRIGGER PARA CAMBIAR EL ESTADO DE LA SOLICITUD SI SE PASÓ DE LA FECHA LÍMITE.

DROP TRIGGER IF EXISTS update_estado_limite_fecha;

DELIMITER //
CREATE TRIGGER update_estado_limite_fecha BEFORE UPDATE on pago
FOR EACH ROW

BEGIN

	DECLARE id INT;
	SET id = OLD.idSolicitud;

	IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='en proceso' THEN
		UPDATE solicitud SET estado='cancelado' WHERE idSolicitud;
    END IF;
END // 
DELIMITER ; 


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


DROP TRIGGER IF EXISTS relacionUnoAUnoPagoUPD;

DELIMITER // 
CREATE TRIGGER relacionUnoAUnoPagoUPD BEFORE UPDATE ON pago
FOR EACH ROW
BEGIN
	IF NEW.idSolicitud IN (SELECT idSolicitud FROM pago) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede insertar un nuevo pago puesto que ya existe un Pago Activo para esta Solicitud';
	END IF;
END
// DELIMITER ; 

-- TRIGGERS PARA CAMBIAR EL MONTO DEL PAGO DE DE UN DOCUMENTO 'TRAMITADO'

DROP trigger IF EXISTS INSERT_MONTO_SDOC_SOLICITADO;
	
DELIMITER //
CREATE TRIGGER INSERT_MONTO_SDOC_SOLICITADO BEFORE INSERT ON pago
FOR EACH ROW 
BEGIN
	DECLARE id INT;
    SET id = NEW.idSolicitud;
    
    IF id IN(SELECT idSolicitud FROM solicitud) THEN 
		SET NEW.monto=(SELECT costo FROM tramite JOIN solicitud USING(idTramite) WHERE idSolicitud=id);
	else
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no existe';
    END IF;
    
END //
DELIMITER ;



-- Triggers para DOCUMENTO

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



-- TRIGGERS PARA COMENTARIO

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



-- TRIGGERS PARA USUARIO:

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


-- TRIGGERS PARA CANCELACIÓN:

DROP TRIGGER IF EXISTS relacionUnoAUnoCancelacionesINS;
DELIMITER //
CREATE TRIGGER relacionUnoAUnoCancelacionesINS BEFORE INSERT ON Cancelacion
FOR EACH ROW
BEGIN
	IF NEW.idSolicitud IN (SELECT DISTINCT(idSolicitud) FROM Cancelacion) THEN
			SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Ya existe esta misma solicitud que está cancelada,
            verifique la información';
END IF;
end
// DELIMITER ; 
SELECT * FROM USUARIO;

DROP TRIGGER IF EXISTS relacionUnoAUnoCancelacionesUPD;
DELIMITER //
CREATE TRIGGER relacionUnoAUnoCancelacionesUPD BEFORE UPDATE ON Cancelacion
FOR EACH ROW
BEGIN
	IF NEW.idSolicitud IN (SELECT DISTINCT(idSolicitud) FROM auditoriaCancelaciones) THEN
			SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Ya existe esta misma solicitud que está cancelada,
            verifique la información';
END IF;
end
// DELIMITER ; 

