-- Solicitudes próximas a vencer:
DROP VIEW IF EXISTS solicitudesProximasAVencer;

CREATE VIEW solicitudesProximasAVencer AS

SELECT s.idSolicitud as 'Solicitudes Próximas a Vencer',
p.fechaInicio, p.fechaLimite, p.fechaLimite-current_date() as
'Días restantes'
FROM solicitud s
JOIN PAGO P USING (idSolicitud)
WHERE p.estadoDePago='PorPagar'
AND p.fechaLimite-current_date()BETWEEN 0 AND 3;

-- Solicitudes por tipo de Usuario:

DROP VIEW IF EXISTS solicitudesPorUsuario;
CREATE VIEW solicitudesPorUsuario AS (
	(SELECT u.tipo, COUNT(*) AS Cantidad
	FROM solicitud s
	INNER JOIN usuario u ON s.idUsuario = u.idUsuario
	GROUP BY u.tipo)
UNION
	(SELECT 'Total', COUNT(idSolicitud) FROM solicitud)
    );
