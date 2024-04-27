DROP DATABASE IF EXISTS PROYECTO;
CREATE DATABASE PROYECTO;
USE PROYECTO;

-- Unidad
CREATE TABLE Unidad (
			  idUnidad int NOT NULL AUTO_INCREMENT,
			  nombreUnidad varchar(100) NOT NULL,
			  extension int NOT NULL,
			  correo varchar(100) NOT NULL,
	
			  PRIMARY KEY (idUnidad)
			  );
ALTER TABLE unidad ADD CONSTRAINT checkExtension CHECK(extension<100000);
ALTER TABLE unidad ADD CONSTRAINT checkCorreoUnidad CHECK(correo LIKE '%@%');


-- Tramite
CREATE TABLE Tramite (
			idTramite int NOT NULL AUTO_INCREMENT,
			idUnidad int NOT NULL,
			linkPlantilla TEXT NOT NULL,
			nombre varchar(200) NOT NULL,
			descripcion TEXT NOT NULL,
			costo decimal(12,2) DEFAULT NULL,
            
			PRIMARY KEY (idTramite),
            FOREIGN KEY(idUnidad) REFERENCES unidad(idunidad))
            ;

ALTER TABLE Tramite ADD CONSTRAINT revisarCOsto CHECK (costo>=0);    
-- Normativa
CREATE TABLE Normativa (
			idNormativa int NOT NULL AUTO_INCREMENT,
            idTramite INT NOT NULL,
			descripcionNormativa MEDIUMTEXT NOT NULL,
			fecha DATETIME NOT NULL DEFAULT NOW(),
			esVigente BOOLEAN NOT NULL,
            
			PRIMARY KEY (idNormativa),
            FOREIGN KEY(idTRamite) REFERENCES tramite (idTramite)
			);


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

ALTER TABLE Usuario ADD CONSTRAINT checkCorreoUsu CHECK(correoElectronico LIKE '%@%');

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
-- CONSTRAINTS                    
-- Pago:
CREATE TABLE Pago (
			idPago INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
			estadoDePago ENUM('Pagado','Por Pagar') NOT NULL,
			fechaInicio DATE NOT NULL,
			fechaLimite DATE NOT NULL,
			fechaDeCancelacion DATE NULL,
			monto DECIMAL(12,2) NOT NULL,
			
			PRIMARY KEY(idPago),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
                        );
                        
ALTER TABLE PAGO ADD CONSTRAINT revisarFechas CHECK (fechaInicio<=FechaLimite);   
ALTER TABLE PAGO ADD CONSTRAINT revisarMonto CHECK (MONTO>=0);    

-- fechaDeCancelacion se maneja desde un trigger, no desde un constraint.

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
			FOREIGN KEY (comentarioAnterior) REFERENCES comentario(idComentario));
            
            

-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									INSERTS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (1, 2,  'Acta de Grado', 'Trámite para solicitar la expedición del Acta de Grado.', 10000,'http://actadegrado.pdf');

-- Extensión de Créditos
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (2, 1,  'Extensión de Créditos', 'Trámite para solicitar una extensión de créditos académicos.', 12000,'http://extensiondecreditos.pdf');

-- Actualización de Documento de Identidad
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (3, 1, 'Actualización de Documento de Identidad', 'Trámite para actualizar el documento de identidad.', 15000,'http://actualizaciondocumento.pdf');

-- Actualización de Datos personales
INSERT INTO tramite (idTramite, idUnidad,  nombre, descripcion, costo,linkPlantilla)
VALUES (4, 1,  'Actualización de Datos Personales', 'Trámite para actualizar los datos personales del estudiante.', 8000,'http://actualizaciondatos.pdf');

-- Modificación de Matrícula Académica
INSERT INTO tramite (idTramite, idUnidad,  nombre, descripcion, costo,linkPlantilla)
VALUES (5, 1,  'Modificación de Matrícula Académica', 'Trámite para modificar la matrícula académica del estudiante.', 9000,'http://modificacionmatricula.pdf');

-- Solicitud de Documento Académico
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (6, 1,  'Solicitud de Documento Académico', 'Trámite para solicitar documentos académicos como certificados y constancias.', 7000,'http://solicituddocumento.pdf');

-- Solicitud de Intercambio MOVE
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (7, 4,  'Solicitud de Intercambio MOVE', 'Trámite para solicitar participación en el programa de intercambio estudiantil MOVE.', 11000,'http://solicitudintercambio.pdf');

-- Solicitud de Servicios de Apoyo estudiantil
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (8, 5,  'Solicitud de Servicios de Apoyo Estudiantil', 'Trámite para solicitar servicios de apoyo estudiantil.', 13000,'http://solicitudapoyo.pdf');

-- Modificación de horario
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (9, 1,  'Modificación de Horario', 'Trámite para solicitar modificaciones en el horario de clases.', 10000,'http://modificacionhorario.pdf');

