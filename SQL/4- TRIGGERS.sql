-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									TRIGGERS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- TRIGGER QUE CUANDO SE INGRESE UN COMENTARIO SE CAMBIE EL ESTADO A 'En proceso' y 
-- Verifica que el usuario sea de esta solicitud
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
CREATE TRIGGER verificarPagos BEFORE INSERT ON pago
FOR EACH ROW 
BEGIN

	IF NOT (getEstadoSolicitud(new.idSolicitud) = 'enproceso') THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
	END IF;
    
    IF NEW.fechaInicio<(SELECT DATE(fechaInicio) FROM solicitud WHERE idSolicitud = new.idSolicitud) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha De inicio de la solicitud no coincide con la del pago';
	END IF;
    
	IF NEW.fechaLimite<current_date() AND getEstadoSolicitud(new.idSolicitud)='enproceso' THEN
		SET new.estadoDePago = 'Vencido';
		UPDATE solicitud SET estado='cancelado' WHERE idSolicitud = new.idSolicitud;
    END IF;
    
END
// DELIMITER ;

-- Triggers en solicitud

-- TRIGGER DE PAGO:
DROP TRIGGER IF EXISTS checkEstadoCerradoPAGO;
DELIMITER // 
CREATE TRIGGER checkEstadoCerradoPAGO BEFORE INSERT ON PAGO 
FOR EACH ROW
BEGIN

	DECLARE elEstado VARCHAR(50);
	SELECT estado INTO elEstado
	FROM solicitud WHERE idsolicitud = new.idSolicitud;
    
    IF elEstado = 'cerrado' THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta solicitud está CERRADA, por lo tanto no puede insertarse más datos.';
	END IF;   

END;
// DELIMITER ;

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

DROP TRIGGER IF EXISTS evitar_modificacion_cedula;
DELIMITER //

CREATE TRIGGER evitar_modificacion_cedula 
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF OLD.identificacion != NEW.identificacion THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No se permite modificar la cédula del usuario.';
    END IF;
END;
//

DELIMITER ;


DROP TRIGGER IF EXISTS evitar_modificacion_tipo;
DELIMITER //

CREATE TRIGGER evitar_modificacion_tipo 
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF OLD.tipo != NEW.tipo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No se permite modificar el tipo de usuario.';
    END IF;
END;
//

DELIMITER ;




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
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud está cerrada y no se pueden insertar más comentarios';
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
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La solicitud está cerrada y no se pueden actualizar más comentarios';
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
       
	IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='enproceso' AND OLD.fechaLimite = NEW.fechaLimite THEN
		SET new.estadoDePago = 'Vencido';
		UPDATE solicitud SET estado='cancelado' WHERE idSolicitud = id;
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


DROP TRIGGER IF EXISTS UPDATEverificarFechaDeSaldarPago;

DELIMITER //
CREATE TRIGGER UPDATEverificarFechaDeSaldarPago BEFORE UPDATE ON PAGO
FOR EACH ROW
BEGIN

IF NEW.saldadoEl > NEW.fechaLimite
	AND verificarFecha(NEW.idSolicitud)=FALSE
	OR
	NEW.saldadoEl < NEW.fechainicio
    AND verificarFecha(NEW.idSolicitud)=FALSE
    THEN
	    
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: La fecha de haber pagado no coincide con las Fechas de Inicio o De Límite!';

END IF;

END;
// DELIMITER ; 



-- TRIGGER PARA VERIFICAR LA FECHA DE CANCELACIÓN
DROP TRIGGER IF EXISTS  verificarFechaDeSaldarPago;

DELIMITER //
CREATE TRIGGER verificarFechaDeSaldarPago BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
	IF NEW.saldadoEl IS NOT NULL AND NEW.saldadoEl NOT BETWEEN NEW.fechaInicio AND NEW.fechaLimite THEN
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'ERROR: La fecha del pago no coincide con las Fechas de Inicio o De Límite!';
    END IF;
    
END
// DELIMITER ;


