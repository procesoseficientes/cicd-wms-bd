-- =============================================
-- Modificacion:					hector.gonzalez
-- Fecha de Creacion: 		28-10-2016 @ A-TEAM SRINT 4
-- Description:			      Se agrego un union a la tabla de OP_WMS_SERVICE

/*
-- Ejemplo de Ejecucion:
		--
		SELECT * FROM [wms].OP_WMS_VIEW_SERVICES
*/
-- =============================================
CREATE VIEW [wms].OP_WMS_VIEW_SERVICES
AS
SELECT
  SERVICE_CODE
 ,[SERVICE_NAME]
FROM SERVICES_SAP
UNION
SELECT
  ows.SERVICE_CODE
 ,ows.SERVICE_DESCRIPTION
FROM [wms].OP_WMS_SERVICE ows