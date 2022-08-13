-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Valida si una ubicación es correcta 




/*
-- Ejemplo de Ejecucion:
  EXEC	[wms].[OP_WMS_SP_VALIDATE_RECOUNTED_MATERIAL_FOR_TASK] @LOGIN = 'ACAMACHO' , @TASK_ID = 8 , @LOCATION = 'B01-R01-C01-NB'
  , @LICENCE_ID  = 127680
, @MATERIAL_ID = 'C00030/LECH-CONDEN'
, @BATCH = '281617'
, @SERIAL = 'GDR007'
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [OWPCD]
    SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [OWPCE]

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_RECOUNTED_MATERIAL_FOR_TASK] (@LOGIN VARCHAR(25)
, @TASK_ID INT
, @LOCATION VARCHAR(50)
, @LICENCE_ID INT
, @MATERIAL_ID VARCHAR(50)
, @BATCH VARCHAR(50) = NULL
, @SERIAL VARCHAR(50) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @RESULT VARCHAR(200) = 'No se encontró información para este material.'
  DECLARE @CODIGO INT = -1
  DECLARE @QTY NUMERIC(18, 4) = 0
  SELECT
  TOP 1
    @RESULT =
             CASE
               WHEN [E].[PHYSICAL_COUNTS_EXECUTION_ID] IS NULL THEN 'OK'
               ELSE 'Material ya ha sido contado.'
             END
   ,@CODIGO =
             CASE
               WHEN [E].[PHYSICAL_COUNTS_EXECUTION_ID] IS NULL THEN 1
               ELSE -1
             END
   ,@QTY = ISNULL([E].[QTY_SCANNED], 0)
  FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
  INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H]
    ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
  LEFT JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [E]
    ON ([E].[PHYSICAL_COUNT_DETAIL_ID] = [D].[PHYSICAL_COUNT_DETAIL_ID]
    AND [E].[LICENSE_ID] = @LICENCE_ID
    AND [E].[MATERIAL_ID] = @MATERIAL_ID
    AND [E].[LOCATION] = @LOCATION
    AND [E].[EXECUTED_BY] = @LOGIN
    AND (@BATCH IS NULL
    OR @BATCH = [E].[BATCH])
    AND (@SERIAL IS NULL)
    )
  WHERE [D].[ASSIGNED_TO] = @LOGIN
  AND [H].[TASK_ID] = @TASK_ID
  AND [D].[LOCATION] = @LOCATION


  SELECT
    1 AS Resultado
   ,@RESULT Mensaje
   ,@CODIGO Codigo
   ,CAST(@QTY AS VARCHAR) DbData


END