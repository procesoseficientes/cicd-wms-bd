-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		01-Dec-17 @ Nexus Team Sprint GTA
-- Description:			    Se agrega parámetro opcional de licencia.

/*
-- Ejemplo de Ejecucion:
       
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREA_LICENCIA]
	-- Add the parameters for the stored procedure here
	@pCODIGO_POLIZA			varchar(25),
	@pLOGIN					varchar(25),
	@pLICENCIA_ID			NUMERIC(18,0) OUTPUT,
	@pCLIENT_OWNER			varchar(25),
	@pREGIMEN				varchar(50),
	@pResult				varchar(250) OUTPUT,
	@pTaskId				NUMERIC(18,0) = NULL,
	@LOCATION				VARCHAR(25) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
		
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT,
	@WAREHOUSE VARCHAR(50) = NULL ;
	
	BEGIN TRY
			
		BEGIN

		SELECT @WAREHOUSE = [WAREHOUSE_PARENT] FROM [wms].[OP_WMS_SHELF_SPOTS] WHERE [LOCATION_SPOT] = @LOCATION
		
		--BEGIN TRANSACTION
		IF  ((@pTaskId IS NOT NULL) AND NOT EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_TASK_LIST] [TL] WHERE [TL].[SERIAL_NUMBER] = @pTaskId AND [TL].[TASK_ASSIGNEDTO] =@pLOGIN))
		BEGIN
			RAISERROR ('Tarea ya fue asinada a otro operador.', 16, 1)

		END
		
		INSERT INTO [wms].[OP_WMS_LICENSES]
			(
			[CODIGO_POLIZA]
		   ,[CLIENT_OWNER]
           ,CURRENT_WAREHOUSE
           ,CURRENT_LOCATION
           ,LAST_LOCATION
           ,[LAST_UPDATED]
           ,[LAST_UPDATED_BY], REGIMEN
		   )				
		VALUES
           (@pCODIGO_POLIZA
           ,@pCLIENT_OWNER
           , ISNULL( @WAREHOUSE,  (SELECT DEFAULT_WAREHOUSE_ID FROM [wms].OP_WMS_LOGINS WHERE LOGIN_ID = @pLOGIN))
           , ISNULL (@LOCATION, (SELECT DEFAULT_RECEPTION_LOCATION FROM [wms].OP_WMS_WAREHOUSES WHERE WAREHOUSE_ID IN 
				(SELECT DEFAULT_WAREHOUSE_ID FROM [wms].OP_WMS_LOGINS WHERE LOGIN_ID = @pLOGIN)
			))
           ,NULL
           ,CURRENT_TIMESTAMP
           ,@pLOGIN, @pREGIMEN)

		
			SELECT	@pResult	= 'OK'
			
			--SELECT @pLICENCIA_ID = (SELECT IDENT_CURRENT('[wms].OP_WMS_LICENSES'))
			SELECT @pLICENCIA_ID = @@IDENTITY


				--RECORD THE REALLOC
		 INSERT INTO [wms].[OP_WMS_REALLOCS_X_LICENSE]
           ([LICENSE_ID]
           ,[SOURCE_LOCATION]
           ,[TARGET_LOCATION]
           ,[TRANS_TYPE]
           ,[LAST_UPDATED]
           ,[LAST_UPDATED_BY])
		 VALUES
			   (@pLICENCIA_ID
			   ,NULL
			   ,(SELECT DEFAULT_WAREHOUSE_ID FROM [wms].OP_WMS_LOGINS WHERE LOGIN_ID = @pLOGIN)
			   ,'CREATED'
			   ,CURRENT_TIMESTAMP
			   ,@pLOGIN)


	
			IF(@pCODIGO_POLIZA = '') BEGIN
				
				UPDATE	[wms].OP_WMS_LICENSES 
				SET		CODIGO_POLIZA	= 'INIALMGEN'  --CONVERT(VARCHAR(20), @pLICENCIA_ID)
				WHERE	LICENSE_ID		= @pLICENCIA_ID
			
				IF @@ROWCOUNT = 0 BEGIN
					--ROLLBACK TRANSACTION	
					SELECT	@pResult	= 'NO ACTUALIZO LICENCIA: ' + CONVERT(VARCHAR(20), @pLICENCIA_ID)
					RETURN -1
				END
				
				UPDATE [wms].OP_WMS_POLIZA_HEADER SET STATUS = 'ON_PROCESS',
				LAST_UPDATED			= CURRENT_TIMESTAMP,
				LAST_UPDATED_BY			= @pLOGIN
				WHERE CODIGO_POLIZA		= 'INIALMGEN' --CONVERT(VARCHAR(20), @pLICENCIA_ID)
				
			END 
			ELSE BEGIN
				UPDATE [wms].OP_WMS_POLIZA_HEADER SET STATUS = 'ON_PROCESS',
				LAST_UPDATED = CURRENT_TIMESTAMP,
				LAST_UPDATED_BY = @pLOGIN
				WHERE CODIGO_POLIZA = @pCODIGO_POLIZA
			END
			
			--COMMIT TRANSACTION			
			SELECT
				1 AS Resultado
				,'Proceso Exitoso' Mensaje
				,0 Codigo
				,CAST(@pLICENCIA_ID AS VARCHAR) DbData
		END

	END TRY
	BEGIN CATCH
		--ROLLBACK TRANSACTION
		SELECT	@pResult	= ERROR_MESSAGE()
		SELECT
			-1 AS Resultado
			,ERROR_MESSAGE() Mensaje
			,@@error Codigo
			,'' DbData
	END CATCH
   
END