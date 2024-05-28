
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																									INSERTS          
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- UNIDADES:

INSERT INTO Unidad (nombreUnidad, extension, correo)
VALUES 
('Departamento de Bienestar Universitario', 12349, 'bienestaruniversitario@universidad.edu'),
('Departamento de Grados y Títulos', 12346, 'gradosytitulos@universidad.edu'),
('Departamento de Investigación', 12350, 'investigacion@universidad.edu'),
('Departamento de Prácticas Profesionales', 12351, 'practicasprofesionales@universidad.edu'),
('Oficina de Relaciones Externas', 12348, 'relacionesexternas@universidad.edu'),
('Registro Académico', 12345, 'registroacademico@universidad.edu'),
('Unidad de Recursos Humanos', 12347, 'recursoshumanos@universidad.edu');


-- TRÁMITES: 

INSERT INTO tramite (idTramite, idUnidad, nombre, descripcion, costo, linkPlantilla)
VALUES 
(1, 2, 'Acta de Grado', 'Trámite para solicitar la expedición del Acta de Grado.', 10000, 'http://actadegrado.pdf'),
(2, 1, 'Extensión de Créditos', 'Trámite para solicitar una extensión de créditos académicos.', 12000, 'http://extensiondecreditos.pdf'),
(3, 1, 'Actualización de Documento de Identidad', 'Trámite para actualizar el documento de identidad.', 15000, 'http://actualizaciondocumento.pdf'),
(4, 1, 'Actualización de Datos Personales', 'Trámite para actualizar los datos personales del estudiante.', 8000, 'http://actualizaciondatos.pdf'),
(5, 1, 'Modificación de Matrícula Académica', 'Trámite para modificar la matrícula académica del estudiante.', 9000, 'http://modificacionmatricula.pdf'),
(6, 1, 'Solicitud de Documento Académico', 'Trámite para solicitar documentos académicos como certificados y constancias.', 7000, 'http://solicituddocumento.pdf'),
(7, 4, 'Solicitud de Intercambio MOVE', 'Trámite para solicitar participación en el programa de intercambio estudiantil MOVE.', 11000, 'http://solicitudintercambio.pdf'),
(8, 5, 'Solicitud de Servicios de Apoyo Estudiantil', 'Trámite para solicitar servicios de apoyo estudiantil.', 13000, 'http://solicitudapoyo.pdf'),
(9, 1, 'Modificación de Horario', 'Trámite para solicitar modificaciones en el horario de clases.', 10000, 'http://modificacionhorario.pdf'),
(10, 1, 'Certificado de Matrícula', 'Trámite para obtener un certificado de matrícula.', 8500, 'http://certificadomatricula.pdf'),
(11, 3, 'Certificado Laboral', 'Trámite para solicitar un certificado laboral.', 9500, 'http://certificadolaboral.pdf'),
(12, 6, 'Certificado de Publicaciones', 'Trámite para obtener un certificado de publicaciones académicas.', 11000, 'http://certificadopublicaciones.pdf'),
(13, 7, 'Certificado de Prácticas y Pasantías Institucionales', 'Trámite para obtener un certificado de prácticas y pasantías institucionales.', 12000, 'http://certificadopracticas.pdf'),
(14, 1, 'Certificado Oficial de Notas', 'Trámite para obtener un certificado oficial de notas.', 9000, 'http://certificadonotas.pdf'),
(15, 1, 'Solicitud de Contenidos Programáticos', 'Trámite para solicitar contenidos programáticos de cursos y asignaturas.', 8000, 'http://solicitudcontenidos.pdf'),
(16, 1, 'Solicitud de Cancelación de Semestre', 'Trámite para solicitar la cancelación de un semestre.', 7500, 'http://solicitudcancelacionsemestre.pdf'),
(17, 1, 'Solicitud de Cancelación de Materias', 'Trámite para solicitar la cancelación de materias inscritas.', 8500, 'http://solicitudcancelacionmaterias.pdf');


-- NORMATIVA

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

 
-- SOLICITUD:

INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, fechaInicio)
VALUES 
(6, 1, 17, CURRENT_DATE()),
(22, 2, 17, CURRENT_DATE()),
(3, 4, 3, CURRENT_DATE()),
(6, 5, 4, CURRENT_DATE()),
(2, 5, 5, CURRENT_DATE()),
(6, 4, 17, CURRENT_DATE()),
(7, 3, 17, CURRENT_DATE()),
(6, 2, 8, CURRENT_DATE()),
(16, 1, 16, CURRENT_DATE()),
(13, 1, 10, CURRENT_DATE()),
(14, 4, 16, CURRENT_DATE()),
(12, 5, 6, CURRENT_DATE()),
(10, 3, 2, CURRENT_DATE()),
(9, 2, 16, CURRENT_DATE()),
(4, 5, 2, CURRENT_DATE()),
(18, 5, 12, CURRENT_DATE()),
(19, 3, 2, CURRENT_DATE()),
(4, 5, 10, CURRENT_DATE()),
(12, 2, 17, CURRENT_DATE()),
(18, 2, 1, CURRENT_DATE()),
(18, 5, 14, CURRENT_DATE()),
(12, 3, 16, CURRENT_DATE());


