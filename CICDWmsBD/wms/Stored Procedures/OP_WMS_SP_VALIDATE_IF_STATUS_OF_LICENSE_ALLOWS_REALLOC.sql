-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-03 @ Team REBORN - Sprint Collin
-- Description:	        Sp que valida si el estado de la licencia y el material permiete reubicacion

-- Modificacion 17-Jan-18 @ Nexus Team Sprint @Jumanji
					-- pablo.aguilar
					-- Se agrega retorno de objeto operacion

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_VALIDATE_IF_STATUS_OF_LICENCE_ALLOW_REALLOC
*/
-- =============================================
CREATE	 PROCEDURE [wms].[OP_WMS_SP_VALIDATE_IF_STATUS_OF_LICENSE_ALLOWS_REALLOC] (
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
		,@RESPUESTA VARCHAR(30)
		,@CODIGO INT = 0;

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
				@RESULT [Mensaje];
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
			SELECT @RESPUESTA = 'DE LICENCIA "'
				+ CAST(@LICENCE_ID AS VARCHAR) + '"',
				@CODIGO = 1401;
		END;
		ELSE
		BEGIN
			SELECT @RESPUESTA = 'DE SKU "'
				+ CAST(@MATERIAL_ID AS VARCHAR) + '"',
				@CODIGO = 1402;
		END;

		SET @RESULT = 'ESTADO, "' + @STATUS_NAME
			+ '", NO PERMITE REUBICACION ' + @RESPUESTA;
		SELECT
			@RESULT [Mensaje];

		SELECT
			-1 AS [Resultado]
			,@RESULT [Mensaje]
			,@CODIGO [Codigo]
			,CAST('' AS VARCHAR) [DbData];
	 

		RETURN -1;
	END;

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST('1' AS VARCHAR) [DbData];

	SELECT
		@RESULT [Mensaje];

END;