-- Certificado de Matrícula
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (10, 1,  'Certificado de Matrícula', 'Trámite para obtener un certificado de matrícula.', 8500,'http://certificadomatricula.pdf');

-- Certificado Laboral
INSERT INTO tramite (idTramite, idUnidad,  nombre, descripcion, costo,linkPlantilla)
VALUES (11, 3, 'Certificado Laboral', 'Trámite para solicitar un certificado laboral.', 9500,'http://certificadolaboral.pdf');

-- Certificado de publicaciones
INSERT INTO tramite (idTramite, idUnidad,  nombre, descripcion, costo,linkPlantilla)
VALUES (12, 6, 'Certificado de Publicaciones', 'Trámite para obtener un certificado de publicaciones académicas.', 11000,'http://certificadopublicaciones.pdf');

-- Certificado de prácticas y pasantías institucionales
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (13, 7, 'Certificado de Prácticas y Pasantías Institucionales', 'Trámite para obtener un certificado de prácticas y pasantías institucionales.', 12000,'http://certificadopracticas.pdf');

-- Certificado oficial de notas
INSERT INTO tramite (idTramite, idUnidad,  nombre, descripcion, costo,linkPlantilla)
VALUES (14, 1, 'Certificado Oficial de Notas', 'Trámite para obtener un certificado oficial de notas.', 9000,'http://certificadonotas.pdf');

-- Solicitud de contenidos programáticos
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (15, 1,  'Solicitud de Contenidos Programáticos', 'Trámite para solicitar contenidos programáticos de cursos y asignaturas.', 8000,'http://solicitudcontenidos.pdf');

-- Solicitud de cancelación de semestre
INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (16, 1, 'Solicitud de Cancelación de Semestre', 'Trámite para solicitar la cancelación de un semestre.', 7500,'http://solicitudcancelacionsemestre.pdf');

-- Solicitud de cancelación de materias

INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo,linkPlantilla)
VALUES (17, 1, 'Solicitud de Cancelación de Materias', 'Trámite para solicitar la cancelación de materias inscritas.', 8500,'http://solicitudcancelacionmaterias.pdf');



-- Acta de Grado
INSERT INTO Normativa (idTramite, descripcionNormativa, esVigente)
VALUES 
('1', 'Normativa que establece los requisitos y procedimientos para la obtención del Acta de Grado.', 1),
(1,'Normativa que establece Documentos Solicitados para un acta de grado',1),
('2', 'Normativa que regula el proceso para solicitar una extensión de créditos académicos.', 1),
('3', 'Normativa que establece los procedimientos para la actualización del documento de identidad de los estudiantes.', 1),
('4', 'Normativa que regula el proceso de actualización de datos personales de los estudiantes.', 1),
('5', 'Normativa que establece los procedimientos para realizar modificaciones en la matrícula académica.', 1),
('6', 'Normativa que regula el proceso para solicitar documentos académicos como certificados y constancias.', 1),
('7', 'Normativa que establece los requisitos y procedimientos para solicitar participar en el programa de intercambio estudiantil MOVE.', 1),
('8', 'Normativa que regula el proceso para solicitar servicios de apoyo estudiantil ofrecidos por la universidad.', 1),
('9', 'Normativa que establece los procedimientos para solicitar modificaciones en el horario de clases.', 1),
('10', 'Normativa que regula el proceso para obtener un certificado de matrícula.', 1),
('11', 'Normativa que establece los procedimientos para solicitar un certificado laboral.', 1),
('12', 'Normativa que regula el proceso para obtener un certificado de publicaciones académicas.', 1),
('13', 'Normativa que establece los procedimientos para obtener un certificado de prácticas y pasantías institucionales.', 1),
('14', 'Normativa que regula el proceso para obtener un certificado oficial de notas.', 1),
('15', 'Normativa que establece los procedimientos para solicitar contenidos programáticos de cursos y asignaturas.', 1),
('16', 'Normativa que regula el proceso para solicitar la cancelación de un semestre.', 1),
('17', 'Normativa que establece los procedimientos para solicitar la cancelación de materias inscritas.', 1);


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
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite,fechaInicio)
VALUES 
(6, 1, 17,current_date()-4),
(22, 2, 17,current_date()-4),
(3, 4, 3,current_date()-4),
(6, 5, 4,current_date()-4),
(2, 5, 5,current_date()-4),
(6, 4, 17,current_date()-4),
(7, 3, 17,current_date()-4),
(6, 2, 8,current_date()-4),
(16, 1, 16,current_date()-4),
(13, 1, 10,current_date()-4),
(14,4,16,current_date()-4),
(12,5,6,current_date()-4),
(10,3,2,current_date()-4),
(9,2,16,current_date()-4),
(4,5,2,current_date()-4);

