										-- Triggers en solicitud

-- Apenas se inserte un nuevo funcionario, verificará si este es de tipo 'Administrador' en la tabla Usuario
DROP TRIGGER IF EXISTS verificar_funcionario_administrador_insert;
DELIMITER //

	CREATE TRIGGER verificar_funcionario_administrador_insert AFTER INSERT ON solicitud
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
	END;

// DELIMITER ;


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
	END;
// DELIMITER ;

-- TRIGGERS PARA CAMBIAR EL MONTO DEL PAGO DE DE UN DOCUMENTO 'TRAMITADO'

DROP trigger IF EXISTS INSERT_MONTO_SDOC_SOLICITADO;
	
    delimiter &&
	CREATE TRIGGER INSERT_MONTO_SDOC_SOLICITADO  before INSERT ON pago
	FOR EACH ROW 
	BEGIN
	declare id INT;
	declare idTram INT;
    set id = NEW.idSolicitud;
    
	SET new.MONTO=(SELECT costo FROM tramite join solicitud using(idtramite) where idSolicitud = id);
    
	END 
	&& DELIMITER ; 
    
    
DROP TRIGGER IF EXISTS UPDATE_MONTO_SDOC_SOLICITADO;
	DELIMITER &&
	CREATE TRIGGER UPDATE_MONTO_SDOC_SOLICITADO BEFORE UPDATE ON pago
		FOR EACH ROW 
	BEGIN
		declare id INT;
		SET id=NEW.idSolicitud; 
	
		SET new.MONTO=(SELECT costo FROM tramite join solicitud using(idtramite)where idSolicitud = id);
	END 
	&& DELIMITER ; 


-- TRIGGERS PARA QUE CUANDO SE INSERTE EL DOCUMENTO SOLICITADO CAMBIE EL ESTADO DE LA SOLICITUD.

DROP TRIGGER IF EXISTS insert_doc_solicitado;
	DELIMITER $$
		CREATE TRIGGER insert_doc_solicitado BEFORE INSERT on documento
		FOR EACH ROW
		BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
		END
	$$ DELIMITER ; 

-- 	Lo mismo pero para un UPDATE
DROP TRIGGER IF EXISTS update_doc_solicitado;
	DELIMITER $$
		CREATE TRIGGER update_doc_solicitado BEFORE UPDATE on documento
		FOR EACH ROW
		BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF NEW.tipoDocumento = 'Solicitado' THEN
			UPDATE solicitud SET estado = 'completado' WHERE idSolicitud = id;
		END IF;
		END
	$$ DELIMITER ; 

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
	END
	// DELIMITER ; 

