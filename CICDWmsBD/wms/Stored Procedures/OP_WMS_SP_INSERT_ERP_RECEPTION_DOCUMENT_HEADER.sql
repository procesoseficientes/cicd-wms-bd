-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		2017-01-13 TeamErgon Sprint 1
-- Description:			      Sp que inserta en tabla OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 Se guarda tanto docNum como docEntry

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Agregan campos por intercompany

-- Modificacion 19/9/2017 @ Reborn-Team Sprint Collin
					-- rudi.garcia
					-- Se agrego [LOCKED_BY_INTERFACES] 

-- Modificacion 10/11/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega parametro @SOURCE

-- Modificacion 12/14/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agrega columna de doc_entry

-- Modificacion 1/26/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agrega parametros de recepcion de wms

-- Modificacion 10-Jul-19 @  G-FORCE Team Sprint Dublin 
					-- pablo.aguilar
					-- Se modificá para utilizar docnum, doc_entry y erp_doc como varchar

/*	
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_INSERT_ERP_RECEPTION_DOCUMENT_HEADER]
			@DOC_ID = 0
			,@TYPE = 'RECEPCION'
			,@CODE_SUPPLIER = '46513'
			,@CODE_CLIENT = 'wms'
			,@LAST_UPDATE_BY = 'AMADO'
			,@TASK_ID = 89498
			,@EXTERNAL_SOURCE_ID = 1
			,@IS_COMPLETE = 0 
			,@DOC_NUM = '123123'
			,@NAME_SUPPLIER = 'PRUEBA'
			,@OWNER = 'arium'
			,@SOURCE = 'PURCHASE_ORDER'
--
		SELECT * FROM [wms].OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_ERP_RECEPTION_DOCUMENT_HEADER] (
		@DOC_ID VARCHAR(50)
		,@TYPE VARCHAR(25)
		,@CODE_SUPPLIER VARCHAR(50) = NULL
		,@CODE_CLIENT VARCHAR(50) = NULL
		,@LAST_UPDATE_BY VARCHAR(50)
		,@TASK_ID INT
		,@EXTERNAL_SOURCE_ID INT
		,@IS_COMPLETE INT
		,@DOC_NUM VARCHAR(200)
		,@NAME_SUPPLIER VARCHAR(100)
		,@OWNER VARCHAR(50)
		,@SOURCE VARCHAR(50)
		,@ERP_WAREHOUSE_CODE VARCHAR(50) = NULL
		,@DOC_ID_POLIZA INT = NULL
		,@DOC_ENTRY VARCHAR(50) = ''
		,@ADDRESS VARCHAR(250) = NULL
		,@DOC_CURRENCY VARCHAR(50) = NULL
		,@DOC_RATE NUMERIC(18, 6) = NULL
		,@SUBSIDIARY VARCHAR(250) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@ID INT;
	--
	BEGIN TRY
		INSERT	INTO [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
				(
					[DOC_ID]
					,[TYPE]
					,[CODE_SUPPLIER]
					,[CODE_CLIENT]
					,[ERP_DATE]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[ATTEMPTED_WITH_ERROR]
					,[IS_POSTED_ERP]
					,[POSTED_ERP]
					,[POSTED_RESPONSE]
					,[ERP_REFERENCE]
					,[IS_AUTHORIZED]
					,[IS_COMPLETE]
					,[TASK_ID]
					,[EXTERNAL_SOURCE_ID]
					,[DOC_NUM]
					,[NAME_SUPPLIER]
					,[OWNER]
					,[LOCKED_BY_INTERFACES]
					,[IS_FROM_ERP]
					,[SOURCE]
					,[ERP_WAREHOUSE_CODE]
					,[DOC_ID_POLIZA]
					,[DOC_ENTRY]
					,[ADDRESS]
					,[DOC_CURRENCY]
					,[DOC_RATE]
					,[SUBSIDIARY]
				)
		VALUES
				(
					@DOC_ID
					,@TYPE
					,@CODE_SUPPLIER
					,@CODE_CLIENT
					,GETDATE()
					,GETDATE()
					,@LAST_UPDATE_BY
					,DEFAULT
					,DEFAULT
					,GETDATE()
					,''
					,''
					,DEFAULT
					,@IS_COMPLETE
					,@TASK_ID
					,@EXTERNAL_SOURCE_ID
					,@DOC_NUM
					,@NAME_SUPPLIER
					,@OWNER
					,1
					,1
					,@SOURCE
					,@ERP_WAREHOUSE_CODE
					,@DOC_ID_POLIZA
					,@DOC_ENTRY
					,@ADDRESS
					,@DOC_CURRENCY
					,@DOC_RATE
					,@SUBSIDIARY
				);
		--
		SET @ID = SCOPE_IDENTITY();
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
			,@@ERROR [Codigo];
	END CATCH;
END;