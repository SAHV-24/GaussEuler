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
			telefono BIGINT NOT NULL,
            sexo ENUM('H','M','O'),
			
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
    
    IF id IN(SELECT idSolicitud FROM solicitud) THEN 
		SET NEW.monto=(SELECT costo FROM tramite JOIN solicitud USING(idTramite) WHERE idSolicitud=id);
	else
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
-- Acta de Grado
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://actadegrado.pdf', 'Normativa que establece los requisitos y procedimientos para la obtención del Acta de Grado.', 1);

-- Extensión de Créditos
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://extensiondecreditos.pdf', 'Normativa que regula el proceso para solicitar una extensión de créditos académicos.', 1);

-- Actualización de Documento de Identidad
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://actualizaciondocumento.pdf', 'Normativa que establece los procedimientos para la actualización del documento de identidad de los estudiantes.', 1);

-- Actualización de Datos Personales
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://actualizaciondatos.pdf', 'Normativa que regula el proceso de actualización de datos personales de los estudiantes.', 1);

-- Modificación de Matrícula Académica
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://modificacionmatricula.pdf', 'Normativa que establece los procedimientos para realizar modificaciones en la matrícula académica.', 1);

-- Solicitud de Documento Académico
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicituddocumento.pdf', 'Normativa que regula el proceso para solicitar documentos académicos como certificados y constancias.', 1);

-- Solicitud de Intercambio MOVE
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicitudintercambio.pdf', 'Normativa que establece los requisitos y procedimientos para solicitar participar en el programa de intercambio estudiantil MOVE.', 1);

-- Solicitud de Servicios de Apoyo Estudiantil
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicitudapoyo.pdf', 'Normativa que regula el proceso para solicitar servicios de apoyo estudiantil ofrecidos por la universidad.', 1);

-- Modificación de Horario
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://modificacionhorario.pdf', 'Normativa que establece los procedimientos para solicitar modificaciones en el horario de clases.', 1);

-- Certificado de Matrícula
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://certificadomatricula.pdf', 'Normativa que regula el proceso para obtener un certificado de matrícula.', 1);

-- Certificado Laboral
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://certificadolaboral.pdf', 'Normativa que establece los procedimientos para solicitar un certificado laboral.', 1);

-- Certificado de Publicaciones
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://certificadopublicaciones.pdf', 'Normativa que regula el proceso para obtener un certificado de publicaciones académicas.', 1);

-- Certificado de Prácticas y Pasantías Institucionales
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://certificadopracticas.pdf', 'Normativa que establece los procedimientos para obtener un certificado de prácticas y pasantías institucionales.', 1);

-- Certificado Oficial de Notas
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://certificadonotas.pdf', 'Normativa que regula el proceso para obtener un certificado oficial de notas.', 1);

-- Solicitud de Contenidos Programáticos
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicitudcontenidos.pdf', 'Normativa que establece los procedimientos para solicitar contenidos programáticos de cursos y asignaturas.', 1);

-- Solicitud de Cancelación de Semestre
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicitudcancelacionsemestre.pdf', 'Normativa que regula el proceso para solicitar la cancelación de un semestre.', 1);

-- Solicitud de Cancelación de Materias
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente)
VALUES ('http://solicitudcancelacionmaterias.pdf', 'Normativa que establece los procedimientos para solicitar la cancelación de materias inscritas.', 1);


-- UNIDADES:


-- Registro Académico
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Registro Académico', 12345, 'registroacademico@universidad.edu');

-- Departamento de Grados y Títulos
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Departamento de Grados y Títulos', 12346, 'gradosytitulos@universidad.edu');

-- Unidad de Recursos Humanos
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Unidad de Recursos Humanos', 12347, 'recursoshumanos@universidad.edu');

-- Oficina de Relaciones Externas
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Oficina de Relaciones Externas', 12348, 'relacionesexternas@universidad.edu');

-- Departamento de Bienestar Universitario
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Departamento de Bienestar Universitario', 12349, 'bienestaruniversitario@universidad.edu');

-- Departamento de Investigación
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Departamento de Investigación', 12350, 'investigacion@universidad.edu');

-- Departamento de Prácticas Profesionales
INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES ('Departamento de Prácticas Profesionales', 12351, 'practicasprofesionales@universidad.edu');



-- TRÁMITES

-- Acta de Grado
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (1, 2, 1, 'Acta de Grado', 'Trámite para solicitar la expedición del Acta de Grado.', 10000);

-- Extensión de Créditos
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (2, 1, 2, 'Extensión de Créditos', 'Trámite para solicitar una extensión de créditos académicos.', 12000);

-- Actualización de Documento de Identidad
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (3, 1, 3, 'Actualización de Documento de Identidad', 'Trámite para actualizar el documento de identidad.', 15000);

-- Actualización de Datos personales
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (4, 1, 4, 'Actualización de Datos Personales', 'Trámite para actualizar los datos personales del estudiante.', 8000);

-- Modificación de Matrícula Académica
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (5, 1, 5, 'Modificación de Matrícula Académica', 'Trámite para modificar la matrícula académica del estudiante.', 9000);

-- Solicitud de Documento Académico
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (6, 1, 6, 'Solicitud de Documento Académico', 'Trámite para solicitar documentos académicos como certificados y constancias.', 7000);

-- Solicitud de Intercambio MOVE
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (7, 4, 7, 'Solicitud de Intercambio MOVE', 'Trámite para solicitar participación en el programa de intercambio estudiantil MOVE.', 11000);

