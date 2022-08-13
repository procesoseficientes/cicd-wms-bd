-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-Oct-17 @ Nexus Team Sprint eNave 
-- Description:			SP que obtiene una factura con su detalle

-- Modificacion 1/26/2018 @ Reborn-Team Sprint Trotzdem
-- diego.as
-- Se agrega obtencion de campos necesarios para wms

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
					@DATABASE = 'SBOwms'
					,@DOC_NUM = 72450
					,@USE_SUBSIDIARY = 0
*/
-- =============================================
CREATE PROCEDURE [wms].[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
(
    @DATABASE VARCHAR(50),
    @DOC_NUM VARCHAR(50),
    @USE_SUBSIDIARY INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;



    DECLARE @QUERY NVARCHAR(MAX);

    SELECT @QUERY
        = N'
    	SELECT 
    		*
    	FROM (SELECT * FROM OPENQUERY([ERP_SERVER],''
    SELECT [H].[CVE_DOC] [DOC_ENTRY],
           [H].[CVE_DOC] [DOC_NUM],
           [H].[CVE_CLPV] [CLIENT_CODE],
           [CLIE].[NOMBRE] [CLIENT_NAME],
           [O].[STR_OBS] [COMMENTS],
           [H].[FECHA_DOC] [DOC_DATE],
           [H].[FECHA_ENT] [DELIVERY_DATE],
           [H].[STATUS] [STATUS],
           [VEND].[CVE_VEND] [CODE_SELLER],
           [H].[CAN_TOT] [TOTAL_AMOUNT],
           [D].[NUM_PAR] [LINE_NUM],
           [D].[CVE_ART] COLLATE DATABASE_DEFAULT [MATERIAL_ID],
           [M].[DESCR] [MATERIAL_NAME],
           [D].[CANT] [QTY],
           [D].[CANT] [OPEN_QTY],
           [D].[PREC] [PRICE],
           [D].[DESC1] +[D].[DESC2] +[D].[DESC3] [DISCOUNT_PERCENT],
           [D].[TOT_PARTIDA] [TOTAL_LINE],
           [D].[NUM_ALM] [WAREHOUSE_CODE],
           ''''alza'''' [MATERIAL_OWNER],
           [CLIE].[CALLE] + '''' '''' + [CLIE].[LOCALIDAD] [ADDRESS],
           [H].[NUM_MONED] [DOC_CURRENCY],
           [H].[TIPCAMB] [DOC_RATE],
           CAST(NULL AS VARCHAR) [SUBSIDIARY],
           [H].[NUM_MONED] [DET_CURRENCY],
           [D].[TIP_CAM] [DET_RATE],
           [D].[IMPU4] [DET_TAX_CODE],
           [D].[IMPU4]+[D].[IMPU3]+[D].[IMPU2] +[D].[IMPU1] [DET_VAT_PERCENT],
           '''''''' [COST_CENTER],
           [D].[UNI_VENTA] [UNIT]
    FROM ' + @DATABASE + N'.[dbo].[FACTF01] [H]
	INNER JOIN ' + @DATABASE
          + N'.[dbo].[PAR_FACTF01] [D] ON [D].[CVE_DOC] = [H].[CVE_DOC]
        LEFT JOIN ' + @DATABASE
          + N'.dbo.[CLIE01] [CLIE]
            ON [CLIE].[CLAVE] = [H].[CVE_CLPV]
        LEFT JOIN ' + @DATABASE
          + N'.[dbo].[OBS_DOCF01] [O]
            ON [O].[CVE_OBS] = [H].[CVE_OBS]
        LEFT JOIN ' + @DATABASE
          + N'.[dbo].[VEND01] [VEND]
            ON ([H].[CVE_VEND] = [VEND].[CVE_VEND])
			LEFT JOIN ' + @DATABASE
          + N'.[dbo].[INVE01] [M] 
			ON [M].[CVE_ART] = [D].[CVE_ART]
			

WHERE LTRIM(RTRIM([H].[CVE_DOC])) = ''''' + CAST(@DOC_NUM AS VARCHAR)
          + N''''' 
		  AND [H].[TIP_DOC] = ''''F''''		  
		  AND [H].[BLOQ] <> ''''S''''
          AND [H].[STATUS] <> ''''C''''
          AND [H].[ESCFD] <> ''''A''''
          AND [H].[ESCFD] <> ''''D''''
          AND [H].[ENLAZADO] <> ''''T''''

'')) [O];
'   ;
    ----
    PRINT '@QUERY: ' + @QUERY;
    --
    EXEC (@QUERY);
END;











