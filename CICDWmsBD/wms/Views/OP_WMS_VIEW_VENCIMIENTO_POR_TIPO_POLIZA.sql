﻿



CREATE VIEW [wms].[OP_WMS_VIEW_VENCIMIENTO_POR_TIPO_POLIZA]
AS

SELECT P.DOC_ID
	, P.CODIGO_POLIZA
	, P.NUMERO_ORDEN
	, C.CLIENT_NAME
	, T.ACUERDO_COMERCIAL_NOMBRE
	, P.FECHA_LLEGADA
	, p.REGIMEN
	, dateadd(day, NUMERIC_VALUE, FECHA_LLEGADA) AS VALIN_TO
	, case 
		when datediff(day, GETDATE(), dateadd(day, NUMERIC_VALUE, FECHA_LLEGADA)) <= 0 THEN 0		
		ELSE datediff(day, GETDATE(), dateadd(day, NUMERIC_VALUE, FECHA_LLEGADA))
	   END AS DAYS_REMAINING
	--, datediff(day, GETDATE(), dateadd(day, NUMERIC_VALUE, FECHA_LLEGADA)) AS DAYS_REMAINING
FROM [wms].OP_WMS_POLIZA_HEADER P
	INNER JOIN [wms].OP_WMS_CONFIGURATIONS ON PARAM_NAME = REGIMEN
	INNER JOIN [wms].OP_WMS_TARIFICADOR_HEADER T ON ACUERDO_COMERCIAL_ID = ACUERDO_COMERCIAL
	INNER JOIN [wms].OP_WMS_VIEW_CLIENTS C ON P.CLIENT_CODE = C.CLIENT_CODE
WHERE PARAM_GROUP = 'REGIMEN'
AND TIPO = 'INGRESO'
AND PARAM_TYPE = 'WMS3PL'
AND WAREHOUSE_REGIMEN = 'FISCAL'