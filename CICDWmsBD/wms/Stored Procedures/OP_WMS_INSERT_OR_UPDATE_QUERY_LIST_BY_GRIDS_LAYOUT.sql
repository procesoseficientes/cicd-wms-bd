-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	16-05-2018 @ G-Force Sprint Caribú
-- Description:			Se que inserta o actualiza el layout del grid

/*
-- Ejemplo de Ejecucion:
		EXEC [wms].SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_FAMILY
		@PROMO_ID = 2114
		,@XML = ''
		,@LOGIN_ID = 'GERENTE@wms'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_INSERT_OR_UPDATE_QUERY_LIST_BY_GRIDS_LAYOUT] (
		@QUERY_LIST_ID INT
		,@LOGIN_ID VARCHAR(50)
		,@LAYOUT_XML XML
	)
AS
BEGIN
	BEGIN TRY

		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_QUERY_LIST_BY_GRIDS_LAYOUT]
						WHERE
							[QUERY_LIST_ID] = @QUERY_LIST_ID
							AND [LOGIN_ID] = @LOGIN_ID )
		BEGIN
			INSERT	INTO [wms].[OP_WMS_QUERY_LIST_BY_GRIDS_LAYOUT]
					(
						[QUERY_LIST_ID]
						,[LOGIN_ID]
						,[LAYOUT_XML]
					)
			VALUES
					(
						@QUERY_LIST_ID
						,@LOGIN_ID
						,@LAYOUT_XML
					);
		END;
		ELSE
		BEGIN
			UPDATE
				[wms].[OP_WMS_QUERY_LIST_BY_GRIDS_LAYOUT]
			SET	
				[LAYOUT_XML] = @LAYOUT_XML
			WHERE
				[QUERY_LIST_ID] = @QUERY_LIST_ID
				AND [LOGIN_ID] = @LOGIN_ID;
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje];    

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;


END;