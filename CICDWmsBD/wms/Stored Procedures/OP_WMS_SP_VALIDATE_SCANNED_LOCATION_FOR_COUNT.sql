-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Valida si una ubicación es correcta 




/*
-- Ejemplo de Ejecucion:
  EXEC	[wms].[OP_WMS_SP_VALIDATE_SCANNED_LOCATION_FOR_COUNT] @LOGIN = 'ACAMACHO' , @TASK_ID = 7 , @LOCATION = 'B02-P01-F01-NU'
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [OWPCD]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_SCANNED_LOCATION_FOR_COUNT] (@LOGIN VARCHAR(25)
, @TASK_ID INT
, @LOCATION VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @RESULT VARCHAR(200)  = 'Ubicación escaneada no válida.'
  DECLARE @CODIGO INT = -1
  SELECT
  TOP 1 
    @RESULT = 
    CASE 
    WHEN [H].[STATUS] = 'CANCELED' THEN 'La tarea ha sido cancelada.'
    WHEN [D].[STATUS] = 'COMPLETED' THEN 'La ubicación ya ha sido contada, ¿Desea recontar?'
    ELSE 'OK'
    END  
    , @CODIGO = 
    CASE 
    WHEN [H].[STATUS] = 'CANCELED' THEN 0
    WHEN [D].[STATUS] = 'COMPLETED' THEN 1
    ELSE 2
    END 
  FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
  INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H]
    ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
  WHERE [D].[ASSIGNED_TO] = @LOGIN
  AND [H].[TASK_ID] = @TASK_ID
  AND [D].[LOCATION] = @LOCATION  

   SELECT
      1 AS Resultado
     ,@RESULT Mensaje
     ,@CODIGO Codigo
     ,CAST('' AS VARCHAR) DbData


END