-- DESCOMENTAR PARA ACTUALIZAR LOS IDS IMPARES
-- UPDATE solicitud set estado='enproceso' where idSolicitud%2!=0;
UPDATE solicitud set estado='enproceso' where idSolicitud IN(2,4,6,8,10,12,14,16,18,20,22);
UPDATE solicitud SET estado='enproceso' WHERE idUsuario IN(18,19,4,12);


-- COMENTARIO

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


-- DOCUMENTO : 

INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento)
VALUES 
(2, 'Operacion', 'CÉDULA', 'link14', 'activo'),
(2, 'Operacion', 'CÉDULA ', 'link15', 'activo'),
(3, 'Solicitado', 'Documento Solicitado ', 'link3', 'activo'),
(4, 'Operacion', 'CEDULA', 'link4', 'activo'),
(5, 'Operacion', 'cc', 'link5', 'activo'),
(5, 'Operacion', 'CÉDULA ', 'link16', 'activo'),
(8, 'Operacion', 'c.c', 'link8', 'activo'),
(14, 'Operacion', 'NotasSemestre4', 'link11', 'activo'),
(14, 'Operacion', 'Recibo de agua', 'link13', 'activo'),
(14, 'ReciboDePago', 'Recibo de Pago 3', 'link9', 'INactivo'),
(14, 'ReciboDePago', 'Recibo de Pago REALL', 'link10', 'activo'),
(15, 'Operacion', 'CEDULA', 'link2', 'activo'),
(15, 'Operacion', 'Derechos', 'link6', 'activo'),
(15, 'ReciboDePago', 'Recibo de Pago', 'link1', 'inactivo');

insert into documento(idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
values(6,'ReciboDePago','recibo','recibo.pdf','activo'),
 (12,'ReciboDePago','recibo','recibo.pdf','activo'),
 (16,'ReciboDePago','recibo','recibo.pdf','activo'),
 (17,'ReciboDePago','recibo','recibo.pdf','activo'),
 (18,'ReciboDePago','recibo','recibo.pdf','activo'),
 (19,'ReciboDePago','recibo','recibo.pdf','activo'),
 (20,'ReciboDePago','recibo','recibo.pdf','activo'),
 (21,'ReciboDePago','recibo','recibo.pdf','activo'),
 (22,'ReciboDePago','recibo','recibo.pdf','activo');

-- PAGO:

INSERT INTO pago(idSolicitud, estadoDePago, fechaInicio, fechaLimite, saldadoEl, monto)
VALUES
    (4, 'PorPagar', CURRENT_DATE(), CURRENT_DATE(), NULL, 1500),
    (6, 'PorPagar', CURRENT_DATE(), CURRENT_DATE(), CURRENT_DATE(), 2000),
    (8, 'PorPagar', CURRENT_DATE(), CURRENT_DATE(), NULL, 2500),
    (10, 'PorPagar', CURRENT_DATE(), CURRENT_DATE(), NULL, 3000),
    (12, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 2 DAY, CURRENT_DATE() + INTERVAL 1 DAY, 56000),
    (14, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 2 DAY, CURRENT_DATE() + INTERVAL 2 DAY, 98500),
    (16, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 1 DAY, CURRENT_DATE(), 105000),
    (17, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 2 DAY, CURRENT_DATE() + INTERVAL 1 DAY, 105000),
    (18, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 2 DAY, CURRENT_DATE() + INTERVAL 2 DAY, 105000),
    (19, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 2 DAY, CURRENT_DATE() + INTERVAL 1 DAY, 0),
    (20, 'Pagado', CURRENT_DATE(), CURRENT_DATE(), CURRENT_DATE(), 98530),
    (21, 'Pagado', CURRENT_DATE(), CURRENT_DATE(), CURRENT_DATE(), 105000),
    (22, 'Pagado', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 1 DAY, CURRENT_DATE(), 101201);


UPDATE pago SET fechaLimite=(CURRENT_DATE() + INTERVAL 3 DAY) WHERE idSolicitud IN(4,8,10);

-- Completados:
UPDATE solicitud set estado='completado' where idSolicitud IN(18,19,20,21);

-- Pruebas
INSERT INTO SOLICITUD (idsolicitud,idUsuario,idfuncionario,idtramite,fechaInicio,estado)
VALUES(256,20,1,5,"2024-05-07","enProceso");

INSERT INTO SOLICITUD (idsolicitud,idUsuario,idfuncionario,idtramite,fechaInicio,estado)
VALUES(900,20,1,5,"2024-05-07","enProceso");
