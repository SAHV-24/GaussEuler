
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
(13, 1, 10),
(14,4,16),
(12,5,6),
(10,3,2),
(9,2,16),
(4,5,2);

-- DESCOMENTAR PARA ACTUALIZAR LOS IDS IMPARES
UPDATE solicitud set estado='en proceso' where idSolicitud%2=0;
INSERT INTO PAGO(idSolicitud,fechaInicio,fechalimite) VALUES
(2,current_date(),current_date()+1),(4,current_date(),current_date()+1),
(6,current_date(),current_date()+1) , (8,current_date(),current_date()+1),
(10,current_date(),current_date()+1),(12,current_date(),current_date()+1),
(14,current_date(),current_date()+1);

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
