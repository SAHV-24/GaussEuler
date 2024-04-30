insert into usuario VALUES(NULL,2220807,'Estudiante','Zharick','Prado','zharick.prado@uao.edu.co',3182553546,'M');
insert into solicitud(idUsuario,idFuncionario,idTramite) VALUES((SELECT idUsuario FROM usuario where nombre = 'Zharick'), 1,17);

select estado from solicitud where idUsuario = (SELECT idUsuario FROM usuario where nombre = 'Zharick');
select * from comentario where idSolicitud=23;


INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(NULL,'Hola Zharick, cómo estás???',1,23);
select estado from solicitud where idUsuario = (SELECT idUsuario FROM usuario where nombre = 'Zharick');

INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(16,'Hola, quiero solicitar mi trámite, me ayudas?!',(SELECT idUsuario FROM usuario where nombre = 'Zharick'),23);
INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(17,'Claro que si, para eso primero mandame tu documento de identidad, gracias!',1,23);
INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(18,'http://eldocumentoZharick.com',(SELECT idUsuario FROM usuario where nombre = 'Zharick'),23);
select * from comentario where idSolicitud=23;
select estado from solicitud where idUsuario = (SELECT idUsuario FROM usuario where nombre = 'Zharick');

-- Insertar al documento:
INSERT into DOCUMENTO(idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento)VALUES (23,'Operacion','Cédula Zharick Prado','http://eldocumentoZharick.com','activo');
SELECT * FROM DOCUMENTO where idSolicitud=23;

-- El funcionario verifica cuál es el trámite que está realizando el usuario, por lo tanto hace:

CALL tramiteDeSolicitud(23);


INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(19,'Listo Zharick!, procederemos a realizar el proceso de pago, el costo es de $8500 pesos',1,23);

-- Inserta en la tabla de pagos:

SELECT * FROM PAGO;

-- Se inserta como nulo para que se sepa que es el mismo valor que tiene el trámite por DEFECTO
INSERT into PAGO(idSolicitud,estadoDePago,fechaInicio,fechaLimite,monto) VALUES(23,'Por Pagar',current_date(),current_date()+1,NULL);

INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(20,'Hola!, ya lo pagué, adjunto el link:',(SELECT idUsuario FROM usuario where nombre = 'Zharick'),23);
INSERT into Comentario(comentarioAnterior,mensaje,idUsuario,idSOlicitud) VALUES(20,'reciboPago.pdf',(SELECT idUsuario FROM usuario where nombre = 'Zharick'),23);

-- Inserto el recibo de pago
INSERT into DOCUMENTO(idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento)VALUES (23,'ReciboDePago','Recibo De Pago Zharick Solicitud 23','reciboPago.pdf','activo');

-- Actualizar el estado De Pago con una fecha de cancelación OJO!
UPDATE pago SET estadoDePago = 'Pagado', fechaDeCancelacion=current_date() where idSolicitud=23;

-- Insertar  el documento SOLICITADO, esto hará que nuestra solicitud CULMINE!
SELECT estado FROM solicitud where idSolicitud=23;
INSERT into DOCUMENTO(idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento)VALUES (23,'Solicitado','Documento Solicitado','DocSolcitado_Sol_23.pdf','activo');
SELECT estado FROM solicitud where idSolicitud=23;


