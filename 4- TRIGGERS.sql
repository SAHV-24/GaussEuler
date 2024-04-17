-- Triggers en solicitud

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


-- Mandar a auditoria las solicitudes canceladas por el usuario
DROP TRIGGER IF EXISTS registrar_cancelacionxUsuario;

DELIMITER //
CREATE TRIGGER registrar_cancelacionxUsuario AFTER UPDATE ON solicitud
FOR EACH ROW
BEGIN

	DECLARE id INT;
	SET id = NEW.idSolicitud;
    
	IF getEstadoSolicitud(id)='cancelado' THEN
		
        INSERT INTO auditoria_cancelaciones (idSolicitud, tipo, fecha) VALUES (id, "USUARIO", NOW());
        
    END IF;
END // 
DELIMITER ;


-- TRIGGERS PARA CAMBIAR EL MONTO DEL PAGO DE DE UN DOCUMENTO 'TRAMITADO'

DROP trigger IF EXISTS INSERT_MONTO_SDOC_SOLICITADO;
	
DELIMITER //
CREATE TRIGGER INSERT_MONTO_SDOC_SOLICITADO  before INSERT ON pago
FOR EACH ROW 
BEGIN
	declare id INT;
    set id = NEW.idSolicitud;
    
	SET new.MONTO = (SELECT costo FROM tramite join solicitud using(idtramite) where idSolicitud = id);
    
END	//
DELIMITER ; 
    
    
DROP TRIGGER IF EXISTS UPDATE_MONTO_SDOC_SOLICITADO;
DELIMITER //
CREATE TRIGGER UPDATE_MONTO_SDOC_SOLICITADO BEFORE UPDATE ON pago
FOR EACH ROW 
	BEGIN
		declare id INT;
		SET id=NEW.idSolicitud; 
	
		SET new.MONTO=(SELECT costo FROM tramite join solicitud using(idtramite) where idSolicitud = id);
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

-- TRIGGER PARA CAMBIAR EL ESTADO DE LA SOLICITUD SI SE PASÓ DE LA FECHA LÍMITE.

DROP TRIGGER IF EXISTS update_estado_limite_fecha;

DELIMITER //
CREATE TRIGGER update_estado_limite_fecha BEFORE UPDATE ON pago
FOR EACH ROW

BEGIN

	DECLARE id INT;
	SET id = OLD.idSolicitud;
    
	IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='en proceso' THEN
		UPDATE solicitud SET estado='cancelado' WHERE idSolicitud = id;
        INSERT INTO auditoria_cancelaciones (idSolicitud, tipo, fecha) VALUES (id, "SISTEMA", NOW());
        
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