DROP TRIGGER IF EXISTS verificarFechaLimiteUPDATE;

DELIMITER //

CREATE TRIGGER verificarFechaLimiteUPDATE BEFORE UPDATE ON pago
FOR EACH ROW

BEGIN

	IF NEW.fechaLimite > OLD.saldadoEl AND OLD.saldadoEl IS NOT NULL
    AND OLD.estadoDePago = 'Pagado' AND NEW.estadoDePAGO='Pagado'
	THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: El pago ya está cancelado, 
							no puede modificarse la fecha de haber saldado el pago!';
	END IF;
    
    IF  NEW.fechaLimite < NEW.saldadoEl AND NEW.saldadoEl IS NOT NULL AND verificarFecha(NEW.idSolicitud) = FALSE
    THEN
    
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Verifique las fechas de Límite y las fechas de haber saldado el pago por favor!';
    
    END IF;       
END


// DELIMITER ; 

DROP TRIGGER IF EXISTS verificarFechaLimiteINSERT;

DELIMITER //

CREATE TRIGGER verificarFechaLimiteINSERT BEFORE INSERT ON pago
FOR EACH ROW

BEGIN
	IF NEW.fechaLimite < NEW.saldadoEl AND NEW.saldadoEl IS NOT NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha Límite no puede ser Menor 
													a la fecha de haber saldado el pago!';
	END IF;       
END


// DELIMITER ; 


DROP TRIGGER IF EXISTS verificarEstadoPagoUPDATE;

DELIMITER $$

CREATE TRIGGER verificarEstadoPagoUPDATE AFTER UPDATE ON PAGO
FOR EACH ROW

BEGIN
    IF NEW.estadoDePago = 'Pagado' AND NEW.saldadoEl IS NULL THEN 
		SIGNAL sqlstate '45000' 
        SET MESSAGE_TEXT = 'Antes de cambiar el estado del pago, debe la fecha de haber saldado el pago!';
	END IF;
END

$$ DELIMITER ; 



DROP TRIGGER IF EXISTS verificarEstadoPagoINSERT;

DELIMITER $$

CREATE TRIGGER verificarEstadoPagoINSERT BEFORE INSERT ON PAGO
FOR EACH ROW

BEGIN
    IF NEW.estadoDePago = 'Pagado' AND NEW.saldadoEl IS NULL THEN 
		SIGNAL sqlstate '45000' 
        SET MESSAGE_TEXT = 'Antes de agregar este registro, debe agregarse la fecha en que se saldó el pago!';
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
        SET MESSAGE_TEXT = 'Este comentario debe ser referenciado a otro puesto que ya existe el comentario raíz
';
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
        SET MESSAGE_TEXT = 'Este comentario debe ser referenciado a otro puesto que ya existe el comentario raíz';
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
    
    IF new.fechaYhora < horaMaxima AND (SELECT COUNT(*) FROM COMENTARIO WHERE IDSOLICITUD = NEW.IDSOLICITUD) !=0
		
    THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: La hora de envío de este comentario no concuerda con la 
										del último comentario de la solicitud!';
    END IF;
    
    IF DATE(new.fechaYHora)<(SELECT DATE(fechaInicio) FROM solicitud where idSolicitud = new.idSolicitud) THEN
				SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: La fecha del comentario no concuerda con el de la creación de la solicitud';
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
    FROM comentario GROUP BY (new.idSolicitud)
    AND (SELECT COUNT(*) FROM COMENTARIO WHERE IDSOLICITUD = NEW.IDSOLICITUD) !=0
    ;
    
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

DECLARE elEstadoDePago ENUM('Pagado','PorPagar');

IF new.iDSolicitud IN (SELECT idSolicitud FROM pago) THEN
	
    SELECT EstadoDePago INTO elEstadoDepago FROM pago where idSolicitud = NEW.idSolicitud;
    
    IF elEstadoDePago = 'PorPagar' AND new.tipoDocumento = 'Solicitado' THEN
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

