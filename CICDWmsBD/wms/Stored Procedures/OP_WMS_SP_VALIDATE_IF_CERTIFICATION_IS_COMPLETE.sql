-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-24 @ Team REBORN - Sprint Drache
-- Description:	        Sp que verifica si la certificacion esta al 100%

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se verifica si esta completo con la tabla de etiquetas por manifiesto en vez de la del detalle del manifiesto
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_VALIDATE_IF_CERTIFICATION_IS_COMPLETE @CERTIFICATION_HEADER_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_VALIDATE_IF_CERTIFICATION_IS_COMPLETE (@CERTIFICATION_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DECLARE @QTY_TOTAL NUMERIC(18, 4)
           ,@QTY_CERTIFICADO NUMERIC(18, 4)
           ,@PORCENTAJE NUMERIC(18, 2) = 0;

    SELECT
      @QTY_TOTAL = SUM([PLB].[QTY])
    FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
	INNER JOIN [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLB] ON [PLB].[MANIFEST_DETAIL_ID] = [MD].[MANIFEST_DETAIL_ID]
    INNER JOIN [wms].[OP_WMS_CERTIFICATION_HEADER] [CH]
      ON [MD].[MANIFEST_HEADER_ID] = [CH].[MANIFEST_HEADER_ID]
    WHERE [CH].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID

    SELECT
      @QTY_CERTIFICADO = SUM([CD].[QTY])
    FROM [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
    INNER JOIN [wms].[OP_WMS_CERTIFICATION_HEADER] [CH]
      ON [CD].[CERTIFICATION_HEADER_ID] = [CH].[CERTIFICATION_HEADER_ID]
    WHERE [CH].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID

    IF @QTY_CERTIFICADO IS NOT NULL
    BEGIN
      SET @PORCENTAJE = (@QTY_CERTIFICADO / @QTY_TOTAL * 100)
    END



    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@PORCENTAJE AS VARCHAR) [DbData];

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;


END