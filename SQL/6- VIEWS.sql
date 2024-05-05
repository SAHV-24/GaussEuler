-- Solicitudes próximas a vencer:
DROP VIEW IF EXISTS solicitudesProximasAVencer;

CREATE VIEW solicitudesProximasAVencer AS

SELECT s.idSolicitud as 'Solicitudes Próximas a Vencer',
p.fechaInicio, p.fechaLimite, p.fechaLimite-current_date() as
'Días restantes'
FROM solicitud s
JOIN PAGO P USING (idSolicitud)
WHERE p.estadoDePago='Por Pagar'
AND p.fechaLimite-current_date()BETWEEN 0 AND 3;

-- Vista de Solicitudes por Funcionario

DROP VIEW IF EXISTS solicitudesPorFUncionario;

CREATE VIEW SolicitudesPorFuncionario AS
	SELECT s.idFuncionario, u.nombre, u.apellido,
	CONCAT(CAST(COUNT(s.idFuncionario) AS CHAR), " solicitudes") AS Gestiona
	FROM solicitud AS s INNER JOIN usuario AS u 
    ON s.idFuncionario = u.idUsuario 
    GROUP BY s.idFuncionario;

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
