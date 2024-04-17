
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
