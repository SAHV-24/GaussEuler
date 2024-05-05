-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									TRIGGERS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- TRIGGER QUE CUANDO SE INGRESE UN COMENTARIO SE CAMBIE EL ESTADO A 'En proceso' y Verifica que el usuario sea de esta solicitud
DROP TRIGGER IF EXISTS Comentario_en_proceso;
DELIMITER || 
CREATE TRIGGER Comentario_en_proceso BEFORE INSERT ON comentario
FOR EACH ROW

BEGIN
 
	IF new.idSolicitud NOT IN (SELECT idSolicitud FROM comentario) 
    AND getEstadoSolicitud(NEW.idSolicitud) = 'pendiente' THEN
		UPDATE solicitud SET estado = 'enproceso' WHERE idSolicitud=NEW.idSolicitud;
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
CREATE TRIGGER verificarPagos after INSERT ON pago
FOR EACH ROW 
BEGIN
	IF getEstadoSolicitud(new.idSolicitud) != 'enproceso' THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
	END IF;
    IF NEW.fechaInicio<(SELECT DATE(fechaInicio) FROM solicitud WHERE idSolicitud = new.idSolicitud) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha De inicio de la solicitud no coincide con la del pago';
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
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un pago para esta solicitud, Actualizalo ó  Elimina y Crea un nuevo registro!';
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

-- TRIGGERS PARA PONER EL MISMO MONTO DEL TRÁMITE


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

-- TRIGGER PARA QUE CUANDO SE INSERTE EL DOCUMENTO SOLICITADO CAMBIE EL ESTADO DE LA SOLICITUD.

DROP TRIGGER IF EXISTS insert_doc_solicitado;
DELIMITER //
CREATE TRIGGER insert_doc_solicitado BEFORE INSERT on documento
FOR EACH ROW
	BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' AND NEW.estadoDocumento = 'activo' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
	END //
DELIMITER ; 

-- 	Lo mismo pero para un UPDATE
DROP TRIGGER IF EXISTS update_doc_solicitado;
DELIMITER //
CREATE TRIGGER update_doc_solicitado BEFORE UPDATE on documento
FOR EACH ROW
	BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' AND NEW.estadoDocumento = 'activo' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
	END //
DELIMITER ; 

-- Si se elimina ese registro y el estado del documento es activo, se cambia el estado de la solicitud

DROP TRIGGER IF EXISTS delete_doc_solicitado;
DELIMITER //
CREATE TRIGGER delete_doc_solicitado BEFORE DELETE on documento
FOR EACH ROW
	BEGIN
		DECLARE Id INT;
		SET id = OLD.idSolicitud;

		IF OLD.tipoDocumento = 'Solicitado' and OLD.estadoDocumento = 'activo' THEN
			UPDATE solicitud SET estado = 'enproceso' WHERE idSolicitud = id;
		END IF;
	END //
DELIMITER ; 


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

-- Trigger para no dejar actualizar un comentario si la solicitud ya está cerrada.

DROP TRIGGER IF EXISTS UPDATEestadoSolicitud_en_comentario;

DELIMITER //
CREATE TRIGGER UPDATEestadoSolicitud_en_comentario AFTER UPDATE ON comentario
FOR EACH ROW
BEGIN
	DECLARE laId INT;
	SET laId = New.idSolicitud;
	IF getEstadoSolicitud(laId)='cerrado' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='ERROR, LA SOLICITUD ESTÁ CERRADA';
	END IF;
END // 
DELIMITER ;

-- TRIGGER QUE NO PERMITE ACTUALIZAR EL ESTADO DE UN PAGO SI NO EXISTE UN RECIBO DE PAGO ACTIVO

DROP TRIGGER IF EXISTS verificarRecibosActivosEnPagoUPDATE;

DELIMITER $$

CREATE TRIGGER verificarRecibosActivosEnPagoUPDATE BEFORE UPDATE on PAGO
FOR EACH ROW
BEGIN
	DECLARE recibosActivos INT;
    
    SELECT COUNT(*) INTO recibosActivos 
    FROM documento 
    WHERE idSolicitud = NEW.idSolicitud AND tipoDocumento = 'ReciboDePago' AND estadoDocumento ='activo';
    
    IF NEW.estadoDePago = 'Pagado' THEN
    
	IF recibosActivos != 1 THEN
			SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT= 'No existe ningún Recibo de Pago activo para esta solicitud!';
		END IF;
        
	END IF;
    
END

$$ DELIMITER ; 

-- TRIGGER QUE NO PERMITE INSERTAR UN PAGO REALIZADO SI NO EXISTE NINGÚN RECIBO DE PAGO ACTIVO 

