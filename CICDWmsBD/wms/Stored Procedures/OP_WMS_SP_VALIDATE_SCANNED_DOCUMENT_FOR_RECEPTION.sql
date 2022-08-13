-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/30/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Valida el codigo del documento ingresado y la bodega asociada al login del usuario y devuelve el tipo de este conjunto a su ID. 

-- Modificacion 14-Dec-17 @ Nexus Team Sprint HeYouPikachu!
					-- pablo.aguilar
					-- Se realiza la validación de bodegas unicamente en solicitud de transferencia. 
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_SCANNED_DOCUMENT_FOR_RECEPTION] 
					@DOCUMENT = 'MC-48', -- varchar(100)
					@LOGIN = 'JCRUZTGU' -- varchar(25)


-- Modificación: Elder Lucas
-- Fecha Modificación: 1 de julio 2022
-- Descripción: Se identifican picking del traslado que no hayan sido enviado al ERP


   select *   FROM [OP_WMS_ALZA].[wms].[OP_WMS_MANIFEST_HEADER] where [MANIFEST_HEADER_ID]=2087 ORDER BY 1 DESC
   exec wms.OP_WMS_SP_VALIDATE_SCANNED_DOCUMENT_FOR_RECEPTION @DOCUMENT = N'MC-2087', @LOGIN = N'JCRUZTGU'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_SCANNED_DOCUMENT_FOR_RECEPTION](
	@DOCUMENT VARCHAR(100)
	,@LOGIN  VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DOCUMENT_TYPE VARCHAR(50)
		,@DOCUMENT_ID VARCHAR(50)
		,@WAREHOUSE_TO VARCHAR(50)
		,@MANIFEST_TYPE VARCHAR(50)
		,@PICKING_NOT_IN_ERP VARCHAR(MAX) = 'Los siguientes picking no han sido envidos a ERP: '
		,@CURRENT_NOT_IN_ERP_PICKING_DOCUMENT INT = NULL;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene todos los parametros de prefijo de documentos.
		-- ------------------------------------------------------------------------------------
		SELECT [PARAMETER_ID] [DOCUMENT]
				,[VALUE] [PREFIX]
		INTO [#PREFIX]
		FROM [wms].[OP_WMS_PARAMETER] 
		WHERE [GROUP_ID] = 'PREFIX'
		-- ------------------------------------------------------------------------------------
		-- Verifica que, al documento ingresado, su prefijo exista en los parametros, si no existe envia un error.
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS (SELECT TOP 1 1 
			FROM  [wms].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') [SPL]
				INNER JOIN [#PREFIX] [P] ON [P].[PREFIX] = [SPL].[VALUE])
		BEGIN
			SELECT -1 [Resultado]
				,'Id de documento invalido.' [Mensaje]
				,1501 [Codigo]
			RETURN
		END
		-- ------------------------------------------------------------------------------------
		-- Llena las variables de @DOCUMENT_TYPE y @DOCUMENT_ID
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @DOCUMENT_TYPE = [P].[DOCUMENT]
		FROM  [wms].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') [SPL]
			INNER JOIN [#PREFIX] [P] ON [P].[PREFIX] = [SPL].[VALUE]
		--
		SELECT TOP 1 @DOCUMENT_ID = [VALUE]
		FROM [wms].[OP_WMS_FN_SPLIT](@DOCUMENT,'-') 
		ORDER BY [ID] DESC	
		--
		IF @DOCUMENT_TYPE = 'CARGO_MANIFEST'
		BEGIN

		--select distinct TL.WAVE_PICKING_ID  into #PICKING_DOCUMENTS from wms.OP_WMS_TASK_LIST TL
		--inner join wms.OP_WMS_TRANSFER_REQUEST_HEADER TRH on TL.TRANSFER_REQUEST_ID = TRH.TRANSFER_REQUEST_ID
		--inner join wms.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH ON PDH.WAVE_PICKING_ID = TL.WAVE_PICKING_ID
		--where TRH.TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID AND PDH.IS_FROM_ERP = 1 AND PDH.IS_POSTED_ERP = 0


		select distinct TL.WAVE_PICKING_ID into #PICKING_DOCUMENTS from wms.OP_WMS_TASK_LIST TL
		inner join wms.OP_WMS_TRANSFER_REQUEST_HEADER TRH on TL.TRANSFER_REQUEST_ID = TRH.TRANSFER_REQUEST_ID
		inner join wms.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH ON PDH.WAVE_PICKING_ID = TL.WAVE_PICKING_ID
		inner join wms.OP_WMS_MANIFEST_HEADER MH ON MH.TRANSFER_REQUEST_ID = TRH.TRANSFER_REQUEST_ID
		WHERE mh.MANIFEST_HEADER_ID = @DOCUMENT_ID AND PDH.IS_FROM_ERP = 1 AND PDH.IS_POSTED_ERP = 0


		
		--IF EXISTS(SELECT TOP 1 1 FROM #PICKING_DOCUMENTS)
		WHILE EXISTS(SELECT TOP 1 1 FROM #PICKING_DOCUMENTS)
		BEGIN
			SET @CURRENT_NOT_IN_ERP_PICKING_DOCUMENT = (SELECT TOP 1 WAVE_PICKING_ID FROM #PICKING_DOCUMENTS)
			SELECT @PICKING_NOT_IN_ERP = CONCAT(@PICKING_NOT_IN_ERP, CAST(@CURRENT_NOT_IN_ERP_PICKING_DOCUMENT AS VARCHAR))
			SELECT @PICKING_NOT_IN_ERP = CONCAT(@PICKING_NOT_IN_ERP, ',')
			DELETE FROM #PICKING_DOCUMENTS WHERE WAVE_PICKING_ID = @CURRENT_NOT_IN_ERP_PICKING_DOCUMENT
		END;
		--END;
		--

		IF(@CURRENT_NOT_IN_ERP_PICKING_DOCUMENT IS NOT NULL)
		BEGIN
			--SET @Codigo = 1506;
            RAISERROR(@PICKING_NOT_IN_ERP,16,1);
            RETURN;
		END;


			
			-- ------------------------------------------------------------------------------------
			-- Verifica que el manifiesto de carga exista select * FROM [wms].[OP_WMS_MANIFEST_HEADER]
			-- ------------------------------------------------------------------------------------
			IF NOT EXISTS (SELECT TOP 1 1 FROM [wms].[OP_WMS_MANIFEST_HEADER] 
			WHERE MANIFEST_HEADER_ID = @DOCUMENT_ID )
			BEGIN
				SELECT -1 [Resultado]
					,'El documento no existe.' [Mensaje]
					,1502 [Codigo]
				RETURN
			END
			IF  EXISTS (SELECT TOP 1 1 FROM [wms].[OP_WMS_MANIFEST_HEADER] 
			WHERE MANIFEST_HEADER_ID = @DOCUMENT_ID AND STATUS='VALIDATED')
			BEGIN
				SELECT -1 [Resultado]
					,'Ya fue utilizado.' [Mensaje]
					,1503 [Codigo]
				RETURN
			END

			SELECT @MANIFEST_TYPE = [MANIFEST_TYPE] FROM [wms].[OP_WMS_MANIFEST_HEADER] WHERE [MANIFEST_HEADER_ID] = @DOCUMENT_ID
			-- ------------------------------------------------------------------------------------
			-- Si es un documento de manifiesto de carga, verifica que la bodega destino de la solicitud de traslado este asignada al usuario, de lo contrario devuelve un error.
			-- ------------------------------------------------------------------------------------
			IF @MANIFEST_TYPE = 'TRANSFER_REQUEST' AND  NOT EXISTS (SELECT TOP 1 1
				FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
					INNER JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] ON [TH].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
					INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WBU] ON [TH].[WAREHOUSE_TO] = [WBU].[WAREHOUSE_ID]
				WHERE [WBU].[LOGIN_ID] = @LOGIN AND [MH].[MANIFEST_HEADER_ID] = @DOCUMENT_ID )
			BEGIN
				SELECT -1 [Resultado]
					,'La bodega destino de la solicitud de traslado no esta asociada al operador.' [Mensaje]
					,1503 [Codigo]
				RETURN
			END
		END
		UPDATE [wms].[OP_WMS_MANIFEST_HEADER] SET STATUS='VALIDATED'
		WHERE [MANIFEST_HEADER_ID] = @DOCUMENT_ID
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado , 
			'Proceso Exitoso' Mensaje ,  
			@DOCUMENT_ID Codigo, 
			@DOCUMENT_TYPE + '|' + CAST(@DOCUMENT_ID AS VARCHAR) DbData
		--
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
GO

