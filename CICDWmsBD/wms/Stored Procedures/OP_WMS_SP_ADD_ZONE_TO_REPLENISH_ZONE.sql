-- =============================================
-- Autor:					julian.chamale
-- Fecha de Creacion: 		27-Apr-17 @ ErgonTeam Ganondorf
-- Description:				Validar que no exista ya un registro igual, e insertar en la tabla OP_WMS_ZONE_TO_REPLENISH_IN_ZONE
   
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_ADD_ZONE_TO_REPLENISH_ZONE] @ZONE_ID = 1 , 
	@REPLENISH_ZONE_ID = 2
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_ZONE_TO_REPLENISH_ZONE]
	(
		@ZONE_ID INT
		,@REPLENISH_ZONE_ID INT
	)
AS
	BEGIN
		BEGIN TRY
			DECLARE	@ID INT;
		--
			INSERT	INTO [wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE]
					([ZONE_ID] ,[REPLENISH_ZONE_ID])
			VALUES
					(@ZONE_ID  -- ZONE_ID - int
						,@REPLENISH_ZONE_ID  -- REPLENISH_ZONE_ID - int
						);
		--
			SET @ID = SCOPE_IDENTITY();
		--
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CAST(@ID AS VARCHAR) [DbData];
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