DROP TRIGGER IF EXISTS verificarRecibosActivosEnPagoINSERT;

DELIMITER $$

CREATE TRIGGER verificarRecibosActivosEnPagoINSERT BEFORE INSERT on PAGO
FOR EACH ROW
BEGIN
	DECLARE recibosActivos INT;
    
    SELECT COUNT(*) INTO recibosActivos 
    FROM documento 
    WHERE idSolicitud = NEW.idSolicitud AND tipoDocumento = 'ReciboDePago' AND estadoDocumento ='activo';
    
    IF NEW.estadoDePago = 'Pagado' THEN
    
	IF recibosActivos != 1 THEN
			SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT= 'No existe ningún Recibo de Pago activo para esta solicitud!';
		END IF;
        
	END IF;
    
END

$$ DELIMITER ; 

-- TRIGGER QUE VERIFICA SI YA EXISTE UN DOCUMENTO DE RECIBO DE PAGO ACTIVO.
DROP TRIGGER IF EXISTS verificar_reciboDePago;
DELIMITER //

CREATE TRIGGER verificar_reciboDePago BEFORE INSERT ON documento
FOR EACH ROW

BEGIN
	DECLARE laID INT;
    DECLARE cant INT;
	SET laId = NEW.idSOLICITUD;
                
    SET cant = (SELECT COUNT(*) FROM documento WHERE idSolicitud= laID and ESTADOdocumento='Activo' and tipoDocumento='ReciboDePago');

		IF cant>=1 AND new.tipoDocumento = 'ReciboDePago' AND new.estadoDocumento = 'activo' THEN

				SIGNAL SQLSTATE '45000' 
				SET MESSAGE_TEXT='ERROR, YA EXISTE UN RECIBO DE PAGO ACTIVO, DEBE DESACTIVARLO ANTES DE INSERTAR UN RECIBO DE PAGO';
		END IF;
END //

DELIMITER ;

-- TRIGGER QUE VERIFICA SI YA EXISTE UN DOCUMENTO DE RECIBO DE PAGO ACTIVO.
DROP TRIGGER IF EXISTS verificar_reciboDePagoUPD;
DELIMITER //

CREATE TRIGGER verificar_reciboDePagoUPD BEFORE UPDATE ON documento
FOR EACH ROW

BEGIN
	DECLARE laID INT;
    DECLARE cant INT;
	SET laId = NEW.idSOLICITUD;
                
    SET cant = (SELECT COUNT(*) FROM documento WHERE idSolicitud= laID and ESTADOdocumento='Activo' and tipoDocumento='ReciboDePago');

		IF cant>=1 AND new.tipoDocumento = 'ReciboDePago' AND new.estadoDocumento = 'activo' THEN

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
    
	IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='enproceso' THEN
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

DROP TRIGGER IF EXISTS cambioDeFechaEnSolicitud;

DELIMITER || 

CREATE TRIGGER cambioDeFechaEnSolicitud BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN

	DECLARE fechaInicioPago DATE;
    DECLARE contPagos INT;
    
    SELECT count(*) into contPagos FROM pago where idSolicitud = NEW.idSolicitud;
    
    IF contPagos = 1 THEN
		SELECT fechaInicio INTO fechaInicioPago  
        FROM pago WHERE idsolicitud=NEW.idSolicitud;
        
        IF DATE(NEW.fechaInicio) > fechaInicioPago THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las fechas de Pago y de la solicitud no coinciden, verificar!';
        END IF;
		
    END IF;

END;

|| DELIMITER ; 



DROP TRIGGER IF EXISTS checkEstadoEnProceso;
DELIMITER //
CREATE TRIGGER checkEstadoEnProceso BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN

	IF OLD.estado='pendiente' AND NEW.estado='completado' THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La solicitud no puede ser completada si no está en proceso!';
    END IF;    
		
 END;
// DELIMITER ;


DROP TRIGGER IF EXISTS UPDATEverificarFechaDeCancelacion;

DELIMITER //
CREATE TRIGGER UPDATEverificarFechaDeCancelacion BEFORE UPDATE ON PAGO
FOR EACH ROW
BEGIN

IF NEW.fechaDeCancelacion > NEW.fechaLimite OR
	NEW.fechaDeCancelacion < NEW.fechainicio THEN
    
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: La fecha de cancelación no coincide con las Fechas de Inicio o De Límite!';
END IF;

END;
// DELIMITER ; 



-- TRIGGER PARA VERIFICAR LA FECHA DE CANCELACIÓN
DROP TRIGGER IF EXISTS  verificarFechaDeCancelacion;

