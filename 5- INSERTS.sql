-- Inserts definitivos

-- Normativa

INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/certificado_laboral.pdf', 'Normativa para la emisión de certificados laborales', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/certificado_de_publicaciones.pdf', 'Normativa para la expedición de certificados de publicaciones', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/certificado_de_practicas_y_pasantias_institucionales.pdf', 'Normativa para la solicitud de certificados de prácticas y pasantías institucionales', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/certificado_oficial_de_notas.pdf', 'Normativa para la entrega de certificados oficiales de notas', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_contenidos_programaticos.pdf', 'Normativa para solicitar contenidos programáticos', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_cancelacion_de_semestre.pdf', 'Normativa para solicitar la cancelación de semestre', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_cancelacion_de_materias.pdf', 'Normativa para solicitar la cancelación de materias', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_constancia_de_estudios.pdf', 'Normativa para solicitar constancia de estudios', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_cambio_de_carrera.pdf', 'Normativa para solicitar el cambio de carrera', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_equivalencia_de_asignaturas.pdf', 'Normativa para solicitar la equivalencia de asignaturas', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_reconocimiento_de_creditos.pdf', 'Normativa para solicitar el reconocimiento de créditos', TRUE);
INSERT INTO Normativa (linkPlantilla, descripcionNormativa, esVigente) VALUES ('uao.edu.co/normativa/solicitud_de_certificacion_de_idiomas.pdf', 'Normativa para solicitar certificación de idiomas', TRUE);

-- Unidad

INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Recursos Humanos', 12345, 'rh@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Biblioteca', 23456, 'biblioteca@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Coordinación de Prácticas', 34567, 'practicas@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Registro Académico', 45678, 'registro@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Coordinación Académica', 56789, 'academica@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Dirección de Programas Académicos', 67890, 'direcprogramas@uao.edu.co');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Departamento de Idiomas', 78901, 'idiomas@uao.edu.co');

-- Tramites

INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (1, 1, 'Certificado Laboral', 'Certificado laboral emitido por Recursos Humanos', 14000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (2, 2, 'Certificado de Publicaciones', 'Certificado de publicaciones emitido por la Biblioteca', 15000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (3, 3, 'Certificado de Prácticas y Pasantías Institucionales', 'Certificado de prácticas y pasantías institucionales emitido por la Coordinación de Prácticas', 16000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 4, 'Certificado Oficial de Notas', 'Certificado oficial de notas emitido por el Registro Académico', 17000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (5, 5, 'Solicitud de Contenidos Programáticos', 'Solicitud de contenidos programáticos emitida por la Coordinación Académica', 18000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 6, 'Solicitud de Cancelación de Semestre', 'Solicitud de cancelación de semestre emitida por la Dirección de Programas Académicos', 19000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 7, 'Solicitud de Cancelación de Materias', 'Solicitud de cancelación de materias emitida por el Departamento de Idiomas', 20000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 8, 'Solicitud de Constancia de Estudios', 'Solicitud de constancia de estudios emitida por el Registro Académico', 21000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (6, 9, 'Solicitud de Cambio de Carrera', 'Solicitud de cambio de carrera emitida por la Dirección de Programas Académicos', 22000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 10, 'Solicitud de Equivalencia de Asignaturas', 'Solicitud de equivalencia de asignaturas emitida por el Registro Académico', 23000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (4, 11, 'Solicitud de Reconocimiento de Créditos', 'Solicitud de reconocimiento de créditos emitida por el Registro Académico', 24000.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (7, 12, 'Solicitud de Certificación de Idiomas', 'Solicitud de certificación de idiomas emitida por el Departamento de Idiomas', 25000.00);

-- Usuarios

INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1101234567, 'Administrativo', 'María', 'García', 'mariag@uao.edu.co', 3123456789);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1102345678, 'Administrativo', 'Pedro', 'López', 'pedrol@uao.edu.co', 3134567890);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1103456789, 'Administrativo', 'Ana', 'Martínez', 'anam@uao.edu.co', 3145678901);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1114567890, 'Estudiante', 'David', 'Hernández', 'davidh@uao.edu.co', 3156789012);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1115678901, 'Estudiante', 'Laura', 'Gómez', 'laurag@uao.edu.co', 3167890123);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1116789012, 'Estudiante', 'Juan', 'Díaz', 'juand@uao.edu.co', 3178901234);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1117890123, 'Docente', 'Carlos', 'Ruiz', 'carlosr@uao.edu.co', 3189012345);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1118901234, 'Docente', 'Sofía', 'Pérez', 'sofiap@uao.edu.co', 3190123456);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1119012345, 'Docente', 'Elena', 'Torres', 'elenat@uao.edu.co', 3201234567);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1110123456, 'Empleado', 'Javier', 'Gutiérrez', 'javierg@uao.edu.co', 3212345678);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1111234567, 'Empleado', 'Mónica', 'Sánchez', 'monicas@uao.edu.co', 3223456789);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1112345678, 'Empleado', 'Andrés', 'Ramírez', 'andresr@uao.edu.co', 3234567890);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1113456789, 'Estudiante', 'Valentina', 'López', 'valentinal@uao.edu.co', 3245678901);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1114567890, 'Docente', 'Gabriel', 'Martínez', 'gabrielm@uao.edu.co', 3256789012);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (1115678901, 'Empleado', 'Camila', 'Gómez', 'camilag@uao.edu.co', 3267890123);

-- Solicitud

INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (4, 1, 1, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (5, 2, 2, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (6, 3, 3, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (7, 1, 4, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (8, 2, 5, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (9, 3, 6, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (10, 1, 7, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (11, 2, 8, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (12, 3, 9, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (13, 1, 10, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (14, 2, 11, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (15, 3, 12, 'en proceso');
-- 
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (14, 1, 1, 'en proceso');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (10, 2, 2, 'completado');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (12, 2, 4, 'completado');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (15, 3, 6, 'cerrado');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (9, 1, 7, 'cancelado');
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado) VALUES (13, 1, 9, 'cancelado');

-- Documento

INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (1, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash1', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (2, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash2', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (3, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash3', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (4, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash4', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (5, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash5', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (6, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash6', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (7, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash7', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (8, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash8', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (9, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash9', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (10, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash10', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (11, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash11', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (12, 'ReciboDePago', 'Recibo de pago por concepto de trámite', 'cloud.uao.edu.co/hash12', 'activo');
-- Para operacion
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (1, 'Operacion', 'Soporte carnet estudiantil', 'cloud.uao.edu.co/hash13', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (2, 'Operacion', 'Soporte cédula de ciudadanía', 'cloud.uao.edu.co/hash14', 'activo');

-- Pago

INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (1, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 12345.67);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (2, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 13456.78);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (3, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 14567.89);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (4, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 15678.90);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (5, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 16789.01);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (6, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 17890.12);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (7, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 18901.23);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (8, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 19012.34);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (9, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 10123.45);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (10, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 11234.56);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (11, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 12345.67);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (12, 'Por Pagar', CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 10 DAY), 13456.78);

-- Comentario
INSERT INTO Comentario (idSolicitud, idUsuario, comentarioAnterior, mensaje) VALUES (3, 3, NULL, 'Por favor cargar el soporte para continuar');
INSERT INTO Comentario (idSolicitud, idUsuario, comentarioAnterior, mensaje) VALUES (5, 2, NULL, 'Confirme el código que llegó a su correo');
INSERT INTO Comentario (idSolicitud, idUsuario, comentarioAnterior, mensaje) VALUES (5, 8, 2, 'El código es 202876');