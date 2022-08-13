-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-Jun-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Sp Valida si tiene configurado zonas conpatibles con la licencia

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_VALIDATED_CONFIGURATION_OF_SLOTTING_ZONE_BY_LICENSE	
				@login = 'DESPINOZA',
					@LICENSE_ID = 41920
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATED_CONFIGURATION_OF_SLOTTING_ZONE_BY_LICENSE]
(
    @LOGIN VARCHAR(50),
    @LICENSE_ID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- ----------------------------------------
    -- Declaramos las variables necesarias.
    -- ----------------------------------------  
    DECLARE @MATERIAL_CLASS_TABLE TABLE
    (
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(50)
    );

    DECLARE @WAREHOSUE_TABLE TABLE
    (
        [WAREHOUSE_BY_USER_ID] INT,
        [LOGIN_ID] VARCHAR(25),
        [WAREHOUSE_ID] VARCHAR(25),
        [NAME] VARCHAR(50),
		[ERP_WAREHOUSE] INT
    );

    DECLARE @RESULT INT = 0,
            @DISPLAY_SUGGESTIONS INT = 0;

    DECLARE @SLOTTING_ZONE TABLE
    (
        [ID] INT
    );

    -- ----------------------------------------
    -- Obtenemos las bodegas asignadas al usuario
    -- ----------------------------------------
    INSERT INTO @WAREHOSUE_TABLE
    EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_USER_CD] @LOGIN = @LOGIN;

	
  -- ----------------------------------------
  -- Obtenemos todas las zonas compatibles con las clases obteniadas
  -- ----------------------------------------
  	DECLARE	@PARAMETHERS TABLE ([IDENTITY] INT
          ,[GROUP_ID] VARCHAR (250)
          ,[PARAMETER_ID] VARCHAR (250)
          ,[VALUE] VARCHAR (MAX)
          ,[LABEL] VARCHAR (250));

	INSERT INTO @PARAMETHERS 
	EXEC [wms].[OP_WMS_SP_GET_PARAMETER] @GROUP_ID = 'MATERIAL_SUB_FAMILY',@PARAMETER_ID = 'USE_MATERIAL_SUB_FAMILY';
 
	if NOT EXISTS( SELECT TOP 1 1 FROM @PARAMETHERS WHERE [VALUE]='1')--propiedad configurada
	BEGIN

			-- ----------------------------------------
			-- Obtenemos todas las clases de los productos de la licencia enviada
			-- ----------------------------------------
			INSERT INTO @MATERIAL_CLASS_TABLE
			(
				[CLASS_ID],
				[CLASS_NAME]
			)
			SELECT DISTINCT
				   [C].[CLASS_ID],
				   [C].[CLASS_NAME]
			FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
					ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
				INNER JOIN [wms].[OP_WMS_CLASS] [C]
					ON ([M].[MATERIAL_CLASS] = [C].[CLASS_ID])
			WHERE [IL].[LICENSE_ID] = @LICENSE_ID;

			-- ----------------------------------------
			-- Obtenemos todas las zonas compatibles con las clases obteniadas
			-- ----------------------------------------
			INSERT INTO @SLOTTING_ZONE
			(
				[ID]
			)
			SELECT DISTINCT
				   1
			FROM [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
				INNER JOIN @WAREHOSUE_TABLE [WT]
					ON ([SZ].[WAREHOUSE_CODE] = [WT].[WAREHOUSE_ID])
				INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC]
					ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
				INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS]
					ON (
						   [SZ].[ZONE] = [SS].[ZONE]
						   AND [SZ].[WAREHOUSE_CODE] = [SS].[WAREHOUSE_PARENT]
					   )
				INNER JOIN @MATERIAL_CLASS_TABLE [MCT]
					ON ([SZC].[CLASS_ID] = [MCT].[CLASS_ID])
			WHERE [SS].[ALLOW_STORAGE] = 1
			GROUP BY [SZ].[ID],
					 [SZ].[WAREHOUSE_CODE],
					 [SZ].[ZONE_ID],
					 [SZ].[ZONE],
					 [SZ].[MANDATORY];
	END
	ELSE
	BEGIN
	
			-- ----------------------------------------
			-- Obtenemos todas las clases de los productos de la licencia enviada
			-- ----------------------------------------
			INSERT INTO @MATERIAL_CLASS_TABLE
			(
				[CLASS_ID],
				[CLASS_NAME]
			)
			SELECT DISTINCT
				   [C].[SUB_CLASS_ID],
				   [C].[SUB_CLASS_NAME]
			FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
					ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
				INNER JOIN [wms].[OP_WMS_SUB_CLASS] [C]
					ON ([M].[MATERIAL_sub_CLASS] = [C].[sub_CLASS_ID])
			WHERE [IL].[LICENSE_ID] = @LICENSE_ID;
			-- ----------------------------------------
			-- Obtenemos todas las zonas compatibles con las clases obteniadas
			-- ----------------------------------------
			INSERT INTO @SLOTTING_ZONE
			(
				[ID]
			)
			SELECT DISTINCT
				   1
			FROM [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
				INNER JOIN @WAREHOSUE_TABLE [WT]
					ON ([SZ].[WAREHOUSE_CODE] = [WT].[WAREHOUSE_ID])
				INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZC]
					ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
				INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS]
					ON (
						   [SZ].[ZONE] = [SS].[ZONE]
						   AND [SZ].[WAREHOUSE_CODE] = [SS].[WAREHOUSE_PARENT]
					   )
				INNER JOIN @MATERIAL_CLASS_TABLE [MCT]
					ON ([SZC].[SUB_CLASS_ID] = [MCT].[CLASS_ID])
			WHERE [SS].[ALLOW_STORAGE] = 1
			GROUP BY [SZ].[ID],
					 [SZ].[WAREHOUSE_CODE],
					 [SZ].[ZONE_ID],
					 [SZ].[ZONE],
					 [SZ].[MANDATORY];


	END

    IF EXISTS (SELECT 1 FROM @SLOTTING_ZONE)
    BEGIN
        SET @RESULT += 1;
    END;

    SELECT TOP 1
           @DISPLAY_SUGGESTIONS = CAST([P].[VALUE] AS INT)
    FROM [wms].[OP_WMS_PARAMETER] [P]
    WHERE [P].[GROUP_ID] = 'SUGGESTION_TO_LOCATE'
          AND [P].[PARAMETER_ID] = 'DISPLAY_SUGGESTIONS';


    SET @RESULT = CASE
                      WHEN @RESULT = 1
                           AND @DISPLAY_SUGGESTIONS = 1 THEN
                          3
                      WHEN @RESULT = 0
                           AND @DISPLAY_SUGGESTIONS = 1 THEN
                          2
                      WHEN @RESULT = 1
                           AND @DISPLAY_SUGGESTIONS = 0 THEN
                          1
                      ELSE
                          0
                  END;
    -- ----------------------------------------
    -- Retornamos el resultado 
    -- ----------------------------------------

    SELECT 1 AS [Resultado],
           'Tiene configurado zonas compatibles' [Mensaje],
           0 [Codigo],
           CAST(@RESULT AS VARCHAR(20)) AS [DbData];
END;