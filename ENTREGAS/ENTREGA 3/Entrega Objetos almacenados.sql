
-- /////////////////////////////    TRIGGERS    /////////////////////////////




-- /////////////////////////////    FUNCTIONS    /////////////////////////////


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
SELECT idDocumento,tituloDocumento,estadoDocumento FROM documento Where idDocumento=9;
CALL CambiarEstadoDoc(9);
SELECT idDocumento,tituloDocumento,estadoDocumento FROM documento Where idDocumento=9; 

-- Muestra de funcionamiento de triggers: 
SELECT idDocumento,tituloDocumento,estadoDocumento FROM documento Where idDocumento=10; -- No puedo cambiar esto porque...!
--  DESCOMENTAR : 
-- CALL CambiarEstadoDoc(10);



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
// DELIMITER 

-- DESCOMENTAR PARA VER LOS RECIBOS DE PAGO
-- CALL generarReciboDePago(4);

-- ESTE GENERARÁ ERROR:
-- CALL generarReciboDePago(1);


-- VIEWS 

-- Solicitudes próximas a vencer por NO PAGAR:
DROP VIEW IF EXISTS solicitudesProximasAVencer;

CREATE VIEW solicitudesProximasAVencer AS

SELECT s.idSolicitud as 'Solicitudes Próximas a Vencer',
p.fechaInicio, p.fechaLimite, p.fechaLimite-current_date() as
'Días restantes'
FROM solicitud s
JOIN PAGO P USING (idSolicitud)
WHERE p.estadoDePago='Por Pagar'
AND p.fechaLimite-current_date() BETWEEN 0 AND 3;

-- Resultados (DESCOMENTAR);
--SELECT * FROM solicitudesProximasAVencer;


CREATE VIEW SolicitudesPorFuncionario AS(
	SELECT s.idFuncionario, u.nombre, u.apellido,
	CONCAT(CAST(COUNT(s.idFuncionario) AS CHAR)," solicitudes") AS Gestiona
	FROM solicitud AS s INNER JOIN usuario AS u 
    ON s.idFuncionario = u.idUsuario 
    GROUP BY s.idFuncionario);
