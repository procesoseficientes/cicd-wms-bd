
 -- =============================================
 -- Autor:					pablo.aguilar
 -- Fecha de Creacion: 		01-Dec-17 @ Nexus Team Sprint GTA
 -- Description:			Crea el estado y devuelve su ID
 
 /*
 -- Ejemplo de Ejecucion:
		DECLARE @STATUS_ID AS INT  
        exec [wms].[OP_WMS_SP_CREATE_MATERIAL_STATUS] 'ESTADO_DEFAULT', @STATUS_ID OUT , @DEFAULT = 1
				SELECT  @STATUS_ID
				SELECT * FROM [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] WHERE [STATUS_ID] = @STATUS_ID
 */
 -- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_MATERIAL_STATUS] (
		@STATUS_CODE_TO_CREATE VARCHAR(50)
		,@STATUS_ID INT OUT
		,@DEFAULT INT = NULL --1 Para crear el default prioritario sobre @STATUS_CODE_TO_CREATE
		
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE	@STATUS_TB TABLE (
			[RESULTADO] INT
			,[MENSAJE] VARCHAR(15)
			,[CODIGO] INT
			,[STATUS_ID] INT
		);

	DECLARE
		@STATUS_CODE VARCHAR(50)
		,@STATUS_NAME VARCHAR(100)
		,@BLOCKS_INVENTORY INT
		,@ALLOW_REALLOC INT
		,@TARGET_LOCATION VARCHAR(50)
		,@DESCRIPTION VARCHAR(200)
		,@COLOR VARCHAR(50);
      -- ----------------------------------------------------------------------------------
      -- Se obtinene los datos del estado
      -- ----------------------------------------------------------------------------------
	SELECT
		@STATUS_CODE = [C].[PARAM_NAME]
		,@STATUS_NAME = [C].[PARAM_CAPTION]
		,@BLOCKS_INVENTORY = CASE [C].[SPARE1]
								WHEN 'SI' THEN 1
								WHEN 'NO' THEN 0
								WHEN 1 THEN 1
								ELSE 0
								END
		,@ALLOW_REALLOC = CASE [C].[SPARE2]
							WHEN 'SI' THEN 1
							WHEN 'NO' THEN 0
							WHEN 1 THEN 1
							ELSE 0
							END
		,@TARGET_LOCATION = [C].[SPARE3]
		,@DESCRIPTION = [C].[TEXT_VALUE]
		,@COLOR = [C].[COLOR]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		(
			@DEFAULT = 1
			OR [C].[PARAM_NAME] = @STATUS_CODE_TO_CREATE
		)
		AND (
				@DEFAULT = 0
				OR [C].[NUMERIC_VALUE] = 1
			)
		AND [C].[PARAM_GROUP] = 'ESTADOS';

      -- ----------------------------------------------------------------------------------
      -- Se actualiza la informacion del estado
      -- ----------------------------------------------------------------------------------
	INSERT	[wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
			(
				[STATUS_CODE]
				,[STATUS_NAME]
				,[BLOCKS_INVENTORY]
				,[ALLOW_REALLOC]
				,[TARGET_LOCATION]
				,[DESCRIPTION]
				,[COLOR]
			)
	VALUES
			(
				@STATUS_CODE
				,@STATUS_NAME
				,@BLOCKS_INVENTORY
				,@ALLOW_REALLOC
				,@TARGET_LOCATION
				,@DESCRIPTION
				,@COLOR
			);


	SET @STATUS_ID = SCOPE_IDENTITY();
	INSERT INTO @STATUS_TB
			(
				[RESULTADO]
				,[MENSAJE]
				,[CODIGO]
				,[STATUS_ID]
			)
	VALUES
			(
				1  -- RESULTADO - int
				,'Proceso éxitoso'  -- MENSAJE - varchar(15)
				,0  -- CODIGO - int
				, CAST( @STATUS_ID AS VARCHAR)  -- STATUS_ID - int
			)
	

END;