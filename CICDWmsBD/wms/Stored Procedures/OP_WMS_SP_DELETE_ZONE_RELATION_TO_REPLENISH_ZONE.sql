
-- =============================================
-- Autor:					julian.chamale
-- Fecha de Creacion: 		27-Apr-17 @ ErgonTeam Ganondorf
-- Description:				Realizar un UPDATE en la tabla  OP_WMS_ZONE con los parámetros enviados por la ZONE_ID
   
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_DELETE_ZONE_RELATION_TO_REPLENISH_ZONE]
	@ZONE_ID = 3 , -- int
	@REPLENISH_ZONE_ID = 4 -- int
*/
-- =============================================<

--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_ZONE_RELATION_TO_REPLENISH_ZONE]
	@ZONE_ID INT
	,@REPLENISH_ZONE_ID INT
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE	@ROWS_AFFECTED INT;
		--
			DELETE FROM 
				[wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE]
			WHERE
				[ZONE_ID] = @ZONE_ID
			AND
				[REPLENISH_ZONE_ID] = @REPLENISH_ZONE_ID;
		--
			SET @ROWS_AFFECTED = @@ROWCOUNT;
		--
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CAST(@ROWS_AFFECTED AS VARCHAR) [DbData];
		END TRY
		BEGIN CATCH
			SELECT
				-1 AS [Resultado]
				,CASE CAST(@@ERROR AS VARCHAR)
					WHEN '2627' THEN ''
					ELSE ERROR_MESSAGE()
					END [Mensaje]
				,@@ERROR [Codigo]; 
		END CATCH;
	END;