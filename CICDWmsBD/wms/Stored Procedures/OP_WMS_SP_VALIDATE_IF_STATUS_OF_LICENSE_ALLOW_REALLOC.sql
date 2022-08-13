-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-03 @ Team REBORN - Sprint Collin
-- Description:	        Sp que valida si el estado de la licencia y el material permiete reubicacion

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_VALIDATE_IF_STATUS_OF_LICENCE_ALLOW_REALLOC
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_IF_STATUS_OF_LICENSE_ALLOW_REALLOC] (
		@LICENCE_ID NUMERIC
		,@MATERIAL_ID VARCHAR(50) = NULL
		,@RESULT VARCHAR(250) OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
  ---------------------------------------------------------------------------------
  -- Declaramos Variables
  ---------------------------------------------------------------------------------

	DECLARE
		@ALLOW_REALLOC INT = 0
		,@STATUS_NAME VARCHAR(100)
		,@NUMBER_OF_STATUS INT
		,@RESPUESTA VARCHAR(30);

	SET @RESULT = 'OK';

  ---------------------------------------------------------------------------------
  -- Validamos si el material es null para hacer validaciones de licencia nada mas
  ---------------------------------------------------------------------------------

	IF @MATERIAL_ID IS NULL
	BEGIN

    ---------------------------------------------------------------------------------
    -- Se verifica si la licencia tiene estados que bloqueen y que no bloqueen reubicacion, si tiene mas de uno, no se bloquea la reubicacion
    ---------------------------------------------------------------------------------
		SELECT
			@NUMBER_OF_STATUS = COUNT(*)
		FROM
			(SELECT
					[IXL].[LICENSE_ID]
					,[S].[ALLOW_REALLOC]
				FROM
					[wms].[OP_WMS_INV_X_LICENSE] [IXL]
				INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON [IXL].[STATUS_ID] = [S].[STATUS_ID]
				WHERE
					[IXL].[LICENSE_ID] = @LICENCE_ID
				GROUP BY
					[IXL].[LICENSE_ID]
					,[S].[ALLOW_REALLOC]) [R];

		IF @NUMBER_OF_STATUS > 1
		BEGIN
			SELECT
				@RESULT;
			RETURN;
		END;
	END;

  ---------------------------------------------------------------------------------
  -- Se valida si el estado de la licencia y material bloquea reubicacion
  ---------------------------------------------------------------------------------
	SELECT
		@ALLOW_REALLOC = [S].[ALLOW_REALLOC]
		,@STATUS_NAME = [S].[STATUS_NAME]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IXL]
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S] ON [IXL].[STATUS_ID] = [S].[STATUS_ID]
	WHERE
		[IXL].[LICENSE_ID] = @LICENCE_ID
		AND (
				@MATERIAL_ID IS NULL
				OR [IXL].[MATERIAL_ID] = @MATERIAL_ID
			);

	IF (@ALLOW_REALLOC = 0)
	BEGIN


		IF @MATERIAL_ID IS NULL
		BEGIN
			SET @RESPUESTA = 'DE LICENCIA "'
				+ CAST(@LICENCE_ID AS VARCHAR) + '"';
		END;
		ELSE
		BEGIN
			SET @RESPUESTA = 'DE SKU "'
				+ CAST(@MATERIAL_ID AS VARCHAR) + '"';
		END;

		SET @RESULT = 'ESTADO, "' + @STATUS_NAME
			+ '", NO PERMITE REUBICACION ' + @RESPUESTA;
		SELECT
			@RESULT;
		RETURN -1;
	END;

	SELECT
		@RESULT;

END;