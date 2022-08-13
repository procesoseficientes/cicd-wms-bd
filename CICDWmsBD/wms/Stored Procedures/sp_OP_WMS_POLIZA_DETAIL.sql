-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-02-2017 @ Sprint Ergon III
-- Description:			Se graba el detalle

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	12-Diciembre-2019 G-Force@Kioto
-- Description:			Se agrega campo de Material Id al detalle de la poliza
/*
	Ejemplo Ejecucion: 
    EXEC [wms].sp_OP_WMS_POLIZA_DETAIL
 */
-- =============================================

CREATE PROCEDURE [wms].[sp_OP_WMS_POLIZA_DETAIL]
    @LINE_NUMBER NUMERIC(18, 0) = 0 OUTPUT,
    @DOC_ID NUMERIC(18, 0),
    @SKU_DESCRIPTION VARCHAR(250),
    @SAC_CODE VARCHAR(50),
    @BULTOS NUMERIC(18, 4),
    @CLASE VARCHAR(25),
    @NET_WEIGTH NUMERIC(18, 2),
    @WEIGTH_UNIT VARCHAR(25),
    @QTY NUMERIC(18, 4),
    @CUSTOMS_AMOUNT NUMERIC(18, 2),
    @QTY_UNIT VARCHAR(25),
    @VOLUME NUMERIC(18, 3),
    @VOLUME_UNIT VARCHAR(25),
    @DAI NUMERIC(18, 2),
    @IVA NUMERIC(18, 2),
    @MISC_TAXES NUMERIC(18, 2),
    @FOB_USD NUMERIC(18, 2),
    @FREIGTH_USD NUMERIC(18, 2),
    @INSURANCE_USD NUMERIC(18, 2),
    @MISC_EXPENSES NUMERIC(18, 2),
    @ORIGIN_COUNTRY VARCHAR(50),
    @REGION_CP VARCHAR(50),
    @AGREEMENT_1 VARCHAR(50),
    @AGREEMENT_2 VARCHAR(50),
    @RELATED_POLIZA VARCHAR(15),
    @LAST_UPDATED_BY VARCHAR(25),
    @LAST_UPDATED DATETIME,
    @ORIGIN_DOC_ID NUMERIC(18, 0),
    @CODIGO_POLIZA_ORIGEN VARCHAR(15),
    @CLIENT_CODE VARCHAR(25),
    @PCTDAI NUMERIC(18, 3) = 0.000,
    @ORIGIN_LINE_NUMBER NUMERIC(18, 0) = 0,
    @TAX NUMERIC(18, 9) = 0,
    @MATERIAL_ID VARCHAR(50)
AS

--declaramos las variables a utilizar
DECLARE @retCode INT;
DECLARE @LINEID INT;

IF NOT EXISTS
(
    SELECT *
    FROM [wms].[OP_WMS_POLIZA_HEADER]
    WHERE [DOC_ID] = @DOC_ID
)
BEGIN
    SET @retCode = 0;
    RAISERROR('NO EXISTE LA POLIZA', 1, 16);
END;
IF @LINE_NUMBER = 0
BEGIN
    SELECT @LINEID = ISNULL([LINE_NUMBER], 0) + 1
    FROM [wms].[OP_WMS_POLIZA_DETAIL]
    WHERE [DOC_ID] = @DOC_ID;
    IF @LINEID IS NULL
    BEGIN
        SET @LINEID = 1;
    END;
END;
ELSE
BEGIN
    SET @LINEID = @LINE_NUMBER;
