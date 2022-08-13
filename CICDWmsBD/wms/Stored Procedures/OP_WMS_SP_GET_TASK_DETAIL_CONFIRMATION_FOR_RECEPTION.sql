-- =============================================
-- Autor:                 marvin.solares
-- Fecha de Creacion:   2018-06-11 @ GForce@Dinosaurio
-- Description:          SP que obtiene el detalle de las recepciones desde una tarea.


-- Autor:                 marvin.solares
-- Fecha de Creacion:   20180718 GForce@FocaMonje
-- Description:          Se modifica sp para que soporte ver 

-- Autor:                 marvin.solares
-- Fecha de Creacion:   20180823 GForce@Humano
-- Description:          Se modifica para que pueda agrupar la licencia cuando vienen series

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Descripcion:			agrego lote y fecha de expiracion en la consulta

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_TASK_DETAIL_CONFIRMATION_FOR_RECEPTION]
          @SERIAL_NUMBER = 557849          
		EXEC [wms].[OP_WMS_SP_GET_TASK_DETAIL_CONFIRMATION_FOR_RECEPTION]
          @SERIAL_NUMBER = 13386
		  SELECT * FROM [wms].OP_WMS_TASK_LIST where serial_number = 557849
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASK_DETAIL_CONFIRMATION_FOR_RECEPTION] (@SERIAL_NUMBER INT)
AS
SELECT DISTINCT * FROM (
SELECT
	[TR].[MATERIAL_CODE] AS [MATERIAL_ID]
	,[TR].[QUANTITY_UNITS] [QTY]
	,[TR].[LOGIN_ID] [ASSIGNED_TO]
	,[TR].[LICENSE_ID] [LICENSE_ID]
	,[TR].[TASK_ID] [SERIAL_NUMBER]
	,[M].[MATERIAL_NAME]
	,[TR].[BATCH]
	,[TR].[DATE_EXPIRATION]
FROM
	[wms].[OP_WMS_TRANS] [TR]
INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [TR].[MATERIAL_CODE] = [M].[MATERIAL_ID]
WHERE
	[TR].[TASK_ID] = @SERIAL_NUMBER
	AND [TR].[STATUS] = 'PROCESSED'
	AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
	AND [TR].[SERIAL] IS NULL
UNION ALL
SELECT
	[TR].[MATERIAL_CODE] AS [MATERIAL_ID]
	,SUM([TR].[QUANTITY_UNITS]) [QTY]
	,[TR].[LOGIN_ID] [ASSIGNED_TO]
	,[TR].[LICENSE_ID] [LICENSE_ID]
	,[TR].[TASK_ID] [SERIAL_NUMBER]
	,[M].[MATERIAL_NAME]
	,MAX([TR].[BATCH])
	,MAX([TR].[DATE_EXPIRATION])
FROM
	[wms].[OP_WMS_TRANS] [TR]
INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [TR].[MATERIAL_CODE] = [M].[MATERIAL_ID]
WHERE
	[TR].[TASK_ID] = @SERIAL_NUMBER
	AND [TR].[STATUS] = 'PROCESSED'
	AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
	AND [TR].[SERIAL] IS NOT NULL
GROUP BY
	[TR].[MATERIAL_CODE]
	,[TR].[LOGIN_ID]
	,[TR].[LICENSE_ID]
	,[TR].[TASK_ID]
	,[M].[MATERIAL_NAME]) AS T;