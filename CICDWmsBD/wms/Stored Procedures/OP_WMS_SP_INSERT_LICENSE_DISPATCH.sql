-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-Aug-2018 G-Force@Humano
-- Description:	        Sp que crea una nueva licencia para el despacho

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181010 GForce@Langosta
-- Description:			Se modifica para que filtre solo las licencias del operador

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_LICENSE_DISPATCH] (
		@WAVE_PICKING_ID INT
		,@LOGIN_ID VARCHAR(15)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY

    -- ------------------------------------------------------------------------------------
    -- Se declaran las variables a utilizar
    -- ------------------------------------------------------------------------------------

		DECLARE
			@LOCATION_SPOT_TARGET VARCHAR(25)
			,@CODIGO_POLIZA_TARGET VARCHAR(25)
			,@CLIENT_OWNER VARCHAR(25)
			,@REGIMEN VARCHAR(50)
			,@WAREHOUSE_TARGET VARCHAR(25)
			,@LICESE_ID INT = NULL;

    -- ------------------------------------------------------------------------------------
    -- Obtenemos la data necesaria para crear la licencia
    -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET]
			,@CODIGO_POLIZA_TARGET = [TL].[CODIGO_POLIZA_TARGET]
			,@CLIENT_OWNER = [TL].[CLIENT_OWNER]
			,@REGIMEN = [TL].[REGIMEN]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;



		SELECT TOP 1
			@WAREHOUSE_TARGET = [SS].[WAREHOUSE_PARENT]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS] [SS]
		WHERE
			[SS].[LOCATION_SPOT] = @LOCATION_SPOT_TARGET;

    -- ------------------------------------------------------------------------------------
    -- Obtenemos la licenia que no tenga inventario para no generar otra
    -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@LICESE_ID = MAX([L].[LICENSE_ID])
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
		WHERE
			[L].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [IL].[LICENSE_ID] IS NULL
			AND [L].[CURRENT_LOCATION] = @LOGIN_ID;

    -- ------------------------------------------------------------------------------------
    -- Validamos si la licencia sin producto existe...
    -- ------------------------------------------------------------------------------------

		IF @LICESE_ID IS NULL
		BEGIN
      
      -- ------------------------------------------------------------------------------------
      -- Insertamos la licencia de la ola de picking
      -- ------------------------------------------------------------------------------------
			INSERT	INTO [wms].[OP_WMS_LICENSES]
					(
						[CODIGO_POLIZA]
						,[CLIENT_OWNER]
						,[CURRENT_WAREHOUSE]
						,[CURRENT_LOCATION]
						,[LAST_LOCATION]
						,[LAST_UPDATED]
						,[LAST_UPDATED_BY]
						,[REGIMEN]
						,[WAVE_PICKING_ID]
					)
			VALUES
					(
						@CODIGO_POLIZA_TARGET
						,@CLIENT_OWNER
						,@LOGIN_ID
						,@LOGIN_ID
						,NULL
						,GETDATE()
						,@LOGIN_ID
						,@REGIMEN
						,@WAVE_PICKING_ID
					);

			SET @LICESE_ID = SCOPE_IDENTITY();
    
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@LICESE_ID AS VARCHAR(18)) [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,0 [Codigo];
	END CATCH;

END;