-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-03 @ Team ERGON - Sprint Ganondorf
-- Description:	 Se agrega SP para realizar explosión en cascada hasta encontrar el material que necesita el reabastecimiento. 




/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_MASTER_PACK_CASCADE_EXPLODE_IN_REPLENISHMENT (@MATERIAL_ID VARCHAR(25)
, @NEW_LICENSE NUMERIC
, @SOURCE_LICENSE NUMERIC
, @WAVE_PICKING_ID NUMERIC
 , @LOGIN_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
--

END
  DECLARE @MATERIAL_TO_EXPLODE VARCHAR(25)
         ,@QTY_TO_EXPLODE INT
         ,@FLAG INT = 0
         ,@REPLENISH_MATERIAL_ID_TARGET VARCHAR(25)

  SELECT TOP 1
    @REPLENISH_MATERIAL_ID_TARGET = [TL].[REPLENISH_MATERIAL_ID_TARGET]
  FROM [wms].[OP_WMS_TASK_LIST] [TL]
  WHERE [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
  AND [TL].[MATERIAL_ID] = @MATERIAL_ID
  AND [TL].[LICENSE_ID_SOURCE] = @SOURCE_LICENSE
  AND [TL].[TASK_SUBTYPE] = 'REUBICACION_BUFFER'
  IF @REPLENISH_MATERIAL_ID_TARGET IS NOT NULL AND @REPLENISH_MATERIAL_ID_TARGET <> @MATERIAL_ID
  BEGIN

    DECLARE @MATERIALS_PARENTS TABLE (
      MATERIAL_ID VARCHAR(25)
     ,QTY INT
    )

    DECLARE @MATERIALS_CHILDS TABLE (
      MATERIAL_ID VARCHAR(25)
     ,QTY INT
    )



    INSERT INTO @MATERIALS_PARENTS
      SELECT
        D.[MATERIAL_ID]
       ,[D].[QTY]
      FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
      INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
        ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
      WHERE [H].[MATERIAL_ID] = @MATERIAL_ID
      AND [H].[LICENSE_ID] = @NEW_LICENSE



    IF EXISTS (SELECT TOP 1
          1
        FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
        WHERE [H].[LICENSE_ID] = @NEW_LICENSE
        AND [H].[MATERIAL_ID] = @MATERIAL_ID)

      EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @NEW_LICENSE
                                                 ,@MATERIAL_ID = @MATERIAL_ID
                                                 ,@LAST_UPDATE_BY = @LOGIN_ID



    WHILE (@FLAG = 0
      AND NOT EXISTS (SELECT TOP 1
          1
        FROM @MATERIALS_PARENTS
        WHERE @REPLENISH_MATERIAL_ID_TARGET = [MATERIAL_ID])
      )
    BEGIN

      WHILE EXISTS (SELECT TOP 1
            1
          FROM @MATERIALS_PARENTS)
      BEGIN
        SELECT TOP 1
          @MATERIAL_TO_EXPLODE = [MATERIAL_ID]
         ,@QTY_TO_EXPLODE = [QTY]
        FROM @MATERIALS_PARENTS

        IF EXISTS (SELECT TOP 1
              1
            FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
            WHERE [H].[LICENSE_ID] = @NEW_LICENSE
            AND [H].[MATERIAL_ID] = @MATERIAL_TO_EXPLODE)
        BEGIN
          EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @NEW_LICENSE
                                                     ,@MATERIAL_ID = @MATERIAL_TO_EXPLODE
                                                     ,@LAST_UPDATE_BY = @LOGIN_ID

          INSERT INTO @MATERIALS_CHILDS
            SELECT
              D.[MATERIAL_ID]
             ,[D].[QTY]
            FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
            INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
              ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
            WHERE [H].[MATERIAL_ID] = @MATERIAL_TO_EXPLODE
            AND [H].[LICENSE_ID] = @NEW_LICENSE

        END



        DELETE @MATERIALS_PARENTS
        WHERE [MATERIAL_ID] = @MATERIAL_TO_EXPLODE

      END

      INSERT INTO @MATERIALS_PARENTS
        SELECT
          [MATERIAL_ID]
         ,[QTY]
        FROM @MATERIALS_CHILDS

      DELETE @MATERIALS_CHILDS

      IF NOT EXISTS (SELECT TOP 1
            1
          FROM @MATERIALS_PARENTS)
        SELECT
          @FLAG = 1


    END


  END