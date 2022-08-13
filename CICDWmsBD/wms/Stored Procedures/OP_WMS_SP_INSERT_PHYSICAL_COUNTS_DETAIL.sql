-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Insertar en detalle de conteo




/*
-- Ejemplo de Ejecucion:

EXEC [wms].[OP_WMS_SP_INSERT_PHYSICAL_COUNTS_DETAIL] @PHYSICAL_COUNT_HEADER_ID = 1
                                                           ,@WAREHOUSE_ID = 'BODEGA_04'
                                                           ,@ZONE = 'BODEGA_04'
                                                           ,@LOCATION = '123123'
                                                           ,@CLIENT_CODE = '123132'
                                                           ,@MATERIAL_ID = NULL
                                                           ,@ASSIGNED_TO = 'ACAMACHO'
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_PHYSICAL_COUNTS_DETAIL] (@PHYSICAL_COUNT_HEADER_ID INT
, @WAREHOUSE_ID VARCHAR(25)
, @ZONE VARCHAR(200)
, @LOCATION VARCHAR(25)
, @CLIENT_CODE VARCHAR(25) = NULL
, @MATERIAL_ID VARCHAR(25) = NULL
, @ASSIGNED_TO VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  INSERT INTO [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] ([PHYSICAL_COUNT_HEADER_ID], [ZONE], [LOCATION], [CLIENT_CODE], [MATERIAL_ID], [ASSIGNED_TO], [STATUS], [WAREHOUSE_ID])
    VALUES (@PHYSICAL_COUNT_HEADER_ID, @ZONE, @LOCATION, @CLIENT_CODE, @MATERIAL_ID, @ASSIGNED_TO, 'CREATED', @WAREHOUSE_ID);

  DECLARE @DOC_ID INT = SCOPE_IDENTITY()
  IF @@ERROR <> 0
  BEGIN

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
     ,'0' DbData

  END
  ELSE
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@DOC_ID AS VARCHAR) DbData
  END

END