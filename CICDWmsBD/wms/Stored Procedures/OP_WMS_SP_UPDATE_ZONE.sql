-- =============================================
-- Autor:					julian.chamale
-- Fecha de Creacion: 		27-Apr-17 @ ErgonTeam Ganondorf
-- Description:				Realizar un UPDATE en la tabla  OP_WMS_ZONE con los parámetros enviados por la ZONE_ID
   
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_UPDATE_ZONE] 
	@ZONE_ID = 1 , -- int
	@ZONE = 'PRINCIPAL' , -- varchar(50)
	@DESCRIPTION = 'Zona de prueba' , -- varchar(100)
	@WAREHOUSE_CODE = 'BODEGA_01' , -- varchar(25)
	@EXPLODE_MATERIALS_IN_REALLOC = 1 , -- int
	@LINE_ID = 'LINEA_O1' -- varchar(25)
*/
-- =============================================

--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_ZONE]
		@ZONE_ID INT
		,@ZONE VARCHAR(50)
		,@DESCRIPTION VARCHAR(100)
		,@WAREHOUSE_CODE VARCHAR(25)
		,@EXPLODE_MATERIALS_IN_REALLOC INT
		,@LINE_ID VARCHAR(25)
AS
  BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE	@ROWS_AFFECTED INT;
		--
			UPDATE [wms].[OP_WMS_ZONE] SET
				[ZONE] = @ZONE,
				[DESCRIPTION] = @DESCRIPTION,
				[WAREHOUSE_CODE] = @WAREHOUSE_CODE,
				[RECEIVE_EXPLODED_MATERIALS] = @EXPLODE_MATERIALS_IN_REALLOC,
				[LINE_ID] = @LINE_ID
			WHERE
				[ZONE_ID] = @ZONE_ID
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