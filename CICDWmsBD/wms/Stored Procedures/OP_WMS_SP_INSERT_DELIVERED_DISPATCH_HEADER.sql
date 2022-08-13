-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-09 @ Team REBORN - Sprint Ramsey
-- Description:	        Tabla de despachos entregados encabezado

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_DELIVERED_DISPATCH_HEADER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_DELIVERED_DISPATCH_HEADER] (@WAVE_PICKING_ID INT
, @STATUS VARCHAR(25)
, @CREATE_BY VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @PICKING_DEMAND_HEADER_ID INT

  SELECT TOP 1
    @PICKING_DEMAND_HEADER_ID = [PDH].[PICKING_DEMAND_HEADER_ID]
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
  WHERE [PDH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID

  BEGIN TRY
    DECLARE @ID INT;

    INSERT INTO [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER] ([WAVE_PICKING_ID]
    , [STATUS]
    , [CREATE_DATE]
    , [CREATE_BY]
    , [PICKING_DEMAND_HEADER_ID])
      VALUES (@WAVE_PICKING_ID, @STATUS -- varchar(50)
      , GETDATE()  -- CREATE_DATE - datetime
      , @CREATE_BY  -- CREATE_BY - varchar(50)                    
      , @PICKING_DEMAND_HEADER_ID
      );

    SET @ID = SCOPE_IDENTITY();

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@ID AS VARCHAR) [DbData];
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;


END;