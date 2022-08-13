-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	18/09/2017 @ Reborn-Team Sprint Collin 
-- Description:			    Sp que actualiza el invnetario

/*
-- Ejemplo de Ejecucion:
				
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_UPDATE_STATUS_BY_MATERIAL (@XML XML)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    DECLARE @LICENSE_ID NUMERIC = 0
           ,@MATERIAL_ID VARCHAR(50) = ''
           ,@STATUS_CODE VARCHAR(50) = ''
           ,@STATUS_NAME VARCHAR(100) = ''
           ,@BLOCKS_INVENTORY INT = 0
           ,@ALLOW_REALLOC INT = 0
           ,@TARGET_LOCATION VARCHAR(25) = ''
           ,@DESCRIPTION VARCHAR(200) = ''
           ,@COLOR VARCHAR(20) = ''
           ,@STATUS_ID INT = 0

    --
    DECLARE @XML_RESULT TABLE (
      [LICENSE_ID] NUMERIC
     ,[MATERIAL_ID] VARCHAR(50)
     ,[CODE_STATUS] VARCHAR(50)
    );
    --
    DECLARE @INVENTORY_BY_STATUS TABLE (
      [LICENSE_ID] NUMERIC
     ,[MATERIAL_ID] VARCHAR(50)
     ,[CODE_STATUS] VARCHAR(50)
     ,[STATUS_NAME] VARCHAR(100)
     ,[BLOCKS_INVENTORY] INT
     ,[ALLOW_REALLOC] INT
     ,[TARGET_LOCATION] VARCHAR(25)
     ,[DESCRIPTION] VARCHAR(200)
     ,[COLOR] VARCHAR(20)
    );

    DECLARE @STATUS_TB TABLE (
      RESULTADO INT
     ,MENSAJE VARCHAR(15)
     ,CODIGO INT
     ,STATUS_ID INT
    )
    -- ------------------------------------------------------------------------------------
    -- Obtenemos todos los SKUs desde el XML.  
    -- ------------------------------------------------------------------------------------
    INSERT INTO @XML_RESULT
      SELECT
        [X].[Rec].[query]('./LICENSE_ID').[value]('.', 'int') [LICENSE_ID]
       ,[X].[Rec].[query]('./MATERIAL_ID').[value]('.', 'varchar(50)') [MATERIAL_ID]
       ,[X].[Rec].[query]('./STATUS_CODE').[value]('.', 'varchar(50)') [STATUS_CODE]
      FROM @XML.[nodes]('/ArrayOfInventario/Inventario') AS [X] ([Rec]);

    -- ------------------------------------------------------------------------------------
    -- Se obtiene el estado de cada licencia
    -- ------------------------------------------------------------------------------------
    INSERT INTO @INVENTORY_BY_STATUS
      SELECT
        [XR].[LICENSE_ID]
       ,[XR].[MATERIAL_ID]
       ,[XR].[CODE_STATUS]
       ,[C].[PARAM_CAPTION]
       ,CASE [C].[SPARE1]
          WHEN 'SI' THEN 1
          WHEN 'NO' THEN 0
          WHEN 1 THEN 1
          ELSE 0
        END
       ,CASE [C].[SPARE2]
          WHEN 'SI' THEN 1
          WHEN 'NO' THEN 0
          WHEN 1 THEN 1
          ELSE 0
        END
       ,[C].[SPARE3]
       ,[C].[TEXT_VALUE]
       ,[C].[COLOR]
      FROM @XML_RESULT [XR]
      INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
        ON (
        [C].[PARAM_NAME] = [XR].[CODE_STATUS]
        )
        AND [C].[PARAM_GROUP] = 'ESTADOS'


    DELETE @XML_RESULT
    -- ------------------------------------------------------------------------------------
    -- Procesa las licencias para insertar el detalle
    -- ------------------------------------------------------------------------------------
    WHILE EXISTS (SELECT TOP 1
          1
        FROM @INVENTORY_BY_STATUS)
    BEGIN
      SELECT TOP 1
        @LICENSE_ID = [IS].[LICENSE_ID]
       ,@MATERIAL_ID = [IS].[MATERIAL_ID]
       ,@STATUS_CODE = [IS].[CODE_STATUS]
       ,@STATUS_NAME = [IS].[STATUS_NAME]
       ,@BLOCKS_INVENTORY = [IS].[BLOCKS_INVENTORY]
       ,@ALLOW_REALLOC = [IS].[ALLOW_REALLOC]
       ,@TARGET_LOCATION = [IS].[TARGET_LOCATION]
       ,@DESCRIPTION = [IS].[DESCRIPTION]
       ,@COLOR = [IS].[COLOR]
      FROM @INVENTORY_BY_STATUS [IS]


      INSERT INTO @STATUS_TB ([RESULTADO], [MENSAJE], [CODIGO], [STATUS_ID])
      EXEC [wms].[OP_WMS_SP_ADD_STATUS_OF_MATERIAL_BY_LICENSE] @STATUS_CODE = @STATUS_CODE
                                                                  ,@STATUS_NAME = @STATUS_NAME
                                                                  ,@BLOCKS_INVENTORY = @BLOCKS_INVENTORY
                                                                  ,@ALLOW_REALLOC = @ALLOW_REALLOC
                                                                  ,@TARGET_LOCATION = @TARGET_LOCATION
                                                                  ,@DESCRIPTION = @DESCRIPTION
                                                                  ,@COLOR = @COLOR
                                                                  ,@LICENSE_ID = @LICENSE_ID

      SELECT TOP 1
        @STATUS_ID = [STATUS_ID]
      FROM @STATUS_TB

      DELETE @STATUS_TB

      -- ------------------------------------------------------------------------------------
      -- Se actualiza el estado de la licencia y material
      -- ------------------------------------------------------------------------------------
      UPDATE [wms].[OP_WMS_INV_X_LICENSE]
      SET [STATUS_ID] = @STATUS_ID
      WHERE [LICENSE_ID] = @LICENSE_ID
      AND [MATERIAL_ID] = @MATERIAL_ID;

      -- ------------------------------------------------------------------------------------
      -- Quita la licencia y materialde la tabla temporal
      -- ------------------------------------------------------------------------------------
      DELETE FROM @INVENTORY_BY_STATUS
      WHERE [LICENSE_ID] = @LICENSE_ID
        AND [MATERIAL_ID] = @MATERIAL_ID;
    END;

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH

END;