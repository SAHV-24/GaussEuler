-- Inserts para Normativa
INSERT INTO Normativa (linkPlantilla, descripcionNormativa) VALUES ('enlace_plantilla_1', 'Descripción de la Normativa 1');
INSERT INTO Normativa (linkPlantilla, descripcionNormativa) VALUES ('enlace_plantilla_2', 'Descripción de la Normativa 2');

-- Inserts para Unidad
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Unidad 1', 1234, 'unidad1@ejemplo.com');
INSERT INTO Unidad (nombreUnidad, extension, correo) VALUES ('Unidad 2', 5678, 'unidad2@ejemplo.com');

-- Inserts para Tramite
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (1, 1, 'Trámite 1', 'Descripción del Trámite 1', 100.00);
INSERT INTO Tramite (idUnidad, idNormativa, nombre, descripcion, costo) VALUES (2, 2, 'Trámite 2', 'Descripción del Trámite 2', 150.00);

-- Inserts para Usuario
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (123456, 'Administrativo', 'Juan', 'Pérez', 'juan@example.com', 123456789);
INSERT INTO Usuario (identificacion, tipo, nombre, apellido, correoElectronico, telefono) VALUES (789012, 'Estudiante', 'María', 'González', 'maria@example.com', 987654321);

-- Inserts para Solicitud
-- Suponiendo que los ids de Usuario y Tramite existen y son 1 y 1 respectivamente
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado, fechaInicio) VALUES (1, 2, 1, 'pendiente', NOW());
INSERT INTO Solicitud (idUsuario, idFuncionario, idTramite, estado, fechaInicio) VALUES (2, 1, 2, 'pendiente', NOW());

-- Inserts para Documento
-- Suponiendo que los ids de Solicitud son 1 y 2 respectivamente
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (1, 'ReciboDePago', 'Recibo de Pago 1', 'enlace_documento_1', 'activo');
INSERT INTO Documento (idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento) VALUES (2, 'Operacion', 'Operación 1', 'enlace_documento_2', 'activo');

-- Inserts para Pago
-- Suponiendo que los ids de Solicitud son 1 y 2 respectivamente
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (1, 'Por Pagar', CURRENT_DATE(), '2024-04-30', 100.00);
INSERT INTO Pago (idSolicitud, estadoDePago, fechaInicio, fechaLimite, monto) VALUES (2, 'Por Pagar', CURRENT_DATE(), '2024-04-30', 150.00);

-- Inserts para Comentario
-- Suponiendo que los ids de Solicitud y Usuario son 1 y 1 respectivamente
INSERT INTO Comentario (idSolicitud, idUsuario, comentarioAnterior, mensaje, fechaYhora) VALUES (1, 1, NULL, 'Primer comentario en la solicitud 1', NOW());
INSERT INTO Comentario (idSolicitud, idUsuario, comentarioAnterior, mensaje, fechaYhora) VALUES (2, 2, NULL, 'Primer comentario en la solicitud 2', NOW());
