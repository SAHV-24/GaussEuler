
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

-- --------------------------------------------------------------

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