-- DESCOMENTAR PARA ACTUALIZAR LOS IDS IMPARES
-- UPDATE solicitud set estado='en proceso' where idSolicitud%2!=0;
UPDATE solicitud set estado='en proceso' where idSolicitud%2=0;


-- PROBAR QUE PASA SI SE EJECUTA 
 -- INSERT INTO PAGO(idSolicitud,fechaInicio,fechaLimite) VALUES(1,current_date(),current_date()+1);

INSERT INTO comentario (idComentario,idSolicitud,idUsuario,mensaje,comentarioAnterior)
VALUES (1,3,3,'Hola',NULL),
(2,3,4,'Hola Usuario, cómo estás???',1),
(3,3,4,'Necesito tu cédula por favor',2),
(4,3,3,'Bien y tú?',1),
(5,3,3,'http://lacedula.com',4),
(6,4,6,'Hola',NULL),
(7,4,5,'Hola Usuario, cómo estás???',6),
(8,4,5,'Necesito tu cédula por favor',7),
(9,4,6,'Bien y tú?',6),
(10,4,6,'http://lacedula.com',9)
,(11,14,9,'Hola',NULL),
(12,14,2,'Hola Usuario, cómo estás???',11),
(13,14,2,'Necesito tu cédula por favor',12),
(14,14,9,'Bien y tú?',12),
(15,14,9,'http://lacedula.com',14);

-- DOCUMENTOS : 


INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento)
VALUES 
(15, 'ReciboDePago', 'Recibo de Pago', 'link1', 'inactivo'),
(15, 'Operacion', 'CEDULA', 'link2', 'activo'),
(15, 'Operacion', 'Derechos', 'link6', 'activo'),
(15, 'ReciboDePago', 'Recibo de Pago 2', 'link7', 'activo'),
(3, 'Solicitado', 'Documento Solicitado ', 'link3', 'activo'),
(4, 'Operacion', 'CEDULA', 'link4', 'activo'),
(5, 'Operacion', 'cc', 'link5', 'activo'),
(8, 'Operacion', 'c.c', 'link8', 'activo'),
(14, 'ReciboDePago', 'Recibo de Pago 3', 'link9', 'INactivo'),
(14, 'ReciboDePago', 'Recibo de Pago REALL', 'link10', 'activo'),
(14, 'Operacion', 'NotasSemestre4', 'link11', 'activo'),
(2, 'Solicitado', 'Trámite', 'link12', 'activo'),
(14, 'Operacion', 'Recibo de agua', 'link13', 'activo'),
(2, 'Operacion', 'CÉDULA', 'link14', 'activo'),
(2, 'Operacion', 'CÉDULA ', 'link15', 'activo'),
(5, 'Operacion', 'CÉDULA ', 'link16', 'activo');


INSERT INTO solicitud (idUsuario,idFuncionario,idTramite)  VALUES (18,5,12),
(19,3,2),(4,5,10),(12,2,17),
(18,2,1),(18,5,14),(12,3,16);

UPDATE solicitud SET estado='en proceso' WHERE idUsuario IN(18,19,4,12);

INSERT INTO pago(idSolicitud,estadoDePago,fechaInicio,fechaLimite,fechaDecancelacion,monto)
VALUES(16,'Pagado',current_date(),current_date()+1,current_date(),105000),
(17,'Pagado',current_date(),current_date()+3,current_date()+1,105000 ),
(18,'Pagado',current_date(),current_date()+4,current_date()+2,105000),
(19,'Pagado',current_date(),current_date()+5,current_date()+1,0),
(20,'Pagado',current_date(),current_date()+6,current_date()+3,98530),
(21,'Pagado',current_date(),current_date()+7,current_date()+5,105000),
(22,'Pagado',current_date(),current_date()+8,current_date()+1,101201);

-- Insertar pagos en solicitudes seleccionadas
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto,fechaDeCancelacion)
VALUES (6, 'Pagado', current_date()-2, current_date()+3, 2000,current_date());

INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto,fechaDeCancelacion)
VALUES (4, 'Por Pagar', current_date(), current_date(), 1500, NULL);

INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto,fechaDeCancelacion)
VALUES (8, 'Por Pagar', current_date()-1, current_date, 2500,NULL);

INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto,fechaDeCancelacion)
VALUES (10, 'Por Pagar', current_date()-1, current_date, 3000,NULL);

INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto,fechaDeCancelacion)
VALUES (12, 'Pagado',current_date()-2, current_date()+10,56000,'2024-04-24'),
		(14, 'Pagado', current_date()+5, current_date()+12,98500,'2024-04-25');

UPDATE pago SET fechaLimite=fechaLimite+1 WHERE idSolicitud=4;
UPDATE pago SET fechaLimite=fechaLimite+3 WHERE idSolicitud=8;
UPDATE pago SET fechaLimite=fechaLimite+2 WHERE idSolicitud=10;

UPDATE solicitud set estado='completado' where idSolicitud IN(18,19,20,21);

   
