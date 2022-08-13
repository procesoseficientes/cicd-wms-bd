-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		14-Jan-19 @ G-FORCE  Perezoso
-- Description:			    

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_CHANGE_QA_STATUS_TO_DEFAUL_BY_TASK] @TASK_ID = 718
	 , @LOGIN = 'PABS'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHANGE_QA_STATUS_TO_DEFAUL_BY_TASK] (
		@TASK_ID INT
		,@LOGIN VARCHAR(100)
	)
AS
BEGIN
	--
	DECLARE	@LICENSE_ID_ITERATE INT;
	BEGIN TRAN;
	BEGIN TRY

		SELECT		
		DISTINCT
			[L].[LICENSE_ID]
		INTO
			[#LICENSES_BY_TASK]
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [R] ON [L].[CODIGO_POLIZA] = CAST([R].[DOC_ID_POLIZA] AS VARCHAR)
		WHERE
			[R].[TASK_ID] = @TASK_ID;

			
	-- ------------------------------------------------------------------------------------
	-- RECORREMOS LAS LICENCIAS ASOCIADAS A LA TAREA PARA DESBLOQUEAR EL INVENTARIO
	-- ------------------------------------------------------------------------------------
		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#LICENSES_BY_TASK] ))
		BEGIN
			SELECT TOP 1
				@LICENSE_ID_ITERATE = [LICENSE_ID]
			FROM
				[#LICENSES_BY_TASK];
		-- ------------------------------------------------------------------------------------
		--DESBLOQUEAMOS EL INVENTARIO
		-- ------------------------------------------------------------------------------------
			UPDATE
				[s]
			SET	
				[s].[BLOCKS_INVENTORY] = [CDEF].[SPARE1]
				,[s].[DESCRIPTION] = [CDEF].[TEXT_VALUE]
				,[s].[STATUS_CODE] = [CDEF].[PARAM_NAME]
				,[s].[STATUS_NAME] = [CDEF].[PARAM_NAME]
				,[s].[COLOR] = [CDEF].[COLOR]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [il]
			INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [CQM] ON [CQM].[PARAM_GROUP] = 'ESTADOS'
											AND [CQM].[PARAM_TYPE] = 'ESTADO'
											AND [CQM].[NUMERIC_VALUE] = 2
			INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [s] ON [s].[STATUS_ID] = [il].[STATUS_ID]
											AND [s].[STATUS_CODE] = [CQM].[PARAM_NAME]
			INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [CDEF] ON [CDEF].[PARAM_GROUP] = 'ESTADOS'
											AND [CDEF].[PARAM_TYPE] = 'ESTADO'
											AND [CDEF].[NUMERIC_VALUE] = 1
			WHERE
				[il].[LICENSE_ID] = @LICENSE_ID_ITERATE;
			
		
		-- ------------------------------------------------------------------------------------
		-- ACTUALIZO EL ENCABEZADO DE LA LICENCIA
		-- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
			WHERE
				[LICENSE_ID] = @LICENSE_ID_ITERATE;

		-- ------------------------------------------------------------------------------------
		-- ELIMINO LA LICENCIA ITERADA DEL ARRAY
		-- ------------------------------------------------------------------------------------
			DELETE FROM
				[#LICENSES_BY_TASK]
			WHERE
				[LICENSE_ID] = @LICENSE_ID_ITERATE;

		END;

	

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' AS [Mensaje]
			,1 AS [Codigo]
			,'' AS [DbData];

		COMMIT;	

	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Despliega el error
		-- ------------------------------------------------------------------------------------
		ROLLBACK;
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
	
END;