-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181024 GForce@Mamba
-- Description:			sp que valida si hay suficiente inventario para reubicar por material

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[[OP_WMS_SP_VALIDATE_INVENTORY_FOR_REALLOC]]
					@LICENSE_ID = 5
					,@MATERIAL_ID = 'C00012/CONCLIMON'
					,@SERIAL = 'SERIAL'
					,@BATCH = 'BATCH'
					,@DATE_EXPIRATION = '20171111'
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_INVENTORY_FOR_REALLOC] (
		@MATERIAL_ID VARCHAR(250)
		,@SOURCE_LICENSE NUMERIC(18, 0)
		,@QUANTITY_UNITS NUMERIC(18, 4)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE
			@ErrorCode INT
			,@CURRENT_SOURCE_INV NUMERIC(18, 4)
			,@RESULT VARCHAR(200);
		--

		SELECT TOP 1
			@CURRENT_SOURCE_INV = ISNULL([IL].[QTY], 0)
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		WHERE
			[IL].[LICENSE_ID] = @SOURCE_LICENSE
			AND [IL].[MATERIAL_ID] = @MATERIAL_ID;

		SELECT TOP 1
			@CURRENT_SOURCE_INV = @CURRENT_SOURCE_INV
			+ ISNULL([CI].[COMMITED_QTY], 0)
		FROM
			[wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI]
		WHERE
			[CI].[LICENCE_ID] = @SOURCE_LICENSE
			AND [CI].[MATERIAL_ID] = @MATERIAL_ID;

    ---------------------------------------------------------------------------------
    -- validar unidades
    ---------------------------------------------------------------------------------  
		IF (@CURRENT_SOURCE_INV < @QUANTITY_UNITS)
		BEGIN
			SELECT
				@RESULT = 'ERROR, Licencia: '
				+ CONVERT(VARCHAR(20), @SOURCE_LICENSE)
				+ ' No tiene suficiente inventario '
				+ ' para rebajar '
				+ CONVERT(VARCHAR(20), @QUANTITY_UNITS);
			SELECT
				@ErrorCode = 3055;
			RAISERROR (@RESULT, 16, 1);
		END;

		SELECT
			1 [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,1 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode [Codigo]
			,'' [DbData];
	END CATCH;

	
END;