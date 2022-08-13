
-- =============================================
-- Autor:				Alejandro.Ochoa
-- Fecha de Creacion: 	18-07-19
-- Description:			SP que Inserta una Orden de Venta (Pedido) proviniente de SONDA
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_SALES_ORDER] @SALES_ORDER_ID = @SALES_ORDER_ID
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_SALES_ORDER_PRUEBAS]
(@SALES_ORDER_ID NUMERIC)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SAE_DOCUMENT INT,
            @FULL_SAE_DOCUMENT VARCHAR(20),
            @SERIE VARCHAR(6) = 'STAND.',
            @DOCUMENT_TYPE CHAR(1) = 'P',
            @NUMBER_FROM INT,
            @COMMENT_ID INT,
            @LOG_ID INT,
            @QTY FLOAT,
            @ISV FLOAT = 0.15,
            @ROUND_DECIMALS INT = 6,
            @TOTAL_TAX FLOAT,
			@TOTAL_DOC FLOAT,
            @TOTAL_DESC FLOAT,
            @AVAILABLE_CREDIT FLOAT,
            @CREDIT_LIMIT FLOAT,
            @OVERDUE_AMOUNT FLOAT,
            @SO_STATUS VARCHAR(8) = 'APROBADO',
            @TOTAL_WITHOUT_TAX FLOAT,
            @SO_COMMENT VARCHAR(250),
            @CLIENT_ID VARCHAR(50),
            @CODE_SKU VARCHAR(25),
            @LINE_SEQ INT,
            @SO_ID UNIQUEIDENTIFIER,
            @ERP_REFERENCE VARCHAR(MAX),
            @TODAY DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0);

    BEGIN TRY
        BEGIN TRANSACTION;

        --Getting ORDER HEADER Data
        SELECT [ssoh].[SALES_ORDER_ID],
               [ssoh].[COMMENT],
               [ssoh].[POSTED_DATETIME],
               [ssoh].[DELIVERY_DATE],
               [ssoh].[CLIENT_ID],
               [ssoh].[WAREHOUSE],
               [ssoh].[POSTED_BY],
               [ssoh].[TOTAL_AMOUNT],
               [US].[RELATED_SELLER],
               [svac].[TAX_ID_NUMBER],
               [svac].[CREDIT_LIMIT],
               ([svac].[CREDIT_LIMIT] - [svac].[BALANCE] - [ssoh].[TOTAL_AMOUNT]) [AVAILABLE_CREDIT]
        INTO [#SALES_ORDER]
        FROM [SWIFT_EXPRESS].[SONDA].[SONDA_SALES_ORDER_HEADER] [ssoh]
            INNER JOIN [SWIFT_EXPRESS].[SONDA].[USERS] [US]
                ON [ssoh].[POSTED_BY] = [US].[LOGIN]
            INNER JOIN [SWIFT_EXPRESS].[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [svac]
                ON [ssoh].[CLIENT_ID] = [svac].[CODE_CUSTOMER]
        WHERE [ssoh].[SALES_ORDER_ID] = @SALES_ORDER_ID;

        SELECT @SALES_ORDER_ID = [SALES_ORDER_ID],
               @SO_COMMENT = [COMMENT],
               @CLIENT_ID = [CLIENT_ID],
               @CREDIT_LIMIT = [CREDIT_LIMIT],
               @TOTAL_WITHOUT_TAX = 0,
               @TOTAL_TAX = 0,
               @TOTAL_DESC = 0,
			   @TOTAL_DOC = 0,
               @AVAILABLE_CREDIT = [AVAILABLE_CREDIT]
        FROM [#SALES_ORDER]
        WHERE [SALES_ORDER_ID] = @SALES_ORDER_ID;

        --Getting the Client's Overdue Amount
        SELECT @OVERDUE_AMOUNT = SUM([PENDING_TO_PAID])
        FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER]
        WHERE [CODE_CUSTOMER] = @CLIENT_ID
              AND [IS_EXPIRED] = 1;

        --Setting as "BLOQUED"
        IF (@OVERDUE_AMOUNT > 0 OR (@AVAILABLE_CREDIT < 0 AND @CREDIT_LIMIT > 0))
        BEGIN
            SELECT @SO_STATUS = 'REVISION';
        END;

        --Getting Next Document for Serie
        SELECT TOP (1)
               @SAE_DOCUMENT = ([ULT_DOC] + 1),
               @NUMBER_FROM = [FOLIODESDE]
        FROM [SAE70EMPRESA01].[dbo].[FOLIOSF01]
        WHERE [TIP_DOC] = @DOCUMENT_TYPE
              AND [SERIE] = @SERIE
        GROUP BY [ULT_DOC],
                 [FOLIODESDE]
        ORDER BY [FOLIODESDE] DESC;

        --Update Next Document of Serie
        UPDATE [SAE70EMPRESA01].[dbo].[FOLIOSF01]
        SET [ULT_DOC] = (CASE
                             WHEN [ULT_DOC] < @SAE_DOCUMENT THEN
                                 @SAE_DOCUMENT
                             ELSE
                                 [ULT_DOC]
                         END
                        ),
            [FECH_ULT_DOC] = GETDATE()
        WHERE [TIP_DOC] = @DOCUMENT_TYPE
              AND [SERIE] = @SERIE
              AND [FOLIODESDE] = @NUMBER_FROM;

        --Getting next ID for Comments
        SELECT @COMMENT_ID = ([ULT_CVE] + 1)
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = 56;

        --Update next ID for Comments
        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @COMMENT_ID
        WHERE [ID_TABLA] = 56
              AND [ULT_CVE] = (@COMMENT_ID - 1);

        --Insert Sales Order Comment
        INSERT INTO [SAE70EMPRESA01].[dbo].[OBS_DOCF01]
        (
            [CVE_OBS],
            [STR_OBS]
        )
        VALUES
        (@COMMENT_ID, ISNULL(@SO_COMMENT, ''));

        --Getting next ID for Log
        SELECT @LOG_ID = ([ULT_CVE] + 1)
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = 62;

        --Update next ID for Log
        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @LOG_ID
        WHERE [ID_TABLA] = 62
              AND [ULT_CVE] = (@LOG_ID - 1);

        --Getting Sales Order Identifier
        SELECT @SO_ID = NEWID(),
               @FULL_SAE_DOCUMENT = [dbo].[FUNC_ADD_CHARS]([dbo].[FUNC_ADD_CHARS](@SAE_DOCUMENT, '0', 10), ' ', 20);

        --Insert Sales Order Log
        INSERT INTO [SAE70EMPRESA01].[dbo].[BITA01]
        (
            [CVE_BITA],
            [CVE_CAMPANIA],
            [STATUS],
            [CVE_CLIE],
            [CVE_USUARIO],
            [NOM_USUARIO],
            [OBSERVACIONES],
            [FECHAHORA],
            [CVE_ACTIVIDAD]
        )
        VALUES
        (@LOG_ID, '_SAE_', 'F', [dbo].[FUNC_ADD_CHARS](@CLIENT_ID, ' ', 10), 477, 'wms',
         ('No. [' + @FULL_SAE_DOCUMENT + ' ]'), GETDATE(), '    4');

        --Insert Sales Order
        INSERT INTO [SAE70EMPRESA01].[dbo].[FACTP01]
        (
            [TIP_DOC],
            [CVE_DOC],
            [CVE_CLPV],
            [STATUS],
            [DAT_MOSTR],
            [CVE_VEND],
            [CVE_PEDI],
            [FECHA_DOC],
            [FECHA_ENT],
            [FECHA_VEN],
            [CAN_TOT],
            [IMP_TOT1],
            [IMP_TOT2],
            [IMP_TOT3],
            [IMP_TOT4],
            [DES_TOT],
            [DES_FIN],
            [COM_TOT],
            [CONDICION],
            [CVE_OBS],
            [NUM_ALMA],
            [ACT_CXC],
            [ACT_COI],
            [ENLAZADO],
            [NUM_MONED],
            [TIPCAMB],
            [NUM_PAGOS],
            [FECHAELAB],
            [PRIMERPAGO],
            [RFC],
            [CTLPOL],
            [ESCFD],
            [AUTORIZA],
            [SERIE],
            [FOLIO],
            [AUTOANIO],
            [DAT_ENVIO],
            [CONTADO],
            [CVE_BITA],
            [BLOQ],
            [TIP_DOC_E],
            [DES_FIN_PORC],
            [DES_TOT_PORC],
            [COM_TOT_PORC],
            [IMPORTE],
            [DOC_ANT],
            [TIP_DOC_ANT],
            [UUID],
            [VERSION_SINC]
        )
        SELECT @DOCUMENT_TYPE,
               @FULL_SAE_DOCUMENT,
               [dbo].[FUNC_ADD_CHARS]([ssoh].[CLIENT_ID], ' ', 10),
               'O',
               0,
               [dbo].[FUNC_ADD_CHARS]([ssoh].[RELATED_SELLER], ' ', 5),
               '',
               @TODAY,
               [ssoh].[DELIVERY_DATE],
               [ssoh].[POSTED_DATETIME],
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               0,
               '',
               @COMMENT_ID,
               [ssoh].[WAREHOUSE],
               'S',
               'N',
               'O',
               1,
               1,
               1,
               GETDATE(),
               0,
               [ssoh].[TAX_ID_NUMBER],
               0,
               'N',
               0,
               '',
               @SAE_DOCUMENT,
               '',
               0,
               'N',
               @LOG_ID,
               'S',
               'O',
               0,
               0,
               0,
               0,
               '',
               '',
               @SO_ID,
               GETDATE()
        FROM [#SALES_ORDER] [ssoh];

        --Insert Sales Order User Fields
        INSERT INTO [SAE70EMPRESA01].[dbo].[FACTP_CLIB01]
        (
            [CLAVE_DOC],
            [CAMPLIB23]
        )
        VALUES
        (@FULL_SAE_DOCUMENT, @SO_STATUS);

        --Getting the Sales Order Detail
        SELECT [ssod].[LINE_SEQ],
               [ssod].[SKU],
               [ssod].[QTY],
               [ssod].[PRICE],
               [ssod].[DISPLAY_AMOUNT],
               ROUND([ssod].[DISPLAY_AMOUNT] / (1 + @ISV), @ROUND_DECIMALS) AS [TOTAL_WITHOUT_TAX],
               [ssod].[SALES_ORDER_ID],
               [INVE].[CVE_ART],
               [INVE].[COSTO_PROM],
               [INVE].[MAN_IEPS],
               [INVE].[UNI_MED],
               [INVE].[TIPO_ELE],
               [INVE].[APL_MAN_IMP],
               [INVE].[CUOTA_IEPS],
               [INVE].[APL_MAN_IEPS],
               [INVE].[CVE_ESQIMPU],
               [IMP].[IMPUESTO1],
               [IMP].[IMPUESTO2],
               [IMP].[IMPUESTO3],
               [IMP].[IMPUESTO4],
               [IMP].[IMP1APLICA],
               [IMP].[IMP2APLICA],
               [IMP].[IMP3APLICA],
               [IMP].[IMP4APLICA],
               (ISNULL([ssod].[DISCOUNT], 0) + ISNULL([ssod].[DISCOUNT_BY_FAMILY], 0)
                + ISNULL([ssod].[DISCOUNT_BY_GENERAL_AMOUNT], 0)
                + ISNULL([ssod].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE], 0)
               ) AS [DISCOUNT],
			   (ROUND([ssod].[DISPLAY_AMOUNT] / (1 + @ISV), @ROUND_DECIMALS) * 
				 ((ISNULL([ssod].[DISCOUNT], 0) + ISNULL([ssod].[DISCOUNT_BY_FAMILY], 0)
				   + ISNULL([ssod].[DISCOUNT_BY_GENERAL_AMOUNT], 0)
				   + ISNULL([ssod].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE], 0)) / 100)
			   )   AS [DISCOUNT_AMOUNT]
        INTO [#SO_DETAIL]
        FROM [SWIFT_EXPRESS].[SONDA].[SONDA_SALES_ORDER_DETAIL] [ssod]
            INNER JOIN [SAE70EMPRESA01].[dbo].[INVE01] [INVE]
                ON [ssod].[SKU] COLLATE DATABASE_DEFAULT = [INVE].[CVE_ART] COLLATE DATABASE_DEFAULT
            LEFT JOIN [SAE70EMPRESA01].[dbo].[IMPU01] [IMP]
                ON [IMP].[CVE_ESQIMPU] = [INVE].[CVE_ESQIMPU]
        WHERE [ssod].[SALES_ORDER_ID] = @SALES_ORDER_ID
        ORDER BY [ssod].[LINE_SEQ] ASC;


        WHILE EXISTS (SELECT TOP (1) 1 FROM [#SO_DETAIL])
        BEGIN

            SELECT TOP (1)
                   @CODE_SKU = [SKU],
                   @LINE_SEQ = [LINE_SEQ],
                   @QTY = [QTY]
            FROM [#SO_DETAIL]
            ORDER BY [LINE_SEQ] ASC;

            --Update the PEND_SURT value for SKU
            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [PEND_SURT] = (CASE
                                   WHEN [PEND_SURT] + @QTY < 0 THEN
                                       0
                                   WHEN [PEND_SURT] + @QTY >= 0 THEN
                                       [PEND_SURT] + @QTY
                                   ELSE
                                       0
                               END
                              ),
                [VERSION_SINC] = GETDATE()
            WHERE [CVE_ART] = @CODE_SKU;

            --Insert SKU line in Sales Order
            INSERT INTO [SAE70EMPRESA01].[dbo].[PAR_FACTP01]
            (
                [CVE_DOC],
                [NUM_PAR],
                [CVE_ART],
                [CANT],
                [PXS],
                [PREC],
                [COST],
                [IMPU1],
                [IMPU2],
                [IMPU3],
                [IMPU4],
                [IMP1APLA],
                [IMP2APLA],
                [IMP3APLA],
                [IMP4APLA],
                [TOTIMP1],
                [TOTIMP2],
                [TOTIMP3],
                [TOTIMP4],
                [DESC1],
                [DESC2],
                [DESC3],
                [COMI],
                [APAR],
                [ACT_INV],
                [NUM_ALM],
                [POLIT_APLI],
                [TIP_CAM],
                [UNI_VENTA],
                [TIPO_PROD],
                [TIPO_ELEM],
                [CVE_OBS],
                [REG_SERIE],
                [E_LTPD],
                [NUM_MOV],
                [TOT_PARTIDA],
                [IMPRIMIR],
                [MAN_IEPS],
                [APL_MAN_IMP],
                [CUOTA_IEPS],
                [APL_MAN_IEPS],
                [MTO_PORC],
                [MTO_CUOTA],
                [CVE_ESQ],
                [UUID],
                [VERSION_SINC]
            )
            SELECT @FULL_SAE_DOCUMENT,
                   [sd].[LINE_SEQ] + 1,
                   [sd].[SKU],
                   [sd].[QTY],
                   [sd].[QTY],
                   CASE
                       WHEN [sd].[IMPUESTO4] > 0 THEN
                           ROUND(([sd].[PRICE] / (1 + ROUND([sd].[IMPUESTO4] / 100, @ROUND_DECIMALS))), @ROUND_DECIMALS)
                       ELSE
                           [sd].[PRICE]
                   END,
                   [sd].[COSTO_PROM],
                   [sd].[IMPUESTO1],
                   [sd].[IMPUESTO2],
                   [sd].[IMPUESTO3],
                   [sd].[IMPUESTO4],
                   [sd].[IMP1APLICA],
                   [sd].[IMP2APLICA],
                   [sd].[IMP3APLICA],
                   [sd].[IMP4APLICA],
                   0,
                   0,
                   0,
                   CASE
                       WHEN [sd].[IMPUESTO4] > 0 THEN
                           ROUND((([sd].[TOTAL_WITHOUT_TAX]-ISNULL([sd].[DISCOUNT_AMOUNT],0)) * ([sd].[IMPUESTO4] / 100)), @ROUND_DECIMALS)
                       ELSE
                           0
                   END,
                   [sd].[DISCOUNT],
                   0,
                   0,
                   0,
                   0,
                   'N',
                   [so].[WAREHOUSE],
                   '',
                   1,
                   [sd].[UNI_MED],
                   [sd].[TIPO_ELE],
                   'N',
                   0,
                   0,
                   0,
                   0,
                   [sd].[DISPLAY_AMOUNT],
                   'S',
                   [sd].[MAN_IEPS],
                   [sd].[APL_MAN_IMP],
                   [sd].[CUOTA_IEPS],
                   [sd].[APL_MAN_IEPS],
                   0,
                   0,
                   [sd].[CVE_ESQIMPU],
                   NEWID(),
                   GETDATE()
            FROM [#SO_DETAIL] [sd]
                INNER JOIN [#SALES_ORDER] [so]
                    ON [so].[SALES_ORDER_ID] = [sd].[SALES_ORDER_ID]
            WHERE [sd].[SKU] = @CODE_SKU
                  AND [sd].[LINE_SEQ] = @LINE_SEQ;

            SELECT @TOTAL_WITHOUT_TAX
                = (@TOTAL_WITHOUT_TAX
                   + (CASE
                          WHEN [sd].[IMP4APLICA] = 1 THEN
                              ROUND(([sd].[DISPLAY_AMOUNT] * ([sd].[IMPUESTO4] / 100)), @ROUND_DECIMALS)
                          ELSE
                              [sd].[DISPLAY_AMOUNT]
                      END
                     )
                  ),
                   @TOTAL_TAX
                       = (@TOTAL_TAX
                          + (CASE
                                 WHEN [sd].[IMP4APLICA] = 1 THEN
                                     ROUND(([sd].[TOTAL_WITHOUT_TAX] * ([sd].[IMPUESTO4] / 100)), @ROUND_DECIMALS)
                                 ELSE
                                     0
                             END
                            )
                         ),
                   @TOTAL_DESC = (@TOTAL_DESC + ISNULL([sd].[DISCOUNT_AMOUNT],0)),
				   @TOTAL_DOC = (@TOTAL_DOC + ISNULL([sd].[DISPLAY_AMOUNT],0))
            FROM [#SO_DETAIL] [sd]
            WHERE [sd].[SKU] = @CODE_SKU
                  AND [sd].[LINE_SEQ] = @LINE_SEQ;

            --Insert Sales Order Detail User Fields
            INSERT INTO [SAE70EMPRESA01].[dbo].[PAR_FACTP_CLIB01]
            (
                [CLAVE_DOC],
                [NUM_PART]
            )
            VALUES
            (@FULL_SAE_DOCUMENT, (@LINE_SEQ + 1));

            DELETE FROM [#SO_DETAIL]
            WHERE [SKU] = @CODE_SKU
                  AND [LINE_SEQ] = @LINE_SEQ;

        END;

        UPDATE [SAE70EMPRESA01].[dbo].[FACTP01]
        SET [BLOQ] = 'N',
            [CAN_TOT] = @TOTAL_WITHOUT_TAX,
            [IMP_TOT4] = @TOTAL_TAX,
			[DES_TOT] = @TOTAL_DESC,
			[IMPORTE] = @TOTAL_DOC
        WHERE [CVE_DOC] = @FULL_SAE_DOCUMENT;

        COMMIT;
        SELECT 1 AS [Resultado],
               ('Proceso Exitoso: ' + @FULL_SAE_DOCUMENT) [Mensaje],
               0 [Codigo],
               (@FULL_SAE_DOCUMENT + ' - ' + CAST(@SO_ID AS VARCHAR(MAX))) [DbData];

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERROR_MSG VARCHAR(500) = ERROR_MESSAGE();

        --
        SELECT -1 AS [Resultado],
               ('Proceso fallido: ' + @ERROR_MSG) [Mensaje],
               0 [Codigo],
               '0' [DbData];

    END CATCH;

END;



