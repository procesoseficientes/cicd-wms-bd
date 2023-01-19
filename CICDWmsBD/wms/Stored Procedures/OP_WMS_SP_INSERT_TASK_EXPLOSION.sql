-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	30-09-2016
-- Description:			Sp para insertar tareas tipo reception

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @TeamErgon Sprint 1
-- Description:			    se agrego columna PRIORITY y IS_FROM_ERP

-- Modificacion 23-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se modifica si enviará a ERP para crear sus documentos 

-- Modificacion 29-Ene-18 @ Reborn Sprint Trotzdem
					-- marvin.solares
					-- Se modifica para que el parametro @PRIORITY tenga default 1

-- Modificacion 15-Feb-2018 @ Reborn Sprint Ulrich
			-- rudi.garcia
			-- Se agrego el objeto Operacion para que lo retornara y se elimino esto "Select @ID ID"

-- Modificacion 20180811 GForce@Jaguarundi
-- marvin.solares
-- se modifica sp para que reciba el tipo de recepcion rfc

-- Modificacion:		henry.rodriguez
-- Fecha:				06-SEPTIEMBRE-2019
-- Descripcion:			Se agrega OrderNumber en insert de la taskList, se obtiene del encabezado de la poliza.

-- Modificacion:		gustavo.garcia
-- Fecha:				07-15-2022
-- Descripcion:			se crea para generar tarea en explosiones manuales de HH a base de [OP_WMS_SP_INSERT_TASK_EXPLOSION]

/*
	Ejemplo Ejecucion: 
    EXEC	[wms].[OP_WMS_SP_INSERT_TASK_EXPLOSION]
		@TASK_SUBTYPE = 'GENERAL'
		,@TASK_OWNER = 'ADMIN'
		,@TASK_ASSIGNEDTO = 'MISAELT'
		,@TASK_COMMENTS = 'PRUEBA'
		,@REGIMEN = 'FISCAL'
		,@CLIENT_OWNER = 'C01096'
		,@CLIENT_NAME = 'INDUSTRIAS ALIMENTICIAS KERNS Y CIA., S.C.A.'
		,@CODIGO_POLIZA_SOURCE = '01234'
    ,@DOC_ID_SOURCE = NULL
    ,@PRIORITY = 2
    ,@IS_FROM_ERP = 1
    ,@LOCATION_SPOT_TARGET = 'B11-R03-C09-ND'

		
 */
-- =============================================
create PROCEDURE [wms].[OP_WMS_SP_INSERT_TASK_EXPLOSION] (
		@TASK_SUBTYPE VARCHAR(25)
		,@TASK_OWNER VARCHAR(25)
		,@TASK_ASSIGNEDTO VARCHAR(25)
		,@TASK_COMMENTS VARCHAR(150)
		,@REGIMEN VARCHAR(50)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@CODIGO_POLIZA_SOURCE VARCHAR(25)
		,@DOC_ID_SOURCE NUMERIC(18, 0) = NULL
		,@PRIORITY INT = 1
		,@IS_FROM_ERP INT = 0
		,@LOCATION_SPOT_TARGET VARCHAR(25) = ''
		,@SEND_TO_ERP INT = 0
		,@RECEPTION_TYPE_ERP VARCHAR(50)
	)
AS
BEGIN
	DECLARE
		@ID INT
		,@EXTERNAL_SOURCE_ID INT
		,@OWNER VARCHAR(25)
		,@ORDER_NUMBER VARCHAR(25);
	--

	-- ------------------------------------------------------------------------------------
	-- OBTENEMOS EL NUMERO DE ORDEN QUE SE INGRESO, NUMERO DE REFERENCIA.
	-- ------------------------------------------------------------------------------------
		SELECT
			@ORDER_NUMBER = [NUMERO_ORDEN]
		FROM
			[wms].[OP_WMS_POLIZA_HEADER]
		WHERE
			[CODIGO_POLIZA] = @CODIGO_POLIZA_SOURCE;

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
				,[ORDER_NUMBER]				
			)
	VALUES
			(
				'EXPLOSION MANUAL'
				,@TASK_SUBTYPE
				,@TASK_OWNER
				,@TASK_ASSIGNEDTO
				,@TASK_COMMENTS
				,@REGIMEN
				,1
				,0
				,0
				,0
				,1
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
				,CASE	WHEN @SEND_TO_ERP = 1 THEN 1
						ELSE @IS_FROM_ERP
					END
				,@LOCATION_SPOT_TARGET
				,@ORDER_NUMBER				
			);
	SET @ID = SCOPE_IDENTITY();
	--

	UPDATE
		[wms].[OP_WMS_TASK_LIST]
	SET	
		[TASK_COMMENTS] = 'TAREA DE EXPLOSION MANUAL NO. '
		+ CAST(@ID AS VARCHAR)
	WHERE
		[SERIAL_NUMBER] = @ID;
	
	
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CONVERT(VARCHAR(16), @ID) [DbData];

END;