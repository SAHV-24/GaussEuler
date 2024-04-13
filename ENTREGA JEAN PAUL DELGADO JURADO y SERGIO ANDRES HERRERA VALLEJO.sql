DROP DATABASE IF EXISTS proyecto;
CREATE DATABASE proyecto;
USE proyecto;

-- Normativa
CREATE TABLE Normativa (
			idNormativa int NOT NULL AUTO_INCREMENT,
			linkPlantilla TEXT NOT NULL,
			descripcionNormativa MEDIUMTEXT NOT NULL,
			fecha DATETIME NOT NULL DEFAULT NOW(),
			esVigente BOOLEAN NOT NULL,
			PRIMARY KEY (idNormativa)
			);
-- Unidad
CREATE TABLE Unidad (
			  idUnidad int NOT NULL AUTO_INCREMENT,
			  nombreUnidad varchar(100) NOT NULL,
			  extension int NOT NULL,
			  correo varchar(100) NOT NULL,
	
			  PRIMARY KEY (idUnidad)
                      );

-- Tramite
CREATE TABLE `tramite` (
			`idTramite` int NOT NULL AUTO_INCREMENT,
			`idUnidad` int NOT NULL,
			`idNormativa` int NOT NULL,
			`nombre` varchar(200) NOT NULL,
			`descripcion` TEXT NOT NULL,
			`costo` decimal(12,2) DEFAULT NULL,
			PRIMARY KEY (`idTramite`),
			KEY `idUnidad` (`idUnidad`),
			KEY `idNormativa` (`idNormativa`),
			CONSTRAINT `tramite_ibfk_1` FOREIGN KEY (`idUnidad`) REFERENCES `unidad` (`idUnidad`),
			CONSTRAINT `tramite_ibfk_2` FOREIGN KEY (`idNormativa`) REFERENCES `normativa` (`idNormativa`)
);

-- Usuario
CREATE TABLE Usuario 	(
			idUsuario INT NOT NULL AUTO_INCREMENT,
			identificacion INT NOT NULL,
			tipo ENUM('Administrativo','Estudiante','Docente','Empleado') NOT NULL,
			nombre VARCHAR(100) NOT NULL,
			apellido VARCHAR(100) NOT NULL,
			correoElectronico VARCHAR(200) NOT NULL,
			telefono INT NOT NULL,
			
			PRIMARY KEY(idUsuario),
			UNIQUE(identificacion,tipo)
			);

-- Solicitud
CREATE TABLE Solicitud (
			idSolicitud INT NOT NULL AUTO_INCREMENT,
			idUsuario INT NOT NULL,
			idFuncionario INT NOT NULL,
			idTramite INT NOT NULL,
			estado ENUM('pendiente','en proceso','completado','cerrado','cancelado') NOT NULL DEFAULT 'PENDIENTE',
			fechaInicio DATETIME NOT NULL DEFAULT NOW(),
			
			PRIMARY KEY(idSolicitud),
			FOREIGN KEY(idUsuario) REFERENCES usuario(idUsuario),       
			FOREIGN KEY(idFuncionario) REFERENCES usuario(idUsuario),
			FOREIGN KEY(idTramite) REFERENCES tramite(idTramite)
			);
             
-- Documento:
CREATE TABLE Documento (
			idDocumento INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
                        tipoDocumento ENUM('ReciboDePago','Operacion','Solicitado') NOT NULL,
                        tituloDocumento VARCHAR(100) NOT NULL,
                        linkDocumento TEXT NOT NULL,
			estadoDocumento ENUM('activo','inactivo') NOT NULL,

	
                        PRIMARY KEY(idDocumento),
                        FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
                        );
                        
-- Pago:
CREATE TABLE Pago (
			idPago INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
                        estadoDePago ENUM('Pagado','Por Pagar') NOT NULL,
                        fechaInicio DATE NOT NULL,
                        fechaLimite DATE NOT NULL,
                        monto DECIMAL(12,2) NOT NULL,
                        
                        PRIMARY KEY(idPago),
                        FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
                        );
                        
