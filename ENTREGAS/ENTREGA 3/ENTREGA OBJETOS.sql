-- /////////////////////////////    TRIGGERS PARA ASEGURAR LAS RELACIONES EN LA BASE DE DATOS   /////////////////////////////


-- DISCLAIMER --
-- Para probar estos triggers, es necesario que ya haya ejecutado el archivo de inserts dispuesto,
-- 		debido a que el caso de prueba fallaría si se dispusiera de otros registros específicos para 
-- 		realizar una prueba en concreto.


-- Inicio trigger --

-- 	Trigger para asegurar de que solo exista un comentario raíz por solicitud, por lo que
-- 		los demás comentarios en una solicitud específica deben realizarse como respuesta a otro,
-- 		más no pueden quedar como que no tuvieran un comentario anterior

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
				SET MESSAGE_TEXT = 'Este comentario debe referenciar a otro, puesto que ya existe el comentario de origen';
			END IF;
		END

		// DELIMITER ; 

-- INICIO PRUEBA --
-- Para realizar esta prueba, se debe contar con una solicitud de id 3, realizado por un usuario de id 3, la cual ya haya tenido el comentario origen (como se dispone en los inserts)
-- con el atributo comentarioAnterior null.
-- Se establece el idComentario como 10000 para que no entre en conflicto con otros comentarios que se agregan al ejecutar el archivo inserts.

INSERT INTO comentario (idComentario,idSolicitud,idUsuario,mensaje,comentarioAnterior)
VALUES (10000, 3, 3, 'Hola joven, que bella está.', NULL);


-- FIN PRUEBA 
-- Fin trigger --


-- Inicio trigger --


		-- Trigger para reforzar la relación 1:1 entre pago y solicitud

		DROP TRIGGER IF EXISTS relacionUnoAUnoPagoINS;

		DELIMITER // 
		CREATE TRIGGER relacionUnoAUnoPagoINS BEFORE INSERT ON pago
		FOR EACH ROW
		BEGIN
			IF NEW.idSolicitud IN (SELECT idSolicitud FROM pago) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un pago para esta solicitud. Actualicelo o eliminelo y cree un nuevo registro';
			END IF;
		END
		// DELIMITER ; 

-- INICIO PRUEBA --
-- Para realizar esta prueba, se debe contar con un recibo de pago para la solicitud de id 8 que 
-- ya haya sido creado (como en el archivo inserts).

INSERT INTO pago(idSolicitud, estadoDePago, fechaInicio, fechaLimite, fechaDeCancelacion, monto)
VALUES (8, 'PorPagar', CURRENT_DATE(), CURRENT_DATE() + INTERVAL 8 DAY, NULL, 10500);

-- FIN PRUEBA --
-- Fin trigger --


-- Inicio trigger --
-- Trigger para reforzar relación 1:1 entre cancelacion y solicitud (solo se puede cancelar una solicitud una sola vez)

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

-- INICIO PRUEBA --

-- Nota: no hay registros en el archivo inserts que correspondan a la tabla 'cancelacion'
SELECT * FROM cancelacion;

-- Actualizamos el estado de una solicitud a 'cancelado'
-- Estado antes:
SELECT idSolicitud,estado as estadoAntes FROM solicitud where idSolicitud=5;

UPDATE solicitud set estado = 'cancelado' where idSolicitud = 5;

-- Después
SELECT idSolicitud,estado as estadoDespues FROM solicitud where idSolicitud=5;

-- El trigger 'update_estado_limite_fecha' se encarga de agregar la solicitud al registro de solicitudes canceladas de la tabla 'cancelacion'
-- MÁS ADELANTE SE VERÁ ESTE FUNCIONAMIENTO!

-- Cuando se refiere a usuario, es que la cancelación fue realizada por algún usuario de la base de datos
-- y no automáticamente.
INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (5, 'USUARIO', CURRENT_DATE());

-- Intentamos cancelarla de nuevo
INSERT INTO cancelacion (idSolicitud, tipo, fecha) VALUES (5, 'USUARIO', CURRENT_DATE());


-- FIN PRUEBA --
-- Fin trigger --


-- /////////////////////////////    PROCESO DE CANCELACIÓN    /////////////////////////////



-- Se mostrarán las funciones que se utilizan en los triggers que siguen a continuación, algunos ejemplos
-- son añadidos.