-- Solicitud de Servicios de Apoyo estudiantil
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (8, 5, 8, 'Solicitud de Servicios de Apoyo Estudiantil', 'Trámite para solicitar servicios de apoyo estudiantil.', 13000);

-- Modificación de horario
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (9, 1, 9, 'Modificación de Horario', 'Trámite para solicitar modificaciones en el horario de clases.', 10000);

-- Certificado de Matrícula
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (10, 1, 10, 'Certificado de Matrícula', 'Trámite para obtener un certificado de matrícula.', 8500);

-- Certificado Laboral
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (11, 3, 11, 'Certificado Laboral', 'Trámite para solicitar un certificado laboral.', 9500);

-- Certificado de publicaciones
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (12, 6, 12, 'Certificado de Publicaciones', 'Trámite para obtener un certificado de publicaciones académicas.', 11000);

-- Certificado de prácticas y pasantías institucionales
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (13, 7, 13, 'Certificado de Prácticas y Pasantías Institucionales', 'Trámite para obtener un certificado de prácticas y pasantías institucionales.', 12000);

-- Certificado oficial de notas
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (14, 1, 14, 'Certificado Oficial de Notas', 'Trámite para obtener un certificado oficial de notas.', 9000);

-- Solicitud de contenidos programáticos
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (15, 1, 15, 'Solicitud de Contenidos Programáticos', 'Trámite para solicitar contenidos programáticos de cursos y asignaturas.', 8000);

-- Solicitud de cancelación de semestre
INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (16, 1, 16, 'Solicitud de Cancelación de Semestre', 'Trámite para solicitar la cancelación de un semestre.', 7500);

-- Solicitud de cancelación de materias

INSERT INTO tramite (idTramite, idUnidad, idNormativa, nombre, descripcion, costo)
VALUES (17, 1, 17, 'Solicitud de Cancelación de Materias', 'Trámite para solicitar la cancelación de materias inscritas.', 8500);


-- USUARIOS:



INSERT INTO Usuario (sexo, identificacion, tipo, nombre, apellido, correoElectronico, telefono)
VALUES 
('H', 1001234567, 'Administrativo', 'Juan', 'García', 'juan_garcia@uao.edu.co', 1234567890),
('M', 1112345678, 'Administrativo', 'María', 'Martínez', 'maria_martinez@uao.edu.co', 2345678901),
('H', 1013456789, 'Administrativo', 'Pedro', 'López', 'pedro_lopez@uao.edu.co', 3456789012),
('M', 1012345678, 'Administrativo', 'Ana', 'Rodríguez', 'ana_rodriguez@uao.edu.co', 4567890123),
('H', 1009876543, 'Administrativo', 'Luis', 'Sánchez', 'luis_sanchez@uao.edu.co', 5678901234),
('H', 1001234567, 'Estudiante', 'Juan', 'García', 'juan_garcia@uao.edu.co', 1234567890),
('M', 1112345678, 'Estudiante', 'María', 'Martínez', 'maria_martinez@uao.edu.co', 2345678901),
('H', 1001111111, 'Estudiante', 'Carlos', 'Pérez', 'carlos_perez@uao.edu.co', 1234567890),
('M', 1112222222, 'Estudiante', 'Laura', 'Gómez', 'laura_gomez@uao.edu.co', 2345678901),
('H', 1013333333, 'Estudiante', 'Andrés', 'Díaz', 'andres_diaz@uao.edu.co', 3456789012),
('M', 1014444444, 'Estudiante', 'Ana', 'Rodríguez', 'ana_rodriguez@uao.edu.co', 4567890123),
('H', 1005555555, 'Estudiante', 'Luis', 'Sánchez', 'luis_sanchez@uao.edu.co', 5678901234),
('H', 1006666666, 'Estudiante', 'Diego', 'Martínez', 'diego_martinez@uao.edu.co', 6789012345),
('M', 1117777777, 'Estudiante', 'Camila', 'García', 'camila_garcia@uao.edu.co', 7890123456),
('H', 1018888888, 'Estudiante', 'José', 'Fernández', 'jose_fernandez@uao.edu.co', 8901234567),
('M', 1029999999, 'Estudiante', 'Marcela', 'Hernández', 'marcela_hernandez@uao.edu.co', 9012345678),
('M', 1030000000, 'Estudiante', 'Andrea', 'López', 'andrea_lopez@uao.edu.co', 1231231234),
('H', 100111111, 'Docente', 'Ricardo', 'Gómez', 'ricardo_gomez@uao.edu.co', 1112223333),
('M', 1101011111, 'Docente', 'Isabel', 'Díaz', 'isabel_diaz@uao.edu.co', 2223334444),
('H', 1000000001, 'Docente', 'Mario', 'Martínez', 'mario_martinez@uao.edu.co', 3334445555),
('M', 1004400004, 'Empleado', 'Lorena', 'González', 'lorena_gonzalez@uao.edu.co', 4445556666),
('H', 1115555555, 'Empleado', 'Javier', 'Gutiérrez', 'javier_gutierrez@uao.edu.co', 5556667777);


-- 

-- SOLICITUD:
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite)
VALUES 
(6, 1, 17),
(22, 2, 17),
(3, 4, 3),
(6, 5, 4),
(2, 5, 5),
(6, 4, 17),
(7, 3, 17),
(6, 2, 8),
(16, 1, 16),
(13, 1, 10);