DELIMITER //
CREATE TRIGGER verificarFechaDeCancelacion BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
	IF NEW.fechaDeCancelacion IS NOT NULL AND NEW.fechaDeCancelacion NOT BETWEEN NEW.fechaInicio AND NEW.fechaLimite THEN
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'ERROR: La fecha de cancelación no coincide con las Fechas de Inicio o De Límite!';
    END IF;
    
END
// DELIMITER ;


DROP TRIGGER IF EXISTS verificarFechaLimiteUPDATE;

DELIMITER //

CREATE TRIGGER verificarFechaLimiteUPDATE BEFORE UPDATE ON pago
FOR EACH ROW

BEGIN

	IF NEW.fechaLimite > OLD.fechaDeCancelacion AND OLD.fechaDeCancelacion IS NOT NULL
    AND OLD.estadoDePago = 'Pagado' AND NEW.estadoDePAGO='Pagado'
	THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: El pago ya está cancelado, 
							no puede modificarse la fecha de Cancelación!';
	END IF;
    
    IF  NEW.fechaLimite < NEW.fechaDeCancelacion AND NEW.fechaDeCancelacion IS NOT NULL
    THEN
    
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Verifique las fechas de Límite y las fechas de Cancelación por favor!';
    
    END IF;       
END


// DELIMITER ; 

DROP TRIGGER IF EXISTS verificarFechaLimiteINSERT;

DELIMITER //

CREATE TRIGGER verificarFechaLimiteINSERT BEFORE INSERT ON pago
FOR EACH ROW

BEGIN
	IF NEW.fechaLimite < NEW.fechaDeCancelacion AND NEW.fechaDeCancelacion IS NOT NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha Límite no puede ser Menor 
													a la fecha De Cancelación!';
	END IF;       
END


// DELIMITER ; 


DROP TRIGGER IF EXISTS verificarEstadoPagoUPDATE;

DELIMITER $$

CREATE TRIGGER verificarEstadoPagoUPDATE AFTER UPDATE ON PAGO
FOR EACH ROW

BEGIN
    IF NEW.estadoDePago = 'Pagado' AND NEW.fechaDeCancelacion IS NULL THEN 
		SIGNAL sqlstate '45000' 
        SET MESSAGE_TEXT = 'Antes de cambiar el estado del pago, debe agregarse la FECHA DE CANCELACIÓN!';
	END IF;
END

$$ DELIMITER ; 



DROP TRIGGER IF EXISTS verificarEstadoPagoINSERT;

DELIMITER $$

CREATE TRIGGER verificarEstadoPagoINSERT BEFORE INSERT ON PAGO
FOR EACH ROW

BEGIN
    IF NEW.estadoDePago = 'Pagado' AND NEW.fechaDeCancelacion IS NULL THEN 
		SIGNAL sqlstate '45000' 
        SET MESSAGE_TEXT = 'Antes de agregar este registro, debe agregarse la FECHA DE CANCELACIÓN!';
	END IF;
END

$$ DELIMITER ; 



DROP TRIGGER IF EXISTS verificarComentarioAnteriorINSERT;
DELIMITER $$

CREATE TRIGGER verificarComentarioAnteriorINSERT BEFORE INSERT ON comentario
FOR EACH ROW
BEGIN
	DECLARE solicitudPasada INT;
    
    IF NEW.comentarioAnterior IS NOT NULL THEN
		SELECT idSolicitud INTO solicitudPasada 
        FROM comentario WHERE idComentario = NEW.comentarioAnterior;
        
        IF NEW.idSolicitud != solicitudPasada THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El comentario anterior no es de esta solicitud!';
        END IF;       
    END IF;
END

$$ DELIMITER ; 


DROP TRIGGER IF EXISTS verificarComentarioAnteriorUPDATE;
DELIMITER $$

CREATE TRIGGER verificarComentarioAnteriorUPDATE AFTER UPDATE ON comentario
FOR EACH ROW
BEGIN
	DECLARE solicitudPasada INT;
    
    IF NEW.comentarioAnterior IS NOT NULL THEN
		SELECT idSolicitud INTO solicitudPasada 
        FROM comentario WHERE idComentario = NEW.comentarioAnterior;
        
        IF NEW.idSolicitud != solicitudPasada THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: El comentario anterior no es de esta solicitud!';
        END IF;       
    END IF;
END

$$ DELIMITER ; 



DROP TRIGGER IF EXISTS relacionReflexivaComentario ;

DELIMITER // 

CREATE TRIGGER relacionReflexivaComentario BEFORE INSERT ON COMENTARIO
FOR EACH ROW