END;
IF NOT EXISTS
(
    SELECT *
    FROM [wms].[OP_WMS_POLIZA_DETAIL]
    WHERE [DOC_ID] = @DOC_ID
          AND [LINE_NUMBER] = @LINEID
)
BEGIN

    BEGIN TRANSACTION;
    INSERT INTO [wms].[OP_WMS_POLIZA_DETAIL]
    (
        [DOC_ID],
        [LINE_NUMBER],
        [SKU_DESCRIPTION],
        [SAC_CODE],
        [BULTOS],
        [CLASE],
        [NET_WEIGTH],
        [WEIGTH_UNIT],
        [QTY],
        [CUSTOMS_AMOUNT],
        [QTY_UNIT],
        [VOLUME],
        [VOLUME_UNIT],
        [DAI],
        [IVA],
        [MISC_TAXES],
        [FOB_USD],
        [FREIGTH_USD],
        [INSURANCE_USD],
        [MISC_EXPENSES],
        [ORIGIN_COUNTRY],
        [REGION_CP],
        [AGREEMENT_1],
        [AGREEMENT_2],
        [RELATED_POLIZA],
        [LAST_UPDATED_BY],
        [LAST_UPDATED],
        [ORIGIN_DOC_ID],
        [CODIGO_POLIZA_ORIGEN],
        [CLIENT_CODE],
        [PCTDAI],
        [ORIGIN_LINE_NUMBER],
        [TAX],
        [MATERIAL_ID]
    )
    VALUES
    (@DOC_ID, @LINEID, @SKU_DESCRIPTION, @SAC_CODE, @BULTOS, @CLASE, @NET_WEIGTH, @WEIGTH_UNIT, @QTY, @CUSTOMS_AMOUNT,
     @QTY_UNIT, @VOLUME, @VOLUME_UNIT, @DAI, @IVA, @MISC_TAXES, @FOB_USD, @FREIGTH_USD, @INSURANCE_USD, @MISC_EXPENSES,
     @ORIGIN_COUNTRY, @REGION_CP, @AGREEMENT_1, @AGREEMENT_2, @RELATED_POLIZA, @LAST_UPDATED_BY, @LAST_UPDATED,
     @ORIGIN_DOC_ID, @CODIGO_POLIZA_ORIGEN, @CLIENT_CODE, @PCTDAI, @ORIGIN_LINE_NUMBER, @TAX, @MATERIAL_ID);

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        SET @retCode = 0;
        RETURN @retCode;
    END;
    ELSE
    BEGIN
        COMMIT TRANSACTION;
        SET @retCode = 1;
        SET @LINE_NUMBER = @LINEID;
        RETURN @retCode;
    END;
END;
ELSE
BEGIN
    BEGIN TRANSACTION;
    UPDATE [wms].[OP_WMS_POLIZA_DETAIL]
    SET [SKU_DESCRIPTION] = @SKU_DESCRIPTION,
        [SAC_CODE] = @SAC_CODE,
        [BULTOS] = @BULTOS,
        [CLASE] = @CLASE,
        [NET_WEIGTH] = @NET_WEIGTH,
        [WEIGTH_UNIT] = @WEIGTH_UNIT,
        [QTY] = @QTY,
        [CUSTOMS_AMOUNT] = @CUSTOMS_AMOUNT,
        [QTY_UNIT] = @QTY_UNIT,
        [VOLUME] = @VOLUME,
        [VOLUME_UNIT] = @VOLUME_UNIT,
        [DAI] = @DAI,
        [IVA] = @IVA,
        [MISC_TAXES] = @MISC_TAXES,
        [FOB_USD] = @FOB_USD,
        [FREIGTH_USD] = @FREIGTH_USD,
        [INSURANCE_USD] = @INSURANCE_USD,
        [MISC_EXPENSES] = @MISC_EXPENSES,
        [ORIGIN_COUNTRY] = @ORIGIN_COUNTRY,
        [REGION_CP] = @REGION_CP,
        [AGREEMENT_1] = @AGREEMENT_1,
        [AGREEMENT_2] = @AGREEMENT_2,
        [RELATED_POLIZA] = @RELATED_POLIZA,
        [LAST_UPDATED_BY] = @LAST_UPDATED_BY,
        [LAST_UPDATED] = @LAST_UPDATED,
        [ORIGIN_DOC_ID] = @ORIGIN_DOC_ID,
        [CODIGO_POLIZA_ORIGEN] = @CODIGO_POLIZA_ORIGEN,
        [CLIENT_CODE] = @CLIENT_CODE,
        [PCTDAI] = @PCTDAI,
        [ORIGIN_LINE_NUMBER] = @ORIGIN_LINE_NUMBER,
        [TAX] = @TAX,
        [MATERIAL_ID] = @MATERIAL_ID
    WHERE [DOC_ID] = @DOC_ID
          AND [LINE_NUMBER] = @LINE_NUMBER;
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        SET @retCode = 0;
        RETURN @retCode;
    END;
    ELSE
    BEGIN
        COMMIT TRANSACTION;
        SET @retCode = 2;
        RETURN @retCode;
    END;
END;