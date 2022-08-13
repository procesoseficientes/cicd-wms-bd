-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-09-12 @Team REBORN - Sprint Collin
-- Description:	        Se crea el sp para insertar y validar el tono y calibre del material.

/*
-- Ejemplo de Ejecucion:
EXEC [wms].OP_WMS_SP_ADD_TONE_AND_CALIBER_BY_MATERIAL @MATERIAL_ID = 'C00030/CASEREN'
                                                        , @TONE VARCHAR(10) = 'T123'
                                                        , @CALIBER VARCHAR(10) = 'C123'

			
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_TONE_AND_CALIBER_BY_MATERIAL]
	(
		@MATERIAL_ID VARCHAR(50)
		,@TONE VARCHAR(20) = NULL
		,@CALIBER VARCHAR(20) = NULL
	)
AS
	BEGIN TRY
  --
		DECLARE
			@ID INT = NULL
			,@TONE_TO_INSERT VARCHAR(20)
			,@CALIBER_TO_INSERT VARCHAR(20);
	-- ------------------------------------------------------------
	-- Se verifica que las variables no vengan con valor VACIO = ''
	-- ------------------------------------------------------------
		SELECT
			@TONE_TO_INSERT = CASE @TONE
								WHEN '' THEN NULL
								WHEN NULL THEN NULL
								ELSE @TONE
								END
			,@CALIBER_TO_INSERT = CASE @CALIBER
									WHEN '' THEN NULL
									WHEN NULL THEN NULL
									ELSE @CALIBER
									END;

  -- ----------
  -- Se valida si existte un tono o calbre para el material
  -- ----------
		SELECT
			@ID = [TCM].[TONE_AND_CALIBER_ID]
		FROM
			[wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
		WHERE
			[TCM].[TONE] = @TONE
			AND [TCM].[CALIBER] = @CALIBER
			AND [TCM].[MATERIAL_ID] = @MATERIAL_ID;


		IF @ID IS NULL
		BEGIN

    -- ------------------------
    -- Se inserta si no existe
    -- ------------------------
			INSERT	INTO [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL]
					(
						[MATERIAL_ID]
						,[TONE]
						,[CALIBER]
					)
			VALUES
					(
						@MATERIAL_ID
						,@TONE_TO_INSERT
						,@CALIBER_TO_INSERT
					);
			SET @ID = SCOPE_IDENTITY();
		END;
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@ID AS VARCHAR(50)) [DbData];

	END TRY
	BEGIN CATCH

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];

	END CATCH;