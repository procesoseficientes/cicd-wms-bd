
-- Modificacion 1/25/2017 @ A-Team Sprint Bankole
					-- rodrigo.gomez
					-- Se agrego campo is online

-- Modificacion 		12/14/2018 @ G-Force Team Sprint OsoPolar
-- Autor: 				diego.as
-- Historia/Bug:		Product Backlog Item 26125: Transferencias de Productos que no van en el inicio de Ruta
-- Descripcion: 		12/14/2018 - Se agregan parametros @SELLER_ROUTE, @CODE_WAREHOUSE_TARGET

CREATE PROC [SONDA].[SWIFT_SP_INSERT_TRANSFER_HEADER]
	@SELLER_CODE VARCHAR(50)
	,@SELLER_ROUTE VARCHAR(50)
	,@CODE_WAREHOUSE_TARGET VARCHAR(50)
	,@CODE_WAREHOUSE_SOURCE VARCHAR(50)
	,@STATUS VARCHAR(20)
	,@LAST_UPDATE_BY VARCHAR(50)
	,@COMMENT VARCHAR(250)
	,@IS_ONLINE INT
AS
	BEGIN TRY
		DECLARE
			@return_value INT
			,@pID NUMERIC(18 ,0);
		EXEC @return_value = [SONDA].[SWIFT_SP_GET_NEXT_SEQUENCE] @SEQUENCE_NAME = N'TRANSFER' ,
			@pResult = @pID OUTPUT;
			
		INSERT	INTO [SONDA].[SWIFT_TRANSFER_HEADER]
				(
					[TRANSFER_ID]
					,[SELLER_CODE]
					,[SELLER_ROUTE]
					,[CODE_WAREHOUSE_SOURCE]
					,[CODE_WAREHOUSE_TARGET]
					,[STATUS]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[COMMENT]
					,[IS_ONLINE]
					,[CREATION_DATE]
				)
		VALUES
				(
					@pID
					,@SELLER_CODE
					,@SELLER_ROUTE
					,@CODE_WAREHOUSE_SOURCE
					,@CODE_WAREHOUSE_TARGET
					,@STATUS
					,GETDATE()
					,@LAST_UPDATE_BY
					,@COMMENT
					,@IS_ONLINE
					,GETDATE()
				);			

	
		IF @@ERROR = 0
		BEGIN		
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CONVERT(VARCHAR(50) ,@pID) [DbData];
		END;		
		ELSE
		BEGIN
		
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo];
		END;

	END TRY
	BEGIN CATCH     
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