DECLARE elEstadoDePago ENUM('Pagado','PorPagar');

IF new.iDSolicitud IN (SELECT idSolicitud FROM pago) THEN
	
    SELECT EstadoDePago INTO elEstadoDepago FROM pago where idSolicitud = NEW.idSolicitud;
    
    IF elEstadoDePago = 'PorPagar' AND new.tipoDocumento = 'Solicitado' THEN
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR, NO PUEDES INSERTAR EL DOCUMENTO SOLICITADO SI NO SE HA PAGADO';
    END IF;

END IF;
END;
$$ DELIMITER ; 


DROP TRIGGER IF EXISTS revisarPagos;
DELIMITER // 
CREATE TRIGGER revisarPagos BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN 

DECLARE elEstado VARCHAR(50);

IF NEW.idSolicitud IN (SELECT DISTINCT(idSolicitud) FROM pago) THEN
      
    SELECT estadoDePago INTO elEstado
		FROM pago where idSolicitud = NEW.idSolicitud;
        
	IF elEstado ='PorPagar' AND new.Estado = 'completado' THEN 
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No puedes actualizar la solicitud a completado si tiene un pago pendiente que no ha sido pagado!';
    END IF;
    
END IF;
END;



// DELIMITER ;

DROP TRIGGER  IF EXISTS verificarSiEstaCancelado;
DELIMITER //
CREATE TRIGGER verificarSiEstaCancelado AFTER INSERT ON CANCELACION
FOR EACH ROW
BEGIN 

	DECLARE elEstado VARCHAR(50);
    
    SELECT estado INTO elEstado
    FROM solicitud where idSolicitud = new.idSolicitud;
    
    IF elEstado != 'cancelado' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no se ha cancelado!, primero debe ser cancelada!';
	END IF;

END
// DELIMITER ; 



DROP TRIGGER IF EXISTS integridadCancelaciones;
DELIMITER $$
CREATE TRIGGER integridadCancelaciones BEFORE UPDATE ON SOLICITUD
FOR EACH ROW
BEGIN

DECLARE laCancelacion INT;

IF new.Estado !='cancelado' AND new.Estado != 'cerrado' AND OLD.estado = 'cancelado' THEN
	
    DELETE FROM cancelacion WHERE idSolicitud = NEW.idSolicitud;

END IF;

END
$$ DELIMITER ; 



DROP TRIGGER IF EXISTS checkEstadoCerradoDOC;
DELIMITER // 
CREATE TRIGGER checkEstadoCerradoDOC BEFORE INSERT ON DOCUMENTO 
FOR EACH ROW
BEGIN

	DECLARE elEstado VARCHAR(50);
	SELECT estado INTO elEstado
	FROM solicitud WHERE idsolicitud = new.idSolicitud;
    
    IF elEstado = 'cerrado' THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta solicitud está CERRADA, por lo tanto no puede insertarse más datos.';
	END IF;   

END;
// DELIMITER ;

DROP TRIGGER if exists integridad_fk_pagos_UPD;
DELIMITER //
CREATE TRIGGER integridad_fk_pagos_UPD BEFORE UPDATE ON PAGO
FOR EACH ROW
BEGIN

IF new.idSolicitud IN (SELECT DISTINCT(idsolicitud) FROM pago) AND 
	new.idSolicitud != OLD.idsolicitud THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error!, no se puede cambiar la solicitud porque la nueva solicitud ya tiene un pago registrado';
END IF;
END;
// DELIMITER ; 



DROP TRIGGER IF EXISTS integridadFKsSolicitud;
DELIMITER //
CREATE TRIGGER integridadFKsSolicitud BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN

DECLARE ID INT;
SET id = NEW.idSolicitud;
-- Si ya existen registros en las tablas que dependen de solicitud...
if id IN (SELECT DISTINCT(idsolicitud) from pago)
	OR id IN (SELECT DISTINCT(idsolicitud) from DOCUMENTO)
    OR id IN (SELECT DISTINCT(idsolicitud) from comentario) THEN
    
