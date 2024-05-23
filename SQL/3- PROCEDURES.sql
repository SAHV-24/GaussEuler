
-- Procedimientos para llamar a tablas:
DROP PROCEDURE IF EXISTS u;
DELIMITER // 
CREATE PROCEDURE u()
SELECT * FROM usuario;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS s;
DELIMITER // 
CREATE PROCEDURE s()
SELECT * FROM solicitud;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS t;
DELIMITER // 
CREATE PROCEDURE t()
SELECT * FROM tramite;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS c;
DELIMITER // 
CREATE PROCEDURE c()
SELECT * FROM comentario;
// DELIMITER ; 


DROP PROCEDURE IF EXISTS n;
DELIMITER // 
CREATE PROCEDURE n()
SELECT * FROM normativa;
// DELIMITER ; 

DROP PROCEDURE IF EXISTS p;
DELIMITER // 
CREATE PROCEDURE p()
SELECT * FROM pago;
// DELIMITER ; 

DROP PROCEDURE IF EXISTS d;
DELIMITER // 
CREATE PROCEDURE d()
SELECT * FROM documento;
// DELIMITER ; 


-- Seleccionar pago por ID de la solicitud
DROP procedure if exists estadoDePago;
DELIMITER // 
	CREATE PROCEDURE estadoDePago (in elID INT)
	BEGIN
	SELECT elId, idSolicitud, estadoDePago FROM pago WHERE idSolicitud=elID;
	END;
// DELIMITER ;                                      

-- Cambiar el estado de un determinado Documento:
DROP PROCEDURE IF EXISTS cambiarEstadoDocumento;

DELIMITER // 
CREATE PROCEDURE cambiarEstadoDocumento(IN idDoc INT) 
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

-- Procedimiento para saber cuál es el trámite que se está realizando: 

DROP PROCEDURE IF EXISTS tramiteDesolicitud;

DELIMITER // 
CREATE PROCEDURE tramiteDeSolicitud(IN laIdSolicitud INT)
BEGIN

	SELECT t.nombre,t.costo,t.linkPlantilla,u.extension, u.nombreUnidad,u.extension
    FROM TRAMITE t JOIN SOLICITUD USING(idTramite)
    JOIN unidad u USING(idUnidad)
    WHERE idsolicitud=laIdSolicitud;

END;

// DELIMITER ; 


DROP PROCEDURE IF EXISTS generarReciboDePago;
DELIMITER // 
CREATE PROCEDURE generarReciboDePago (IN laSolicitud INT)
BEGIN

	IF laSolicitud NOT IN(SELECT idSolicitud FROM pago) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='No es posible generar un recibo de pago si no existe en la base de datos.';
	ELSE 
    	SELECT p.idSolicitud as idSolicitud, p.idPago as numPago, p.fechaInicio as plazoMinimo,
				p.fechaLimite as plazoMaximo, p.monto
				FROM pago p
				Where idSolicitud = laSolicitud;
    END IF;
    
END
// DELIMITER 

