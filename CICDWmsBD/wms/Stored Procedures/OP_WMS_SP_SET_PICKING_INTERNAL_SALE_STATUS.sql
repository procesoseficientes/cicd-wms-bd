
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/24/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Se actualiza el valor de la columna INNER_SALE_STATUS.

-- Modificacion 10/25/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se agrega el docnum cuando es factura de venta intenra

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_SET_PICKING_INTERNAL_SALE_STATUS]
					@PICKING_DEMAND_HEADER_ID = 5251, -- int
					@ERP_REFERENCE = 'Proceso Exitoso|Factura de Venta: 45686;', -- varchar(50)
					@INNER_SALE_STATUS = 'SALES_INVOICE', -- varchar(50)
					@OWNER = 'viscosa' -- varchar(50)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SET_PICKING_INTERNAL_SALE_STATUS] (
		@PICKING_DEMAND_HEADER_ID INT
		,@ERP_REFERENCE VARCHAR(50)
		,@INNER_SALE_STATUS VARCHAR(50)
		,@OWNER VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY
		DECLARE
			@INTERNAL_SALE_COMPANIES VARCHAR(50)
			,@IS_INTERNAL_COMPANY INT = 0
			,@PERFORMS_INTERNAL_SALE INT = 0
			,@DOC_NUM INT
			,@QUERY NVARCHAR(MAX)
			,@TABLE VARCHAR(50)
			,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
			,@ERP_DATABASE VARCHAR(50)
			,@SCHEMA_NAME VARCHAR(50)
			,@ERP_REFENRECE_DOC_ENTRY VARCHAR(50);
    -- ------------------------------------------------------------------------------------
    -- Obtiene las compa;ias a las que se les hace compra venta interna
    -- ------------------------------------------------------------------------------------
		SELECT
			@INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS]
		WHERE
			[PARAM_GROUP] = 'INTERCOMPANY'
			AND [PARAM_NAME] = 'INTERNAL_SALE';
    -- ------------------------------------------------------------------------------------
    -- Verifica que nuestro parametro owner este o no este en este listado
    -- ------------------------------------------------------------------------------------
		SELECT
			@IS_INTERNAL_COMPANY = 1
		FROM
			[wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES,
											'|') [FNS]
		WHERE
			@OWNER = [FNS].[VALUE];
    -- ------------------------------------------------------------------------------------
    -- Se obtiene si es pedido de venta interna
    -- ------------------------------------------------------------------------------------
		SELECT
			@PERFORMS_INTERNAL_SALE = 1
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
		INNER JOIN [wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES,
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
    -- Obtiene el docnum de la factura de venta.
    -- ------------------------------------------------------------------------------------
		IF @INNER_SALE_STATUS = 'SALE_INVOICE'
		BEGIN
			SELECT
				@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
				,@ERP_DATABASE = [C].[ERP_DATABASE]
				,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
				,@TABLE = 'OINV'
				,@ERP_REFENRECE_DOC_ENTRY = [wms].[OP_WMS_FN_SPLIT_COLUMNS](REPLACE(@ERP_REFERENCE,
											';', ' '), 5,
											' ')
			FROM
				[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
			INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
			WHERE
				[C].[COMPANY_NAME] = @OWNER;
      --
			SELECT
				@QUERY = N'EXEC '
				+ @INTERFACE_DATA_BASE_NAME + '.'
				+ @SCHEMA_NAME
				+ '.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE =' + @ERP_DATABASE + '
					,@TABLE = ''' + @TABLE + '''
					,@DOC_ENTRY = '''
				+ @ERP_REFENRECE_DOC_ENTRY + '''
					,@DOC_NUM = @DOC_NUM OUTPUT';
			PRINT @QUERY;
			EXEC [sp_executesql] @QUERY,
				N'@DOC_NUM INT =-1 OUTPUT',
				@DOC_NUM = @DOC_NUM OUTPUT;
      --
			SELECT
				@ERP_REFERENCE = REPLACE(@ERP_REFERENCE,
											@ERP_REFENRECE_DOC_ENTRY,
											@DOC_NUM);
		END;
    -- ------------------------------------------------------------------------------------
    -- Actualiza el detalle de todos los productos cuyo owner este en proceso de compra/venta
    -- ------------------------------------------------------------------------------------
		UPDATE
			[DD]
		SET	
			[DD].[INNER_SALE_STATUS] = @INNER_SALE_STATUS
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
		INNER JOIN [wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES,
											'|') [FNS] ON [FNS].[VALUE] = [DD].[MATERIAL_OWNER]
		WHERE
			@PERFORMS_INTERNAL_SALE = 1;
    -- ------------------------------------------------------------------------------------
    -- Actualiza el detalle, si el owner esta en este detalle, actualiza todo, de lo contrario lo actualiza por MATERIAL_OWNER
    -- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
		SET	
			[INNER_SALE_STATUS] = @INNER_SALE_STATUS
			,[INNER_SALE_RESPONSE] = ISNULL([INNER_SALE_RESPONSE],
											'')
			+ @ERP_REFERENCE
		WHERE
			(
				@OWNER = [MATERIAL_OWNER]
				OR (
					ISNULL(@IS_INTERNAL_COMPANY, 0) = 1
					AND @PERFORMS_INTERNAL_SALE = 1
					)
			)
			AND [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
    -- ------------------------------------------------------------------------------------
    -- Si todo el detalle tiene el mismo INNER_SALE_STATUS actualiza el encabezado
    -- ------------------------------------------------------------------------------------
		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
						WHERE
							[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
							AND ISNULL([INNER_SALE_STATUS],
										'') != @INNER_SALE_STATUS )
		BEGIN
			UPDATE
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			SET	
				[INNER_SALE_STATUS] = @INNER_SALE_STATUS
				,[INNER_SALE_RESPONSE] = ISNULL([INNER_SALE_RESPONSE],
											'')
				+ @ERP_REFERENCE
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
		END;

		IF (@INNER_SALE_STATUS = 'SALE_INVOICE')
		BEGIN
			UPDATE
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			SET	
				[IS_SENDING] = 0
			WHERE
				[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
		END;

    -- ------------------------------------------------------------------------------------
    -- Muestra resultado final
    -- ------------------------------------------------------------------------------------
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