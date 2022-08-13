-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/21/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Actualiza el numero de factura en la demanda despacho

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_SET_INVOICE_NUMBER_TO_PICKING_DEMAND]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SET_INVOICE_NUMBER_TO_PICKING_DEMAND]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @XML XML = NULL
		,@EXTERNAL_SOURCE_ID INT
        ,@SOURCE_NAME VARCHAR(50)
        ,@DATA_BASE_NAME VARCHAR(50)
        ,@SCHEMA_NAME VARCHAR(50)
        ,@QUERY VARCHAR(MAX)
	--
	CREATE TABLE #INVOICE(
		[INVOICE] VARCHAR(50)
		,[DOC_ENTRY] INT
		,[PICKING_HEADER_ID] INT
	)
	-- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas necesarias unicamente
    -- ------------------------------------------------------------------------------------
    SELECT DISTINCT
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME] INTO #EXTERNAL_SOURCE
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID]
	WHERE [DH].[IS_POSTED_ERP] = 1
		AND [DH].[DELIVERY_NOTE_INVOICE] IS NULL

	-- ------------------------------------------------------------------------------------
    -- Ciclo para obtener las facturas de las notas de entrega
    -- ------------------------------------------------------------------------------------
    PRINT '--> Inicia el ciclo'
	WHILE EXISTS (SELECT TOP 1
          1
        FROM [#EXTERNAL_SOURCE])
    BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma la primera fuente extermna
		-- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
           ,@SOURCE_NAME = [ES].[SOURCE_NAME]
           ,@DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
           ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
           ,@QUERY = N''
        FROM
            #EXTERNAL_SOURCE [ES]
        ORDER BY
            [ES].[EXTERNAL_SOURCE_ID]
		--
        PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
        PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
        PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
        PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME
		-- ------------------------------------------------------------------------------------
		-- Arma el XML
		-- ------------------------------------------------------------------------------------
		SET @XML = (
			SELECT 
				[DH].[PICKING_DEMAND_HEADER_ID] [PickingHeaderId]
				,[DH].[ERP_REFERENCE] [DocEntry]
			FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
			WHERE [DH].[IS_POSTED_ERP] = 1
				AND [DH].[DELIVERY_NOTE_INVOICE] IS NULL
				AND [DH].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
			FOR
				XML PATH('NotaDeEntrega')
		)

		-- ------------------------------------------------------------------------------------
		-- Obtiene las facturas de las notas de entrega
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N' 
			INSERT INTO #INVOICE

			EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_SP_GET_DELIVERY_NOTES_INVOICE_NUMBER] 
				@DELIVERY_NOTES = ''' + CAST(@XML AS VARCHAR(MAX)) + '''		'
		--
		PRINT '--> @QUERY: ' + @QUERY
		--
		EXEC (@QUERY)
		-- ------------------------------------------------------------------------------------
		-- Eliminamos la fuente externa
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#EXTERNAL_SOURCE]
		WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
    END
	-- ------------------------------------------------------------------------------------
	-- Actualiza las demandas despacho
	-- ------------------------------------------------------------------------------------
	UPDATE [PDH]
	SET [PDH].[DELIVERY_NOTE_INVOICE] = [I].[INVOICE]
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN [#INVOICE] [I] ON [I].[PICKING_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
END