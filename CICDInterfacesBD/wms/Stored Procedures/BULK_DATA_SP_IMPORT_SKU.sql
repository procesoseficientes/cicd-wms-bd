
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa SKU

-- Modificacion 17-04-2016
-- alberto.ruiz
-- Se agrego que se actualizara el nombre de la lista de precios por la lista de precios default

-- Modificacion 23-05-2016
-- alberto.ruiz
-- Se Agergo la columna USE_LINE_PICKING

-- Modificacion 27-05-2016
-- alberto.ruiz
-- Se agregaron las columnas VOLUME_CODE_UNIT y VOLUME_NAME_UNIT

-- Modificacion 3/14/2017 @ A-Team Sprint Ebonne
-- rodrigo.gomez
-- Se agregaron las columas OWNER y OWNER_ID

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agregan columnas ART_CODE, VAT_CODE
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_SKU]
				--
				SELECT * FROM [wms].[SWIFT_ERP_SKU]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_SKU]
AS
BEGIN
  SET NOCOUNT ON;
    --
    DECLARE @NAME_PRICE_LIST VARCHAR(250) = '',
            @CODEE_PRICE_LIST INT;
    --SELECT * FROM [wms].[O

    MERGE OP_WMS_ALZA.[wms].[OP_WMS_CLASS] [C]
    USING
    (
        SELECT [FAMILY_CODE],
               [FAMILY_NAME],
               [PRIORITY]
        FROM OP_WMS_ALZA.[wms].[VIEW_SKU_FAMILIES]
    ) AS [F]
    ON [C].[CLASS_NAME]   COLLATE DATABASE_DEFAULT = [F].[FAMILY_CODE]  COLLATE DATABASE_DEFAULT
    WHEN MATCHED THEN
        UPDATE SET [C].[PRIORITY] = [F].[PRIORITY],
                   [C].[LAST_UPDATED_BY] = 'BULK_PROCESS',
                   [C].[LAST_UPDATED] = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT
        (
            [CLASS_NAME],
            [CLASS_DESCRIPTION],
            [CLASS_TYPE],
            [PRIORITY],
            [CREATED_BY],
            [CREATED_DATETIME],
            [LAST_UPDATED_BY],
            [LAST_UPDATED]
        )
        VALUES
        ([F].[FAMILY_CODE], [F].[FAMILY_NAME], 'PRODUCTOS', [F].[PRIORITY], 'BULK_PROCESS', GETDATE(), 'BULK_PROCESS',
         GETDATE());

	-- ------------------------------------------------------------------------------------
    -- Obtiene las subfamilias
    -- ------------------------------------------------------------------------------------
	MERGE OP_WMS_ALZA.[wms].[OP_WMS_SUB_CLASS] [SC]
    USING
    (
        SELECT [SUB_FAMILY_NAME]
        FROM OP_WMS_ALZA.[wms].[VIEW_SKU_SUB_FAMILIES]
    ) AS [SF]
    ON [SC].[SUB_CLASS_NAME]  COLLATE DATABASE_DEFAULT = [SF].[SUB_FAMILY_NAME]  COLLATE DATABASE_DEFAULT
    WHEN NOT MATCHED THEN
        INSERT
        (
            [SUB_CLASS_NAME],
            [CREATED_BY],
            [CREATED_DATETIME],
            [LAST_UPDATED_BY],
            [LAST_UPDATED]
        )
        VALUES
        ([SF].[SUB_FAMILY_NAME], 'BULK_PROCESS', GETDATE(), 'BULK_PROCESS',
         GETDATE());

    --DELETE
    --	[wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]; 
    --INSERT	INTO [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
    --		(
    --			[CLIENT_ID]
    --			,[MATERIAL_ID]
    --			,[MEASUREMENT_UNIT]
    --			,[QTY]
    --			,[BARCODE]
    --			,[ALTERNATIVE_BARCODE]
    --		)
    --SELECT
    --	[ClientCode]
    --	,[MateriaId]
    --	,[AlternativeUnit]
    --	,[Factor]
    --	,[BarcodeAlternativeUnit]
    --	,''
    --FROM
    --	[wms].[VIEW_SKU_UM]
    --;

    -- ------------------------------------------------------------------------------------
    -- Obtiene los productos
    -- ------------------------------------------------------------------------------------
    MERGE OP_WMS_ALZA.[wms].[OP_WMS_MATERIALS] [M]
    USING
    (
        SELECT [V].[CLIENT_OWNER],
               [V].[MATERIAL_ID],
               [V].[MATERIAL_ID_SAP],
               [V].[BARCODE_ID],
               [V].[ALTERNATE_BARCODE],
               [V].[MATERIAL_NAME],
               [V].[SHORT_NAME],
               [V].[VOLUME_FACTOR],
               [V].[MATERIAL_CLASS],
			   [V].[MATERIAL_SUB_CLASS],
               [V].[HIGH],
               [V].[LENGTH],
               [V].[WIDTH],
               [V].[MAX_X_BIN],
               [V].[SCAN_BY_ONE],
               [V].[REQUIRES_LOGISTICS_INFO],
               [V].[WEIGTH],
               [V].[IMAGE_1],
               [V].[IMAGE_2],
               [V].[IMAGE_3],
               [V].[LAST_UPDATED],
               [V].[LAST_UPDATED_BY],
               [V].[IS_CAR],
               [V].[MT3],
               [V].[BATCH_REQUESTED],
               [V].[SERIAL_NUMBER_REQUESTS],
               [V].[ERP_AVERAGE_PRICE],
               [V].[INVT],
               [V].[HANDLE_TONE],
               [V].[HANDLE_CALIBER],
               [V].[QM],
               [V].[BaseUnit],
               [C].[CLASS_ID],
               [C].[CLASS_NAME],
			   [SC].[SUB_CLASS_ID],
			   [SC].[SUB_CLASS_NAME]
        FROM OP_WMS_ALZA.[wms].[VIEW_SKU_ERP] [V]
            INNER JOIN OP_WMS_ALZA.[wms].[OP_WMS_CLASS] [C] ON [V].[Family]  COLLATE DATABASE_DEFAULT = [C].[CLASS_NAME] COLLATE DATABASE_DEFAULT
			LEFT JOIN OP_WMS_ALZA.[wms].[OP_WMS_SUB_CLASS] [SC] ON [V].[MATERIAL_SUB_CLASS] COLLATE DATABASE_DEFAULT= [SC].[SUB_CLASS_NAME]  COLLATE DATABASE_DEFAULT
    ) AS [V]
    ON [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [V].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
    WHEN MATCHED THEN
        UPDATE SET [M].[CLIENT_OWNER] = [V].[CLIENT_OWNER],
                   [M].[MATERIAL_ID] = [V].[MATERIAL_ID],
                   --,[M].[BARCODE_ID] = [V].[BARCODE_ID]
                   --							
                   --,[M].[ALTERNATE_BARCODE] = [V].[ALTERNATE_BARCODE]
                   --							
                   [M].[MATERIAL_NAME] = ISNULL([V].[MATERIAL_NAME], 'na'),
                   [M].[SHORT_NAME] = ISNULL([V].[SHORT_NAME], 'na'),
                   [M].[VOLUME_FACTOR] = [V].[VOLUME_FACTOR],
                   [M].[MATERIAL_CLASS] = [V].[CLASS_ID],
				   [M].[MATERIAL_SUB_CLASS] = [V].[SUB_CLASS_ID],
                   [M].[HIGH] = [V].[HIGH],
                   [M].[LENGTH] = [V].[LENGTH],
                   [M].[WIDTH] = [V].[WIDTH],
                   [M].[MAX_X_BIN] = [V].[MAX_X_BIN],
                   [M].[SCAN_BY_ONE] = [V].[SCAN_BY_ONE],
                   [M].[REQUIRES_LOGISTICS_INFO] = [V].[REQUIRES_LOGISTICS_INFO],
                   [M].[WEIGTH] = [V].[WEIGTH],
                   [M].[WEIGHT_MEASUREMENT] = 'LIBRA',
                   [M].[IMAGE_1] = [V].[IMAGE_1],
                   [M].[IMAGE_2] = [V].[IMAGE_2],
                   [M].[IMAGE_3] = [V].[IMAGE_3],
                   [M].[LAST_UPDATED] = [V].[LAST_UPDATED],
                   [M].[LAST_UPDATED_BY] = [V].[LAST_UPDATED_BY],
                   [M].[IS_CAR] = [V].[IS_CAR],
                   [M].[MT3] = [V].[MT3],
                   --,[M].[BATCH_REQUESTED] = [V].[BATCH_REQUESTED]
                   --,[M].[SERIAL_NUMBER_REQUESTS] = [V].[SERIAL_NUMBER_REQUESTS]
                   --,[M].[HANDLE_TONE] = [V].[HANDLE_TONE]
                   --,[M].[HANDLE_CALIBER] = [V].[HANDLE_CALIBER]
                   [M].[ITEM_CODE_ERP] = [V].[MATERIAL_ID_SAP],
                   [M].[ERP_AVERAGE_PRICE] = [V].[ERP_AVERAGE_PRICE],
                   [M].[QUALITY_CONTROL] = [V].[QM],
                   [M].[BASE_MEASUREMENT_UNIT] = [V].[BaseUnit]
                   
    WHEN NOT MATCHED THEN
        INSERT
        (
            [CLIENT_OWNER],
            [MATERIAL_ID],
            [BARCODE_ID],
            [ALTERNATE_BARCODE],
            [MATERIAL_NAME],
            [SHORT_NAME],
            [VOLUME_FACTOR],
            [MATERIAL_CLASS],
			[MATERIAL_SUB_CLASS],
            [HIGH],
            [LENGTH],
            [WIDTH],
            [MAX_X_BIN],
            [SCAN_BY_ONE],
            [REQUIRES_LOGISTICS_INFO],
            [WEIGTH],
            [WEIGHT_MEASUREMENT],
            [IMAGE_1],
            [IMAGE_2],
            [IMAGE_3],
            [LAST_UPDATED],
            [LAST_UPDATED_BY],
            [IS_CAR],
            [MT3],
            [BATCH_REQUESTED],
            [SERIAL_NUMBER_REQUESTS],
            [HANDLE_TONE],
            [HANDLE_CALIBER],
            [ITEM_CODE_ERP],
            [ERP_AVERAGE_PRICE],
            [QUALITY_CONTROL],
            [BASE_MEASUREMENT_UNIT]
        )
        VALUES
        ([V].[CLIENT_OWNER], [V].[MATERIAL_ID], ISNULL([V].[BARCODE_ID], 0), [V].[ALTERNATE_BARCODE],
         ISNULL([V].[MATERIAL_NAME], 'N/A'), ISNULL([V].[SHORT_NAME], 'N/A'), [V].[VOLUME_FACTOR], [V].[CLASS_ID], [V].[SUB_CLASS_ID],
         [V].[HIGH], [V].[LENGTH], [V].[WIDTH], [V].[MAX_X_BIN], [V].[SCAN_BY_ONE], [V].[REQUIRES_LOGISTICS_INFO],
         [V].[WEIGTH], 'LIBRA', [V].[IMAGE_1], [V].[IMAGE_2], [V].[IMAGE_3], [V].[LAST_UPDATED], [V].[LAST_UPDATED_BY],
         [V].[IS_CAR], [V].[MT3], [V].[BATCH_REQUESTED], [V].[SERIAL_NUMBER_REQUESTS], [V].[HANDLE_TONE],
         [V].[HANDLE_CALIBER], [V].[MATERIAL_ID_SAP], [V].[ERP_AVERAGE_PRICE], [V].[QM], [V].[BaseUnit]);
END


