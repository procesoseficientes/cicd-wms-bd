-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2018-01-05 @ Team REBORN - Sprint Ramsey
-- Description:	        SP inserta una entrega de una etiqueta

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_DELIVERED_DETAIL] @LABEL_ID = 5, @WAVE_PICKING_ID = 21
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_DELIVERED_DETAIL] (@LABEL_ID INT
, @STATUS VARCHAR(50)
, @LOGIN_ID VARCHAR(50)
, @DELIVERED_DISPATCH_HEADER_ID INT
, @WAVE_PICKING_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    DECLARE @ID INT;

    IF NOT EXISTS (SELECT TOP 1
          1
        FROM [wms].[OP_WMS_PICKING_LABELS] [PL]
        WHERE [PL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
        AND [PL].[LABEL_ID] = @LABEL_ID)
    BEGIN
      SELECT
        -1 AS [Resultado]
       ,'Etiqueta no pertenece a esta ola de picking' [Mensaje]
       ,0 [Codigo]
       ,CAST(@LABEL_ID AS VARCHAR) [DbData];

      RETURN;
    END;

    IF EXISTS (SELECT TOP 1
          1
        FROM [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL] [DL]
        WHERE [DL].[LABEL_ID] = @LABEL_ID)
    BEGIN
      SELECT
        2 AS [Resultado]
       ,'Etiqueta ya fue escaneada, ¿Desea eliminarla?' [Mensaje]
       ,0 [Codigo]
       ,CAST(@LABEL_ID AS VARCHAR) [DbData];

      RETURN;
    END;

    INSERT INTO [wms].[OP_WMS_DELIVERED_DISPATCH_DETAIL] ([LABEL_ID]
    , [LAST_UPDATE]
    , [LAST_UPDATE_BY]
    , [DELIVERED_DISPATCH_HEADER_ID])
      VALUES (@LABEL_ID  -- LABEL_ID - int
      , GETDATE()  -- LAST_UPDATE - datetime
      , @LOGIN_ID  -- LAST_UPDATE_BY - varchar(50)
      , @DELIVERED_DISPATCH_HEADER_ID  -- DELIVERED_DISPATCH_HEADER_ID - int
      );

    SET @ID = SCOPE_IDENTITY();

    UPDATE [wms].[OP_WMS_PICKING_LABELS]
    SET [LABEL_STATUS] = @STATUS
    WHERE [LABEL_ID] = @LABEL_ID;

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