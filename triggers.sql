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

	DROP trigger INSERT_MONTO_SDOC_SOLICITADO;
	delimiter &&
	CREATE TRIGGER INSERT_MONTO_SDOC_SOLICITADO  before INSERT ON pago
	FOR EACH ROW 
	BEGIN
	declare id INT;
	set id = NEW.idSolicitud;

		IF NEW.tipo = 'Tramitado' THEN
			SET new.MONTO=(SELECT costo FROM tramite join solicitud using(idtramite) where idSolicitud = id);
		END IF;
	END 
	&& DELIMITER ; 
    
    
    
    
	DELIMITER &&
	CREATE TRIGGER UPDATE_MONTO_SDOC_SOLICITADO BEFORE UPDATE ON pago
		FOR EACH ROW 
	BEGIN
	declare id INT;
		SELECT NEW.idSolicitud INTO id FROM pago WHERE idPago=NEW.idPago;
			IF NEW.tipo = 'Tramitado' THEN
		SET new.MONTO=(SELECT costo FROM tramite join solicitud using(idtramite)where idSolicitud = id);
	END IF;
	END 
	&& DELIMITER ; 


-- TRIGGERS PARA QUE CUANDO SE INSERTE EN DOCUMENTO EL DOCUMENTO SOLICITADO CAMBIE EL ESTADO DE LA SOLICITUD.



	DROP TRIGGER insert_doc_solicitado;
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



	DROP TRIGGER update_doc_solicitado;
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

-- No poner esto

	DROP TRIGGER DELETE_doc_solicitado;
	DELIMITER $$
		CREATE TRIGGER DELETE_doc_solicitado BEFORE DELETE on documento
		FOR EACH ROW
		BEGIN
		DECLARE Id INT;
		SET id = NEW.idSolicitud;

		IF old.tipoDocumento = 'Solicitado' THEN
			UPDATE solicitud SET estado = 'en proceso' WHERE idSolicitud = id;
		END IF;
		END
	$$ DELIMITER ; 

-- 