-- Función que muestra si una solicitud ya se venció por su fecha,
-- esto sirve para el trigger de auditoría de cancelaciones, en caso tal de que un usuario
-- SE LE HAYA VENCIDO EL PAGO.

		DROP FUNCTION IF EXISTS verificarFecha;

		DELIMITER &&
		CREATE FUNCTION verificarFecha(elID INT) RETURNS BOOL 
		READS SQL DATA
		BEGIN
			DECLARE laFecha Varchar(50);
			DECLARE res BOOL;

			SELECT fechaLimite INTO laFecha FROM pago WHERE idSolicitud=elID;
			
			IF laFecha<current_date() THEN
				SET res=TRUE;
			ELSE
				SET res=FALSE;
			END IF;
			
			RETURN res;
		END
		&& DELIMITER ; 
        
        -- -------------- EJEMPLO: -----------
        
	-- Esta fecha aún no se ha vencido!
	 SELECT fechaLimite FROM pago where idSolicitud=4;
	 SELECT verificarFecha (4);
        
     -- FIN PRUEBA   
        
        
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
        
-- ----------------------------------------------------------------------------------------------------------------------------------------          

-- Proceso para CANCELACIONES y auditoría de cancelaciones usando la función y los triggers!,
-- lo que vamos a hacer es agregar un pago que tenga una fecha antigua de un pago QUE NO FUE CANCELADO. 
-- Apenas se le haga algún cambio CANCELARÁ POR SISTEMA la solicitud, por NO HABER PAGADO!

-- OJO!
DELETE FROM pago where idPago=3;

-- Haremos que se inserte un pago en las fechas de la solicitud, es decir,
-- si alguien hizo una solicitud hace dos semanas, no es correcto permitir
-- que se agregue un pago de hace 5 semanas.alter
		
        -- Este trigger verifica que la solicitud deba de estar en proceso para agregar un pago
        -- y además, que la fechaDeInicio de la solicitud coincida con la del pago.
					
		DROP TRIGGER IF EXISTS verificarPagos;

		DELIMITER //
		CREATE TRIGGER verificarPagos after INSERT ON pago
		FOR EACH ROW 
		BEGIN
			IF getEstadoSolicitud(new.idSolicitud) != 'enproceso' THEN 
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
			END IF;
			IF NEW.fechaInicio<(SELECT DATE(fechaInicio) FROM solicitud WHERE idSolicitud = new.idSolicitud) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha De inicio de la solicitud no coincide con la del pago';
			END IF;
		END
		// DELIMITER ;
        
	-- Ejemplo: 
	SELECT idSolicitud,estado FROM solicitud where idSolicitud=1;
	-- no podré pagar porque la solicitud está pendiente
	INSERT INTO PAGO (idPago, idSolicitud, estadoDePago, fechaInicio, fechaLimite, fechaDeCancelacion, monto)
	VALUES(null,1,'porpagar',current_date(),current_date()+1,NULL,15000);
    -- FIN EJEMPLO


-- Fecha de la solicitud:
SELECT DATE(fechaInicio) as fechaInicioSolicitud FROM solicitud where idSolicitud=8;

-- No me va a servir por el trigger (verificarPagos el cuál verifica la fechaDeInicio)
INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);

-- Por eso cambiaremos esto a una fecha anterior (3 de abril está antes del día estipulado)
UPDATE solicitud set fechaInicio = '2024-04-03' where idSolicitud = 8;

-- Si lo intento ahora con las mismas fechas (3 de abril)
INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);


-- No se podrá cambiar el estado de pago sin ANTES revisar que ya hayan mandado un recibo de pago ACTIVO!, entonces:

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

-- Ejecutamos:
update pago set estadoDePago = 'pagado' where idPago=3;

