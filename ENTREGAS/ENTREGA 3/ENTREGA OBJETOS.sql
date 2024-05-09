-- /////////////////////////////    TRIGGERS PARA ASEGURAR LAS RELACIONES EN LA BASE DE DATOS   /////////////////////////////




-- /////////////////////////////    PROCESO 1   /////////////////////////////






-- /////////////////////////////    PROCESO 2    /////////////////////////////

-- MOSTRAREMOS TODAS LAS FUNCIONES Y SU USO PARTICULAR EN UN EJEMPLO DE UNA MALA
-- 				GESTIÓN DE UN PAGO!

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
        
        -- FUNCIÓN 2 QUE SE USA TAMBIÉN!
				
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
			IF getEstadoSolicitud(new.idSolicitud) != 'enproceso' THEN 
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
		-- Mandar a auditoria las solicitudes canceladas por el usuario
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


	-- Esta fecha aún no se ha vencido!
	-- SELECT fechaLimite FROM pago where idSolicitud=4;
	-- SELECT verificarFecha (4);

	-- Proceso para CANCELACIONES y auditoria de cancelaciones usando la función y los triggers!,
	-- lo que vamos a hacer es agregar  un pago que tenga una fecha antigua de pago QUE NO FUE CANCELADO. 
	-- Apenas se le haga algún cambio CANCELARÁ POR SISTEMA la solicitud, por NO HABER PAGADO!

	DELETE FROM pago where idPago=3;
	-- No me va a servir por el trigger de...
	INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);

	UPDATE solicitud set fechaInicio = '2024-04-03' where idSolicitud = 8;

	-- Si lo intento ahora..
	INSERT INTO pago VALUES(3,8,'PorPagar','2024-04-03','2024-04-27',NULL,15000);

	-- Muestra del trigger para que sólo se cambie el estado de pago si hay un recibo de pago activo!
	update pago set estadoDePago = 'pagado' where idPago=3;

	-- Inserto el documento
	INSERT into documento(idDocumento,idSolicitud,tipoDocumento,tituloDocumento,linkDocumento,estadoDocumento) 
	values(NULL,8,'recibodepago','recibo de pago','link','activo');

	-- Verifiquemos el estado de la solicitud!
	SELECT estado FROM solicitud where idSolicitud=8;

	-- NO ME VA A DEJAR!
	update pago set estadoDePago = 'pagado' where idPago=3;

	-- Entonces, como ya establecimos más arriba, cancelará la solicitud por el UPDATE PAGO que está más abajo!
	
		-- antes
	SELECT idSolicitud, estado FROM solicitud where idSolicitud=8;

	Update pago set fechaDeCancelacion=current_date() where idPago=3;

		-- después
	SELECT idSolicitud, estado FROM solicitud where idSolicitud=8;
	select * from cancelacion;

	-- fin



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
		SELECT idDocumento,estadoDocumento,tituloDocumento FROM documento Where idDocumento=9;
		CALL CambiarEstadoDoc(9);
		SELECT idDocumento,estadoDocumento,tituloDocumento FROM documento Where idDocumento=9; 

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

-- ERROR: 
SELECT idSolicitud,tipoDocumento,estadoDocumento from documento where idSolicitud=2;
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
