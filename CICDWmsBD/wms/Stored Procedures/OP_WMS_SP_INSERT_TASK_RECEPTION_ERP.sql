-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	30-09-2016
-- Description:			Sp para insertar tareas tipo reception

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @TeamErgon Sprint 1
-- Description:			    se agrego columna PRIORITY y IS_FROM_ERP

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Agregan campos por intercompany

-- Modificacion 8/30/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se agrega el parametro @TRANSFER_REQUEST_ID

-- Autor:				Elder Lucas
-- Fecha de Creacion: 	19-Mayo-2021
-- Descripcion:			Se agregan los campos  "SOURCE_TYPE", "STATUS_CODE" al script para que sean insetados en la nueva tarea de recepcion

/*
	Ejemplo Ejecucion: 
    EXEC	[wms].[OP_WMS_SP_INSERT_TASK_RECEPTION_ERP]
		@TASK_SUBTYPE = 'GENERAL'
		,@TASK_OWNER = 'ADMIN'
		,@TASK_ASSIGNEDTO = 'MISAELT'
		,@TASK_COMMENTS = 'PRUEBA'
		,@REGIMEN = 'FISCAL'
		,@CLIENT_OWNER = 'wms'
		,@CLIENT_NAME = 'INDUSTRIAS ALIMENTICIAS KERNS Y CIA., S.C.A.'
		,@CODIGO_POLIZA_SOURCE = '01234'
		,@DOC_ID_SOURCE = NULL
		,@PRIORITY = 2
		,@IS_FROM_ERP = 1
		,@LOCATION_SPOT_TARGET = 'B11-R03-C09-ND'
		,@OWNER = 'arium'
		,@TRANSFER_REQUEST_ID = 0
		
 */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASK_RECEPTION_ERP] (
		@TASK_SUBTYPE VARCHAR(25)
		,@TASK_OWNER VARCHAR(25)
		,@TASK_ASSIGNEDTO VARCHAR(25)
		,@TASK_COMMENTS VARCHAR(150)
		,@REGIMEN VARCHAR(50)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@CODIGO_POLIZA_SOURCE VARCHAR(25)
		,@DOC_ID_SOURCE NUMERIC(18, 0) = NULL
		,@PRIORITY INT = 0
		,@IS_FROM_ERP INT = 0
		,@LOCATION_SPOT_TARGET VARCHAR(25) = ''
		,@OWNER VARCHAR(50)
		,@TRANSFER_REQUEST_ID INT = NULL
    , @SOURCE_TYPE VARCHAR(50) = NULL
	,@STATUS_CODE VARCHAR (30) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@ID INT;
	--
	BEGIN TRY
	    SELECT @CLIENT_NAME = [C].[CLIENT_NAME]
	    	FROM [wms].[OP_WMS_VIEW_CLIENTS] [C]
	    	WHERE [C].[CLIENT_CODE] = @CLIENT_OWNER;  
	    	--
	    	INSERT	INTO [wms].[OP_WMS_TASK_LIST]
	    			(
	    				[TASK_TYPE]
	    				,[TASK_SUBTYPE]
	    				,[TASK_OWNER]
	    				,[TASK_ASSIGNEDTO]
	    				,[TASK_COMMENTS]
	    				,[REGIMEN]
	    				,[IS_COMPLETED]
	    				,[IS_DISCRETIONAL]
	    				,[IS_PAUSED]
	    				,[IS_CANCELED]
	    				,[IS_ACCEPTED]
	    				,[CLIENT_OWNER]
	    				,[CLIENT_NAME]
	    				,[DOC_ID_SOURCE]
	    				,[ASSIGNED_DATE]
	    				,[QUANTITY_PENDING]
	    				,[QUANTITY_ASSIGNED]
	    				,[MATERIAL_ID]
	    				,[MATERIAL_NAME]
	    				,[BARCODE_ID]
	    				,[CODIGO_POLIZA_SOURCE]
	    				,[PRIORITY]
	    				,[IS_FROM_ERP]
	    				,[LOCATION_SPOT_TARGET]
						,[OWNER]
						,[TRANSFER_REQUEST_ID]
          ,[SOURCE_TYPE] 
		  ,[STATUS_CODE]
	    			)
	    	VALUES
	    			(
	    				'TAREA_RECEPCION'
	    				,@TASK_SUBTYPE
	    				,@TASK_OWNER
	    				,@TASK_ASSIGNEDTO
	    				,@TASK_COMMENTS
	    				,@REGIMEN
	    				,0
	    				,0
	    				,0
	    				,0
	    				,0
	    				,@CLIENT_OWNER
	    				,@CLIENT_NAME
	    				,@DOC_ID_SOURCE
	    				,GETDATE()
	    				,0
	    				,0
	    				,0
	    				,''
	    				,0
	    				,@CODIGO_POLIZA_SOURCE
	    				,@PRIORITY
	    				,@IS_FROM_ERP
	    				,@LOCATION_SPOT_TARGET
						  ,@OWNER
						  ,@TRANSFER_REQUEST_ID
              ,@SOURCE_TYPE
			  ,@STATUS_CODE
	    			);
	    	SET @ID = SCOPE_IDENTITY();
	    	--
	    	UPDATE [wms].[OP_WMS_TASK_LIST]
	    	SET	[TASK_COMMENTS] = 'TAREA DE RECEPCION NO. ' + +CAST(@ID AS VARCHAR)
	    	WHERE [SERIAL_NUMBER] = @ID;
	    	--
	    	SELECT
	    		1 AS [Resultado]
	    		,'Proceso Exitoso' [Mensaje]
	    		,0 [Codigo]
	    		,CONVERT(VARCHAR(16), @ID) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,0 [DbData];
	END CATCH
END;