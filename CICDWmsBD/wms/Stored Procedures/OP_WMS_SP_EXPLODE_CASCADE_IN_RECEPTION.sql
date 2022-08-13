-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-07-06 NEXUS@AgeOfEmpires
-- Description:	 Se crea procedimiento que realiza explosión dejando traza por cada nivel que explota hasta llegar al ultimo nivel. 

-- Modificacion 9/8/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se corrige longitud de parametro @pMATERIAL_CODE para que coincida con el de la tabla [OP_WMS_MATERIALS]

/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] (@LICENSE_ID NUMERIC
, @LOGIN_ID VARCHAR(25)
, @MATERIAL_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --


  ---------------------------------------------------------------------------------
  -- DECLARACIÓN DE VARIABLES GLOBALES
  ---------------------------------------------------------------------------------  
  DECLARE @MATERIAL_TO_EXPLODE VARCHAR(25)
         ,@QTY_TO_EXPLODE INT
         ,@FLAG INT = 0

  DECLARE @MATERIALS_PARENTS TABLE (
    MATERIAL_ID VARCHAR(25)
   ,QTY INT
  )

  DECLARE @MATERIALS_CHILDS TABLE (
    MATERIAL_ID VARCHAR(25)
   ,QTY INT
  )


  ---------------------------------------------------------------------------------
  -- Guarda en @MATERIALS_PARENTS los componentes para la explosión de la siguiente iteración
  ---------------------------------------------------------------------------------  
  INSERT INTO @MATERIALS_PARENTS
    SELECT
      D.[MATERIAL_ID]
     ,[D].[QTY]
    FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
    INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
      ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
    WHERE [H].[LICENSE_ID] = @LICENSE_ID
    AND [H].[MATERIAL_ID] = @MATERIAL_ID
    AND [H].[EXPLODED] = 0

  IF EXISTS (SELECT TOP 1
        1
      FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
      WHERE [H].[LICENSE_ID] = @LICENSE_ID
      AND [H].[MATERIAL_ID] = @MATERIAL_ID)

    ---------------------------------------------------------------------------------
    -- Explotar primer nivel
    ---------------------------------------------------------------------------------
	print 'Explotar primer nivel'
    EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID
                                               ,@MATERIAL_ID = @MATERIAL_ID
                                               ,@LAST_UPDATE_BY = @LOGIN_ID
                                               ,@MANUAL_EXPLOTION = 0


  WHILE (@FLAG = 0)
  BEGIN

    ---------------------------------------------------------------------------------
    -- Ciclo hasta explotar todos los materiales posibles
    ---------------------------------------------------------------------------------  
	print 'Ciclo hasta explotar todos los materiales posibles'
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
          WHERE [H].[LICENSE_ID] = @LICENSE_ID
          AND [H].[MATERIAL_ID] = @MATERIAL_TO_EXPLODE)
      BEGIN

        --Explotar material actual
		print 'Explotar material actual: '+@MATERIAL_ID
        EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID
                                                   ,@MATERIAL_ID = @MATERIAL_TO_EXPLODE
                                                   ,@LAST_UPDATE_BY = @LOGIN_ID
                                                   ,@MANUAL_EXPLOTION = 0

        ---------------------------------------------------------------------------------
        -- Guardar materiales explotados para validar si deben de explotarse en el siguiente nivel 
        ---------------------------------------------------------------------------------  
        INSERT INTO @MATERIALS_CHILDS
          SELECT
            D.[MATERIAL_ID]
           ,[D].[QTY]
          FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
          INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
            ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
          WHERE [H].[LICENSE_ID] = @LICENSE_ID
          AND [H].[MATERIAL_ID] = @MATERIAL_TO_EXPLODE
          AND [H].[EXPLODED] = 0


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


    ---------------------------------------------------------------------------------
    -- Finalizar el ciclo en caso ya no hayan mas materiales 
    ---------------------------------------------------------------------------------  
    IF NOT EXISTS (SELECT TOP 1
          1
        FROM @MATERIALS_PARENTS)
      SELECT
        @FLAG = 1
  END


END