-- Y además de eso se ha cambiado el idDelUsuario o del funcionario o del trámite
	IF NEW.idUsuario != OLD.idUsuario 
		OR NEW.idTramite!= OLD.idTramite 
        OR NEW.idFuncionario != OLD.idFuncionario THEN 
		-- Lanzar una excepción!
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede actualizar las llaves foraneas';

	END IF;
    
END IF;
END
// DELIMITER ; 



DROP TRIGGER IF EXISTS revisarPagoVencidoUPD ; 
DELIMITER $$
CREATE TRIGGER revisarPagoVencidoUPD BEFORE UPDATE ON PAGO
FOR EACH ROW 
BEGIN

DECLARE id INT;
	SET id = OLD.idSolicitud;

if NEW.estadoDePago = 'vencido'  AND NOT (OLD.fechaLimite<current_date())AND getEstadoSolicitud(id)='enproceso' THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_text = 'No es posible actualizar a VENCIDO si la fecha limite del pago aún no ha caducado ';
END IF;
END;
$$ DELIMITER ;


DROP TRIGGER IF EXISTS revisarPagoVencidoINS ; 
DELIMITER $$
CREATE TRIGGER revisarPagoVencidoINS BEFORE INSERT ON PAGO
FOR EACH ROW 
BEGIN

DECLARE id INT;
	SET id = NEW.idSolicitud;

if NEW.estadoDePago = 'vencido'  AND NOT(NEW.fechaLimite<current_date()) AND getEstadoSolicitud(id)='enproceso' THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_text = 'No es posible insertar un pago VENCIDO si la fecha limite del pago aún no ha caducado';
END IF;
END;
$$ DELIMITER ;

DROP TRIGGER IF EXISTS verificarPagos;

DELIMITER //
CREATE TRIGGER verificarPagos BEFORE INSERT ON pago
FOR EACH ROW 
BEGIN
    -- Verifica que la solicitud esté en proceso
    IF NOT (getEstadoSolicitud(NEW.idSolicitud) = 'enproceso') THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
    END IF;

    -- Verifica que la fecha de inicio del pago sea mayor o igual a la fecha de inicio de la solicitud
    IF NEW.fechaInicio < (SELECT DATE(fechaInicio) FROM solicitud WHERE idSolicitud = NEW.idSolicitud LIMIT 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio de la solicitud no coincide con la del pago';
    END IF;

END //
DELIMITER ;

DROP TRIGGER IF EXISTS registrar_cancelacionxUsuario;

DELIMITER //
CREATE TRIGGER registrar_cancelacionxUsuario AFTER UPDATE ON solicitud
FOR EACH ROW
BEGIN
    DECLARE id INT;
    DECLARE elEstado VARCHAR(50);
    DECLARE fechaVerificada BOOL;
    SET id = NEW.idSolicitud;
    
    SET elEstado = getEstadoSolicitud(id);
    SET fechaVerificada = verificarFecha(id);

    IF elEstado = 'cancelado' THEN
        IF fechaVerificada THEN
            INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (id, 'SISTEMA', NOW());
        ELSE
            INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (id, 'USUARIO', NOW());
        END IF;
    END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS verificarUpdatesFechaSolicitud;
DELIMITER $$
CREATE TRIGGER verificarUpdatesFechaSolicitud BEFORE UPDATE ON solicitud
FOR EACH ROW
BEGIN

IF(new.fechaInicio!=OLD.fechaInicio) 
AND (OLD.idSolicitud IN (SELECT DISTINCT(idSolicitud) FROM pago)
OR OLD.idSolicitud IN(SELECT DISTINCT(idSolicitud) FROM documento) 
OR OLD.idSolicitud IN(SELECT DISTINCT(idSolicitud) FROM comentario))
THEN
	
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede cambiar la fecha de inicio de la solicitud porque ya hay tablas comprometidas con esta solicitud';
END IF;
END
$$ DELIMITER ; 

