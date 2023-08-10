-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:     22-07-2016
-- Description:          Valida si un poligono se traslapa con otro

-- Modificacion 21-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega el parametro IS_MULTISELLER

-- Modificacion 05-10-2017 @ Reborn Sprint Drache
					-- alberto.ruiz
					-- Se agrego la llamada del sp "[SWIFT_SP_ASSOCIATE_CUSTOMER_BY_POLYGON]"

/*
-- Ejemplo de Ejecucion:
        --
		EXEC [SONDA].[SWIFT_SP_VALIDATE_POLYGON]
			@POLYGON_ID  = 10
			,@PARENT_ID  = null
			,@POLYGON_TYPE = 'REGION'
			,@POLYGON_SUB_TYPE = NULL
		--
		EXEC [SONDA].[SWIFT_SP_VALIDATE_POLYGON]
			@POLYGON_ID  = 10
			,@PARENT_ID  = null
			,@POLYGON_TYPE = 'REGION'
			,@POLYGON_SUB_TYPE = NULL
			,@IS_MULTIPOLYGON = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATE_POLYGON (
		@POLYGON_ID INT
		,@PARENT_ID INT = NULL
		,@POLYGON_TYPE VARCHAR(250)
		,@POLYGON_SUB_TYPE VARCHAR(250) = NULL
		,@IS_MULTIPOLYGON INT = 0
		,@IS_MULTISELLER INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE
			@GEOMETRY_POLYGON_TO_COMPARE GEOMETRY
			,@GEOMETRY_POLYGON GEOMETRY
			,@vPOLYGON_ID INT
			,@vPOLYGON_NAME VARCHAR(250)
			,@POLYGON NVARCHAR(MAX) = '';

		-- ------------------------------------------------------------------------------------
		-- Valida si tiene que validar
		-- ------------------------------------------------------------------------------------
		IF @IS_MULTISELLER = 1
		BEGIN
			GOTO RESULTADO;
		END

		-- ------------------------------------------------------------------------------------
		-- Valida si el poligono tiene hijos 
		-- ------------------------------------------------------------------------------------
		IF [SONDA].[SWIFT_FN_VALIDATE_POLYGON_HAS_CHILD](@POLYGON_ID) = 1
		BEGIN
			SELECT
				-1 AS [RESULTADO]
				,'El poligono tiene poligonos hijos.' [MENSAJE]
				,@@ERROR [CODIGO];
			RETURN;
		END;

		-- ------------------------------------------------------------------------------------
		-- Se obtiene el poligono geometrico del poligono que se desea validar
		-- ------------------------------------------------------------------------------------
		SELECT @GEOMETRY_POLYGON_TO_COMPARE = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@POLYGON_ID);

		-- ------------------------------------------------------------------------------------
		-- Validar que si tiene padre, este contenido en el. 
		-- ------------------------------------------------------------------------------------
		IF @PARENT_ID IS NOT NULL
		BEGIN
			SELECT @GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@PARENT_ID);
			--
			IF @GEOMETRY_POLYGON.[STContains](@GEOMETRY_POLYGON_TO_COMPARE) = 0
			BEGIN
				SELECT
					-1 AS [RESULTADO]
					,'El poligono no esta contenido en el poligono padre.' [MENSAJE]
					,@@ERROR [CODIGO];
				RETURN;
			END;
		END;

		-- ------------------------------------------------------------------------------------
		-- Obtener todos los poligonos de su mismo tipo y de su mismo padre
		-- ------------------------------------------------------------------------------------
		SELECT
			[P].[POLYGON_ID]
			,[P].[POLYGON_NAME]
			,[P].[POLYGON_DESCRIPTION]
			,[P].[COMMENT]
			,[P].[LAST_UPDATE_BY]
			,[P].[LAST_UPDATE_DATETIME]
			,[P].[POLYGON_ID_PARENT]
			,[P].[POLYGON_TYPE]
			,[P].[SUB_TYPE]
		INTO [#POLYGONS]
		FROM [SONDA].[SWIFT_POLYGON] [P]
		WHERE [P].[POLYGON_TYPE] = @POLYGON_TYPE
			AND (
					@PARENT_ID IS NULL
					OR [P].[POLYGON_ID_PARENT] = @PARENT_ID
				)
			AND (
					[P].[SUB_TYPE] = @POLYGON_SUB_TYPE
					OR @POLYGON_SUB_TYPE IS NULL
				)
			AND [P].[POLYGON_ID] <> @POLYGON_ID
			AND [P].[IS_MULTISELLER] = @IS_MULTISELLER;

		-- ------------------------------------------------------------------------------------
		-- Inicia Ciclo
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1 1 FROM [#POLYGONS] )
		BEGIN
			SELECT TOP 1
				@vPOLYGON_ID = [POLYGON_ID]
				,@vPOLYGON_NAME = [POLYGON_NAME]
			FROM [#POLYGONS]
			ORDER BY [POLYGON_ID_PARENT] ASC;
			--
			SET @GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@vPOLYGON_ID);

			-- ------------------------------------------------------------------------------------
			-- Validar que su poligono no intersecte al nuevo.
			-- ------------------------------------------------------------------------------------
			IF @GEOMETRY_POLYGON.[STIntersects](@GEOMETRY_POLYGON_TO_COMPARE) = 1
			BEGIN
				SELECT
					-1 AS [RESULTADO]
					,'El poligono intersecta a otro de su mismo tipo.' [MENSAJE]
					,@@ERROR [CODIGO];
				RETURN;
			END;
			--
			DELETE FROM [#POLYGONS] WHERE [POLYGON_ID] = @vPOLYGON_ID;
		END;

		-- ------------------------------------------------------------------------------------
		-- Finaliza Ciclo
		-- ------------------------------------------------------------------------------------
		RESULTADO:

    EXEC [SONDA].[SWIFT_SP_ASSOCIATE_CUSTOMER_BY_POLYGON] @POLYGON_ID = @POLYGON_ID
    
		SELECT
			1 AS [RESULTADO]
			,'Proceso Exitoso' [MENSAJE]
			,0 [CODIGO]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [RESULTADO]
			,ERROR_MESSAGE() [MENSAJE]
			,@@ERROR [CODIGO];
	END CATCH;
END;
