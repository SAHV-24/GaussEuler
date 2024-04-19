-- Para el número de solicitudes de cada trámite por cada estado
SELECT t.nombre AS Solicitud, s.estado AS Estado, COUNT(s.idSolicitud) AS Cantidad
FROM tramite AS t 
INNER JOIN solicitud AS s USING(idTramite)
GROUP BY t.nombre, s.estado;

-- Promedio de costo y número de trámites por unidad
SELECT u.nombreUnidad AS Unidad, round(AVG(t.costo), 2) AS Costo, COUNT(u.idUnidad) AS CantidadTramites
FROM tramite AS t INNER JOIN unidad AS u USING(idUnidad)
GROUP BY idUnidad;

-- Funcionarios por número de solicitudes que gestiona
SELECT s.idFuncionario, u.nombre, u.apellido, CONCAT(CAST(COUNT(s.idFuncionario) AS CHAR), " solicitudes") AS Gestiona 
FROM solicitud AS s INNER JOIN usuario AS u ON s.idFuncionario = u.idUsuario GROUP BY s.idFuncionario;

-- Cantidad de solicitudes por tipo de usuario
(SELECT u.tipo, COUNT(*) AS Cantidad
FROM solicitud s
INNER JOIN usuario u ON s.idUsuario = u.idUsuario
GROUP BY u.tipo)
UNION
(SELECT 'Total', COUNT(idSolicitud) FROM solicitud);

-- Numero de solicitudes en proceso por cada usuario no administrativo
SELECT nombre, apellido,
  (SELECT COUNT(*)
   FROM solicitud AS s
   WHERE s.idUsuario = u.idUsuario
   AND s.estado = 'en proceso') AS SolicitudesxUsuario
FROM usuario AS u WHERE u.tipo != 'Administrativo';