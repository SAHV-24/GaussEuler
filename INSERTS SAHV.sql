-- Buscar las solictudes que estén prontas a vencer (menos de 3 días)

SELECT s.idSolicitud as 'Solicitudes Próximas a Vencer', p.fechaInicio, p.fechaLimite
FROM solicitud s
JOIN PAGO P
USING (idSolicitud) WHERE p.estadoDePago='Por Pagar'
 AND current_date()-p.fechaLimite BETWEEN 0 AND 3;
SELECT * FROM PAGO;

-- Buscar el estudiante que más solicitudes ha realizado
SELECT  u.idUsuario,u.nombre, u.apellido, u.correoElectronico, t.cant AS 'Cantidad Máxima'
FROM usuario u
join (SELECT idUsuario , COUNT(*) as cant
FROM solicitud s 
JOIN usuario u USING(idUsuario) 
WHERE u.tipo = 'estudiante'
GROUP BY (idUsuario)) as t
using(idUsuario) WHERE t.cant=(
	SELECT MAX(cant) FROM (select  COUNT(*) as cant
FROM solicitud s 
JOIN usuario u USING(idUsuario) 
WHERE u.tipo = 'estudiante'
GROUP BY (idUsuario)) as t
)
;
-- Buscar el trámite más solicitado 
SELECT tr.idTramite as'Trámite más solicitado',tr.nombre,tr.descripcion,t.cant as 'Cantidad Máxima'
from tramite tr 
JOIN (SELECT idTramite,COUNT(*) as cant
FROM solicitud 
JOIN tramite USING(idtramite)
GROUP BY(idTramite)) as t using(idTramite)
WHERE t.cant=(SELECT MAX(cant) 
	FROM (SELECT idTramite,COUNT(*) as cant
			FROM solicitud 
			JOIN tramite USING(idtramite)
			GROUP BY(idTramite)
) AS t
)
;
--
-- Calcular el promedio de tiempo que tarda cada usuario en completar una solicitud:

SELECT u.idUsuario,u.nombre,u.apellido,u.correoElectronico, 
	ROUND((Sum(p.fechaDeCancelacion)-SUM(p.fechaInicio))/COUNT(*)) as 'Días en pagar un trámite'
	From pago p  
	JOIN solicitud s USING(idSolicitud)
	JOIN usuario u USING(idUsuario)
	Where p.fechaInicio IS NOT NULL 
	AND estadoDePago='Pagado'
    GROUP BY(idUsuario);

-- Probabilidad de que un tramite quede en (Completado,enProceso,pendiente)
SELECT estado,CONCAT(CAST(ROUND(((t2.cant/total)*100),2) AS CHAR),'%') as 'Proporción de tramites' FROM(
SELECT SUM(cant) as total FROM(
		SELECT ESTADO,COUNT(*) as cant
		FROM DOCUMENTO 
		JOIN SOLICITUD 
		USING(IDSOLICITUD) 
		JOIN USUARIO USING(IDUSUARIO) 
		group by(estado)
		) 
	AS t) as t1,
    (
		SELECT ESTADO,COUNT(*) as cant
		FROM DOCUMENTO 
		JOIN SOLICITUD 
		USING(IDSOLICITUD) 
		JOIN USUARIO USING(IDUSUARIO) 
		group by(estado)
	) AS t2;
    