-- Comentario:
CREATE TABLE Comentario(
			idComentario INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
			idUsuario INT NOT NULL,
			comentarioAnterior INT NULL,
			mensaje MEDIUMTEXT NOT NULL,
			fechaYhora DATETIME NOT NULL DEFAULT NOW(),
			
			PRIMARY KEY(idComentario),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud),
			FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
			FOREIGN KEY (comentarioAnterior) REFERENCES comentario(idComentario)
                        );
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									TRIGGERS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    
    SET NEW.monto=(SELECT costo FROM tramite JOIN solicitud USING(idTramite) WHERE idSolicitud=id);
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


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									FUNCTIONS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- FUNCIÓN para obtener el ESTADO de la Solicitud

DROP FUNCTION IF EXISTS getEstadoSolicitud;

DELIMITER //
CREATE FUNCTION getEstadoSolicitud(laID INT) RETURNS VARCHAR(50) 
READS SQL DATA 
BEGIN
	declare res VARCHAR(50);

	SELECT estado INTO res FROM solicitud WHERE idSolicitud=laID;

	RETURN res;
END //
DELIMITER ; 

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									PROCEDURES          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Procedimientos para llamar a tablas:
DROP PROCEDURE IF EXISTS u;
DELIMITER // 
CREATE PROCEDURE u()
SELECT * FROM usuario;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS s;
DELIMITER // 
CREATE PROCEDURE s()
SELECT * FROM solicitud;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS t;
DELIMITER // 
CREATE PROCEDURE t()
SELECT * FROM tramite;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS c;
DELIMITER // 
CREATE PROCEDURE c()
SELECT * FROM comentario;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS n;
DELIMITER // 
CREATE PROCEDURE n()
SELECT * FROM normativa;
// DELIMITER ; 

DROP PROCEDURE IF EXISTS p;
DELIMITER // 
CREATE PROCEDURE p()
SELECT * FROM pago;
// DELIMITER ; 

DROP PROCEDURE IF EXISTS d;
DELIMITER // 
CREATE PROCEDURE d()
SELECT * FROM documento;
// DELIMITER ; 


-- Seleccionar pago por ID de la solicitud
DROP procedure if exists estadoDePago;
DELIMITER // 
	CREATE PROCEDURE estadoDePago (in elID INT)
	BEGIN
	SELECT elId, idSolicitud, estadoDePago FROM pago WHERE idSolicitud=elID;
	END;
// DELIMITER ;                                      

-- Cambiar el estado de un determinado Documento:
DROP PROCEDURE IF EXISTS cambiarEstadoDocumento;

DELIMITER // 
CREATE PROCEDURE cambiarEstadoDocumento(IN idDoc INT) 
BEGIN
	DECLARE elEstado VARCHAR(50);
    SELECT estadoDocumento INTO elEstado FROM documento WHERE idDocumento=idDoc;
    
    IF elEstado='activo' THEN
		SET elEstado='inactivo';
	ELSE
		SET elEstado='activo';
	END IF;    
    
    UPDATE documento SET estadoDocumento = elEstado WHERE idDocumento=idDoc;
	SELECT CONCAT('Nuevo Estado: ',elEstado,'. Documento con ID: ',idDoc) AS 'Nuevo Mensaje';
END
// DELIMITER ;

-- Revisa los Recibos De Pago Activos de una SOLICITUD:
DROP PROCEDURE IF EXISTS reciboActivo;

DELIMITER // 
CREATE PROCEDURE reciboActivo(IN idSOLI INT)
BEGIN
	DECLARE cant INT;
	SELECT COUNT(*) INTO cant FROM documento where idSolicitud=idSOLI AND tipoDocumento = 'ReciboDePago' AND estadoDocumento='activo';
    
    IF cant=1 THEN
		SELECT * FROM documento where idSolicitud=idSOLI AND tipoDocumento = 'ReciboDePago' AND estadoDocumento='activo';
    	ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ' NO HAY RECIBOS DE PAGO ACTIVOS';
	END IF;
    
    END
// DELIMITER ; 


-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									INSERTS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