-- Inserto el recibo de pago ACTIVO
INSERT into documento(idDocumento,idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
values(NULL,8,'recibodepago','recibo de pago','link','activo');

-- ¿Qué pasa si se vuelve a hacer? Arroja el trigger:

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
			END //		DELIMITER ;


-- PRUEBA:
INSERT into documento(idDocumento,idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
values(NULL,8,'recibodepago','recibo de pago','link','activo');
-- FIN PRUEBA

-- Verifiquemos el estado de la solicitud!
SELECT estado FROM solicitud where idSolicitud=8;

-- NO podemos actualizar el pago porque también se tiene que insertar la fecha de cancelación 
-- antes de cambiar el estado de pago!

	-- Trigger que primero hace que se inserte la fecha de cancelación 
        -- antes de cambiar el estado del pago
		DROP TRIGGER IF EXISTS verificarEstadoPagoUPDATE;

		DELIMITER $$

		CREATE TRIGGER verificarEstadoPagoUPDATE AFTER UPDATE ON PAGO
		FOR EACH ROW

		BEGIN
			IF NEW.estadoDePago = 'Pagado' AND NEW.fechaDeCancelacion IS NULL THEN 
				SIGNAL sqlstate '45000' 
				SET MESSAGE_TEXT = 'Antes de cambiar el estado del pago, debe agregarse la FECHA DE CANCELACIÓN!';
			END IF;
		END

		$$ DELIMITER ; 

update pago set estadoDePago = 'pagado' where idPago=3;

-- NO SE AGREGARÁ LA fecha de cancelación AÚN PORQUE VAMOS A CANCELAR LA SOLICITUD YA QUE ESTO YA SE VENCIÓ
SELECT current_date() as fechaActual,'    >' as '',fechaLimite FROM pago where idSolicitud=8;

-- Se cancelará apenas hagamos un update o algo sobre la tabla de pago!

-- Lo que hará esto es que primero irá a:

        -- Trigger que cambia el estado de la solicitud a CANCELADO cuando esta ya ha pasado de su fecha límite
		DROP TRIGGER IF EXISTS update_estado_limite_fecha;

		DELIMITER //
		CREATE TRIGGER update_estado_limite_fecha BEFORE UPDATE ON pago
		FOR EACH ROW

		BEGIN

			DECLARE id INT;
			SET id = OLD.idSolicitud;
			
			IF OLD.fechaLimite<current_date() AND getEstadoSolicitud(id)='enproceso' THEN
				UPDATE solicitud SET estado='cancelado' WHERE idSolicitud = id;
				
			END IF;
		END // 
		DELIMITER ; 

-- y luego al trigger que inserta en cancelaciones.

		-- Mandar a auditoria cancelaciones (cancelacion) las solicitudes canceladas por el usuario
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

	-- antes
SELECT idSolicitud, estado as estadoAntes FROM solicitud where idSolicitud=8;

-- Actualizamos
Update pago set fechaDeCancelacion = current_date() where idPago=3;

	-- después
SELECT idSolicitud, estado as estadoDespues FROM solicitud where idSolicitud=8;

-- Veamos qué hay en cancelación:
select * from cancelacion; -- la inserción de la cancelación por tipo usuario fue la que se realizó más arriba.



-- /////////////////////////////    PROCESO ESPERADO DE UNA SOLICITUD    /////////////////////////////


-- Un proceso de solicitud exitoso tendrá la siguiente secuencia de Estados:
-- 			pendiente -> en proceso -> completado -> cerrado
-- 		Este proceso a grandes rasgos, se muestra a continuación:

-- TRIGGER QUE NO PERMITE QUE SE INSERTEN USUARIOS CÓMO FUNCIONARIOS!
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
        
        
-- MOSTRAMOS LOS DATOS QUE VAMOS A INSERTAR!
SELECT idUsuario,tipo from usuario WHERE idUsuario IN(1,11);

-- INSERTAMOS Y OCURRE UN ERROR (Se omite la fecha de Inicio y estado 
-- porque están por default en current_date() y PENDIENTE )

INSERT INTO Solicitud (idSolicitud,idUsuario,idFuncionario,idTramite)
VALUES(40,1,11,2);

-- VALOR CORRECTO:
INSERT INTO Solicitud (idSolicitud,idUsuario,idFuncionario,idTramite)
VALUES(40,11,1,2);

-- MOSTRAMOS LA SOLICITUD:
SELECT * from solicitud where idSolicitud=40;

-- Ahora cambiaremos el estado a 'En proceso'. Esto ocurre cuando apenas se inserte un comentario 
-- (o si lo actualiza el mismo funcionario)

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

-- Mostramos el estado antes de ingresar un comentario
SELECT idSolicitud,estado FROM solicitud where idSolicitud =40;

-- Insertamos el comentario y...
INSERT INTO COMENTARIO (idComentario,idSolicitud,idUsuario,comentarioAnterior,mensaje,fechaYhora)
VALUES(90,40,11,null,'hola',now());

-- Cambia el estado!
SELECT idSolicitud,estado FROM solicitud where idSolicitud =40;

-- PRUEBA

	-- Miremos quienes son los distintos USUARIOS de la solicitud 3
		SELECT DISTINCT(idUsuario) FROM comentario where idSOlicitud=3;
		
		
	-- No puedo agregar un comentario de otra persona que no sea de la solicitud
		INSERT INTO COMENTARIO (idComentario, idSolicitud, idUsuario, comentarioAnterior, mensaje, fechaYhora)
		VALUES(NULL,3,20,1,'esta es una prueba',now());
    
-- FIN PRUEBA
    

-- Imaginemos que se hace las consultas, se solicitan documentos y demás... , entonces cuando el Funcionario envíe el
-- documento tramitado, la solicitud se completará MÁS NO se cerrará.

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

-- Revisar estado antes de..
SELECT idSolicitud,estado FROM solicitud WHERE idSolicitud=40;

-- Se inserta el doc SOLICITADO
INSERT INTO DOCUMENTO VALUES (40,40,'Solicitado','Documento Solicitado','http://linkDOCUMENTO.com','activo');

-- Revisar estado después del trigger
SELECT idSolicitud,estado FROM solicitud WHERE idSolicitud=40;

-- Por último, si el funcionario cierra por su cuenta la solicitud: 
UPDATE solicitud SET ESTADO = 'cerrado' WHERE idSolicitud=40;

-- Claramente cambiará el estado, pero...
SELECT idSolicitud,estado FROM solicitud WHERE idSolicitud=40;

-- Púesto que la solicitud está cerrada el usuario NO PODRÁ ENVIAR MÁS COMENTARIOS
-- Eso es gracias al siguiente trigger:

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

-- PRUEBA: -- SI NO FUNCIONA, DEBES CREAR LA FUNCIÓN getEstadoSolicitud() que está más arriba
INSERT INTO comentario (idComentario,idSolicitud,idUsuario,comentarioAnterior,mensaje,fechaYhora)
VALUES(91,40,11,90,'AYUDAAAA',NOW());
INSERT INTO comentario (idComentario,idSolicitud,idUsuario,comentarioAnterior,mensaje,fechaYhora)
VALUES(92,40,11,91,'NOOOOO',NOW());



-- /////////////////////////////    PROCEDURES    /////////////////////////////




		-- Cambiar el estado de un determinado Documento:
		
        DROP PROCEDURE IF EXISTS cambiarEstadoDoc;

		DELIMITER // 
		CREATE PROCEDURE cambiarEstadoDoc(IN idDoc INT) 
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

		-- Muestra del procedimiento:
		SELECT idDocumento,estadoDocumento AS 'estado ANTES' FROM documento Where idDocumento=9;
        
		CALL CambiarEstadoDoc(9);
        
		SELECT idDocumento,estadoDocumento as 'estado Después'FROM documento Where idDocumento=9; 

		
        -- Procedimiento que revisa los Recibos De Pago Activos de una SOLICITUD:
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

-- PRUEBA BUSCAR LOS RECIBOS ACTIVOS DE LA SOLICITUD 12
CALL reciboActivo(12);


-- SI NO HAY RECIBOS ACTIVOS DE LA SOLICITUD 2
SELECT idSolicitud,tipoDocumento,estadoDocumento from documento where idSolicitud=2;

-- ENTONCES ARROJARÁ UN ERROR.
CALL reciboActivo(2);

-- Y si hay recibos pero no están activos?
INSERT INTO documento(idDocumento, idSolicitud, tipoDocumento, tituloDocumento, linkDocumento, estadoDocumento)
VALUES(1000000,2,'reciboDePago','a','a','inactivo');

CALL reciboActivo(2); -- No los llama!


-- Procedimiento para generar un recibo de pago de una determinada solicitud.

		DROP PROCEDURE IF EXISTS generarReciboDePago;
        
		DELIMITER // 
		CREATE PROCEDURE generarReciboDePago (IN laSolicitud INT)
		BEGIN

			IF laSolicitud NOT IN(SELECT idSolicitud FROM pago) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='No es posible generar un recibo de pago si no existe en la base de datos.';
			ELSE 
				SELECT p.idSolicitud as 'Solicitud #', p.idPago as 'NÚMERO DE PAGO', p.fechaInicio as 'Plazo Mínimo',
						p.fechaLimite as 'Plazo Máximo', p.monto
						FROM pago p
						Where idSolicitud = laSolicitud;
			END IF;
			
		END
		// DELIMITER ;

-- VER LOS RECIBOS DE PAGO
CALL generarReciboDePago(4);

-- ESTE GENERARÁ ERROR:
CALL generarReciboDePago(1);

-- /////////////////////////////    VIEWS    /////////////////////////////

		-- Solicitudes próximas a vencer por NO PAGAR:
		DROP VIEW IF EXISTS solicitudesProximasAVencer;

		CREATE VIEW solicitudesProximasAVencer AS

		SELECT s.idSolicitud as 'Solicitudes Próximas a Vencer',
		p.fechaInicio, p.fechaLimite, p.fechaLimite-current_date() as
		'Días restantes'
		FROM solicitud s
		JOIN PAGO P USING (idSolicitud)
		WHERE p.estadoDePago='PorPagar'
		AND p.fechaLimite-current_date() BETWEEN 0 AND 3;

-- Resultados:
SELECT * FROM solicitudesProximasAVencer;
