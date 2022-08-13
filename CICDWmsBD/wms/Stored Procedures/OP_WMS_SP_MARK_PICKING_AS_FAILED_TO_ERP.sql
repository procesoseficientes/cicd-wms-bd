
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que marca un picking wms fallido

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se agrego el parametro @POSTED_STATUS

-- Modificacion 8/10/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se manda el mensaje de error al detalle.
/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_ERP]
				@PICKING_DEMAND_HEADER_ID = 6262
				,@POSTED_RESPONSE = 'Error de sap'
				,@POSTED_STATUS = -1
				,@OWNER = 'motorganica'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_PICKING_AS_FAILED_TO_ERP] (
		@PICKING_DEMAND_HEADER_ID INT
		,@POSTED_RESPONSE VARCHAR(500)
		,@POSTED_STATUS INT
		,@OWNER VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY
		DECLARE	@INTERNAL_SALE_COMPANIES VARCHAR(50);
    -- ------------------------------------------------------------------------------------
    -- Obtiene las compañias compraventa y crea la tabla temporal [#PEROFRMS_INTERNAL_SALE]
    -- ------------------------------------------------------------------------------------
		SELECT
			@INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS]
		WHERE
			[PARAM_GROUP] = 'INTERCOMPANY'
			AND [PARAM_NAME] = 'INTERNAL_SALE';
    --
		SELECT TOP 5
			CASE	WHEN [ISC].[VALUE] IS NULL THEN 0
					ELSE 1
			END [PERFORMS_INTERNAL_SALE]
			,[PDH].[PICKING_DEMAND_HEADER_ID]
		INTO
			[#PERFORMS_INTERNAL_SALE]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		LEFT JOIN [wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES,
											'|') [ISC] ON ([ISC].[VALUE] = (CASE [PDH].[OWNER]
											WHEN NULL
											THEN CASE [PDH].[SELLER_OWNER]
											WHEN NULL
											THEN [PDH].[CLIENT_OWNER]
											ELSE [PDH].[SELLER_OWNER]
											END
											ELSE [PDH].[OWNER]
											END))
		WHERE
			[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
    -- ------------------------------------------------------------------------------------
    -- Actualiza encabezado
    -- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		SET	
			[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = 'INTERFACE'
			,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR]
			+ 1
			,[POSTED_STATUS] = @POSTED_STATUS
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[IS_POSTED_ERP] = -1
			,[IS_SENDING] = 0
		WHERE
			[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
    -- ------------------------------------------------------------------------------------
    -- Actualiza Detalle
    -- ------------------------------------------------------------------------------------
		UPDATE
			[DD]
		SET	
			[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR]
			+ 1
			,[POSTED_STATUS] = @POSTED_STATUS
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[IS_POSTED_ERP] = -1
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
		INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS] ON [PIS].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
		WHERE
			[DD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
			AND (
					[PIS].[PERFORMS_INTERNAL_SALE] = 1
					OR [DD].[MATERIAL_OWNER] = @OWNER
				);
    --
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;