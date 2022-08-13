
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_ZONE]
	(
		@ZONE VARCHAR(50)
		,@DESCRIPTION VARCHAR(100)
		,@WAREHOUSE_CODE VARCHAR(25)
		,@EXPLODE_MATERIALS_IN_REALLOC INT
		,@LINE_ID VARCHAR(25)
	)
AS
	BEGIN
		BEGIN TRY
			DECLARE	@ID INT;
		--
			INSERT	INTO [wms].[OP_WMS_ZONE]
					(
						[ZONE]
						,[DESCRIPTION]
						,[WAREHOUSE_CODE]
						,[RECEIVE_EXPLODED_MATERIALS]
						,[LINE_ID]
					)
			VALUES
					(
						@ZONE  -- ZONE - varchar(50)
						,@DESCRIPTION  -- DESCRIPTION - varchar(100)
						,@WAREHOUSE_CODE
						,@EXPLODE_MATERIALS_IN_REALLOC  -- RECEIVE_EXPLODED_MATERIALS - int
						,@LINE_ID
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