BEGIN
	DECLARE cantComentarioPrincipal INT;
    
    SELECT COUNT(*) INTO cantComentarioPrincipal
    FROM comentario WHERE idSolicitud= NEW.idSolicitud and comentarioAnterior IS NULL;
    
    IF cantComentarioPrincipal = 1 AND NEW.comentarioAnterior IS NULL THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Este comentario debe ser referenciado a otro puesto que ya existe el comentario de Origen';
	END IF;
END

// DELIMITER ; 

DROP TRIGGER IF EXISTS relacionReflexivaComentarioUPD ;

DELIMITER // 

CREATE TRIGGER relacionReflexivaComentarioUPD BEFORE UPDATE ON COMENTARIO
FOR EACH ROW

BEGIN
	DECLARE cantComentarioPrincipal INT;
    
    SELECT COUNT(*) INTO cantComentarioPrincipal
    FROM comentario 
    WHERE idSolicitud= NEW.idSolicitud 
    And comentarioAnterior IS NULL;
    
    IF cantComentarioPrincipal = 1 AND NEW.comentarioAnterior IS NULL THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Este comentario debe ser referenciado a otro puesto que ya existe el comentario de Origen';
	END IF;
END

// DELIMITER ; 



DROP TRIGGER IF EXISTS VerificarHoraComentario;

DELIMITER // 
CREATE TRIGGER VerificarHoraComentario BEFORE INSERT ON comentario
FOR EACH ROW

BEGIN
	DECLARE horaMaxima DATETIME;
    
    SELECT MAX(fechaYhora) INTO horaMaxima
    FROM comentario GROUP BY (new.idSolicitud);
    
    IF new.fechaYhora < horaMaxima THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: La hora de envío de este comentario no concuerda con la 
										del último comentario de la solicitud!';
    END IF;
    
END
// DELIMITER ; 




DROP TRIGGER IF EXISTS VerificarHoraComentarioUPD;

DELIMITER // 
CREATE TRIGGER VerificarHoraComentarioUPD BEFORE UPDATE ON comentario
FOR EACH ROW

BEGIN
	DECLARE horaMaxima DATETIME;
    
    SELECT MAX(fechaYhora) INTO horaMaxima
    FROM comentario GROUP BY (new.idSolicitud);
    
    IF new.fechaYhora < horaMaxima 
    THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: La hora de envío de este comentario no concuerda con la 
										del último comentario de la solicitud!';
    END IF;
    
END
// DELIMITER ; 


DROP TRIGGER IF EXISTS checkIntegrityOfCompleted;

DELIMITER &&
CREATE TRIGGER checkIntegrityOfCompleted BEFORE UPDATE ON solicitud 
FOR EACH ROW
BEGIN
	IF new.estado = 'cerrado' AND OLD.estado NOT IN ('cancelado','completado') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cerrar una solicitud si no está cancelada o completada';
	END IF;
END
&& DELIMITER ; 


DROP TRIGGER IF EXISTS checkRequestedDocIfHasAPaymentINS;

DELIMITER $$
CREATE TRIGGER checkRequestedDocIfHasAPaymentINS BEFORE INSERT ON documento
FOR EACH ROW
BEGIN

DECLARE elEstadoDePago ENUM('Pagado','Por Pagar');

IF new.iDSolicitud IN (SELECT idSolicitud FROM pago) THEN
	
    SELECT EstadoDePago INTO elEstadoDepago FROM pago where idSolicitud = NEW.idSolicitud;
    
    IF elEstadoDePago = 'Por Pagar' AND new.tipoDocumento = 'Solicitado' THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR, NO PUEDES INSERTAR EL DOCUMENTO SOLICITADO SI NO SE HA PAGADO';
    END IF;

END IF;
END;
$$ DELIMITER ; 


DROP TRIGGER IF EXISTS checkRequestedDocIfHasAPaymentUPD;

DELIMITER $$
CREATE TRIGGER checkRequestedDocIfHasAPaymentUPD BEFORE UPDATE ON documento
FOR EACH ROW
BEGIN

DECLARE elEstadoDePago ENUM('Pagado','Por Pagar');

IF new.iDSolicitud IN (SELECT idSolicitud FROM pago) THEN
	
    SELECT EstadoDePago INTO elEstadoDepago FROM pago where idSolicitud = NEW.idSolicitud;
    
    IF elEstadoDePago = 'Por Pagar' AND new.tipoDocumento = 'Solicitado' THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR, NO PUEDES INSERTAR EL DOCUMENTO SOLICITADO SI NO SE HA PAGADO';
    END IF;

END IF;
END;
$$ DELIMITER ; 

