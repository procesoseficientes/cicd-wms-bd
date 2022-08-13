-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-18 @ Team ERGON - Sprint EPONA
-- Description:	 Validar si la ubicación  en la columna [ALLOW_REALLOC]  de OP_WMS_SHELF_SPOTS es 1. de no ser asi retornar error. 


/*
-- Ejemplo de Ejecucion:
    DECLARE  @pResult VARCHAR(250) 
			exec [wms].[OP_WMS_SP_VALIDATE_LICENSE_FOR_REALLOC_PARTIAL] @LICENSE_ID = 217709
                                                        ,@pResult = @pResult OUTPUT 
    SELECT @pResult
  SELECT *   FROM [wms].[OP_WMS_SHELF_SPOTS] [S] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LICENSE_FOR_REALLOC_PARTIAL] (@LICENSE_ID NUMERIC
, @pResult VARCHAR(250) OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @ALLOW_REALLOC INT

  SELECT
    @pResult = 'OK'

  SELECT TOP 1
    @ALLOW_REALLOC = [S].[ALLOW_REALLOC]
  FROM [wms].[OP_WMS_LICENSES] [L]
  INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
    ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
  WHERE [L].[LICENSE_ID] = @LICENSE_ID


  IF (@ALLOW_REALLOC = 0)
  BEGIN
    SELECT
      @pResult = 'LICENCIA "' + CAST( @LICENSE_ID  AS VARCHAR)+ '" NO ESTA EN UNA UBICACIÓN DISPONIBLE PARA REUBICACION '

	     SELECT
      -1 AS Resultado
     ,@pResult Mensaje
     ,1 Codigo
	 ,CAST('' AS VARCHAR) DbData;

    RETURN -1
  END

  SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST('1' AS VARCHAR) DbData;


END