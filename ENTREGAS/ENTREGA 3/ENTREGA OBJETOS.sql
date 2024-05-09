-- /////////////////////////////    TRIGGERS PARA ASEGURAR LAS RELACIONES EN LA BASE DE DATOS   /////////////////////////////





-- /////////////////////////////    PROCESO DE CANCELACIÓN    /////////////////////////////



-- MOSTRAREMOS TODAS LAS FUNCIONES Y SU USO PARTICULAR EN UN EJEMPLO DE UNA MALA
-- 				GESTIÓN DE UN PAGO Y UNA CANCELACIÓN DE SOLICITUD POR SISTEMA!

-- Función que muestra si una solicitud ya se venció por su fecha,
-- esto sirve para el trigger de auditoría de cancelaciones, en caso tal de que un usuario
-- SE LE HAYA VENCIDO EL PAGO

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
        
        
        -- FUNCIÓN 2 QUE SE SE USA EN LOS TRIGGERS!
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


		-- TRIGGER 1
		-- TRIGGER QUE SIRVEN SÓLO PARA CANCELAR UN PEDIDO DE UN PAGO!
		DROP TRIGGER IF EXISTS verificarPagos;

		DELIMITER //
        
		CREATE TRIGGER verificarPagos after INSERT ON pago
		FOR EACH ROW 
		BEGIN
        
			IF getEstadoSolicitud(new.idSolicitud) != 'enproceso' THEN -- AQUI USAMOS LA FUNCIÓN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes ingresar un pago a una solicitud que no está en proceso!';
			END IF;
			IF NEW.fechaInicio<(SELECT DATE(fechaInicio) FROM solicitud WHERE idSolicitud = new.idSolicitud) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha De inicio de la solicitud no coincide con la del pago';
			END IF;
            
		END
		// DELIMITER ;


		-- TRIGGER 2
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

		-- TRIGGER 3
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


		-- TRIGGER 4
        -- Sirve para cambiar el estado de la solicitud a cancelado cuando esta ya ha pasado de su fecha límite
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

		-- TRIGGER 5 -- AUDITORIA CANCELACIONES: 
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
        
        -- TRIGGER 6
                
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

-- Proceso para CANCELACIONES y auditoría de cancelaciones usando la función y los triggers!,
-- lo que vamos a hacer es agregar un pago que tenga una fecha antigua de un pago QUE NO FUE CANCELADO. 
-- Apenas se le haga algún cambio CANCELARÁ POR SISTEMA la solicitud, por NO HABER PAGADO!

-- OJO!
DELETE FROM pago where idPago=3;

-- No me va a servir por el trigger 1
INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);

-- Esa fecha es:

	SELECT DATE(fechaInicio) as fechaInicioSolicitud FROM solicitud where idSolicitud=8;

-- Por eso cambiaremos esto a una fecha anterior (3 de abril está antes del 27 de abril)
UPDATE solicitud set fechaInicio = '2024-04-03' where idSolicitud = 8;

-- Si lo intento ahora..
INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);

-- Muestra del trigger 2 para que sólo se cambie el estado de pago si hay un recibo de pago activo!
update pago set estadoDePago = 'pagado' where idPago=3;

-- Inserto el recibo de pago ACTIVO
INSERT into documento(idDocumento,idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
values(NULL,8,'recibodepago','recibo de pago','link','activo');

-- Qué pasa si lo vuelvo a hacer? Arroja el trigger 6!
INSERT into documento(idDocumento,idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
values(NULL,8,'recibodepago','recibo de pago','link','activo');

-- Verifiquemos el estado de la solicitud!
SELECT estado FROM solicitud where idSolicitud=8;

-- NO ME VA A DEJAR POR EL TRIGGER 3!
update pago set estadoDePago = 'pagado' where idPago=3;


-- Entonces, como ya establecimos más arriba, cancelará la solicitud por el UPDATE PAGO que está más abajo!
	-- antes
SELECT idSolicitud, estado FROM solicitud where idSolicitud=8;

-- Lo que hará esto es que primero irá al trigger 4 y luego al trigger 5.
Update pago set fechaDeCancelacion = current_date() where idPago=3;

	-- después
SELECT idSolicitud, estado FROM solicitud where idSolicitud=8;

-- Veamos qué hay en cancelación:
select * from cancelacion;





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

-- Ahora cambiaremos el estado a 'En proceso', esto ocurre cuando apenas se inserte un comentario 
-- (o si lo actualiza el mismo funcionario)

		-- TRIGGER QUE CUANDO SE INGRESE UN COMENTARIO SE CAMBIE EL ESTADO A 'En proceso'

		DROP TRIGGER IF EXISTS Comentario_en_proceso;

		DELIMITER || 
		CREATE TRIGGER Comentario_en_proceso BEFORE INSERT ON comentario
		FOR EACH ROW

		BEGIN
		 
			IF new.idSolicitud NOT IN (SELECT idSolicitud FROM comentario) 
			AND getEstadoSolicitud(NEW.idSolicitud) = 'pendiente' THEN
				UPDATE solicitud SET estado = 'enproceso' WHERE idSolicitud=NEW.idSolicitud;
			END IF;
			
		END
		|| DELIMITER ; 

-- Mostramos los estados antes de ingresar un comentario
SELECT estado FROM solicitud where idSolicitud =40;

-- Insertamos el comentario y...
INSERT INTO COMENTARIO (idComentario,idSolicitud,idUsuario,comentarioAnterior,mensaje,fechaYhora)
VALUES(90,40,11,null,'hola',now());

-- Cambia el estado!
SELECT estado FROM solicitud where idSolicitud =40;

-- Imaginemos que se hace las consultas, se solicitan documentos y demás... , entonces cuando ya el Funcionario envíe el
-- documento tramitado, la solicitud se completará MÁS NO se cancelará.

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

-- Se inserta el doc  SOLCIITADO
INSERT INTO DOCUMENTO VALUES (40,40,'Solicitado','Documento Solicitado','http://linkDOCUMENTO.com','activo');

-- Revisar estado después del trigger
SELECT idSolicitud,estado FROM solicitud WHERE idSolicitud=40;

-- Por último, si el funcionario realiza la siguiente acción: 
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

-- PRUEBA: 
INSERT INTO comentario (idComentario,idSolicitud,idUsuario,comentarioAnterior,mensaje,fechaYhora)
VALUES(91,40,11,90,'AYUDAAAA',NOW());




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
		SELECT idDocumento,estadoDocumento FROM documento Where idDocumento=9;
        
		CALL CambiarEstadoDoc(9);
        
		SELECT idDocumento,estadoDocumento FROM documento Where idDocumento=9; 

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

-- PRUEBA:
CALL reciboActivo(12);


-- NO HAY RECIBOS ACTIVOS 
SELECT idSolicitud,tipoDocumento,estadoDocumento from documento where idSolicitud=2;

-- ENTONCES ARROJARÁ UN ERROR.
CALL reciboActivo(2);


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
