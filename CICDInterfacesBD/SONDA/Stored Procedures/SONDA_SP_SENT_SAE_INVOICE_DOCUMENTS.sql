
-- =============================================
-- Autor:	            Gustavo.Garcia
-- Fecha de Creacion: 	02/04/2020
-- Description:	        Sp que realiza el envio de documentos de Venta (FACTURAS) de SONDA a SAE,se utiliza la misma estructura
--						que [SONDA_SP_SENT_SAE_SALE_DOCUMENTS] para verlos en SAE como ordenes de venta

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SONDA_SP_SENT_SAE_INVOICE_DOCUMENTS]
				@OWNER = 'SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_SENT_SAE_INVOICE_DOCUMENTS]
(@OWNER VARCHAR(50) = 'SONDA')
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OPERATION TABLE
    (
        [RESULT] INT,
        [MESSAGE] VARCHAR(MAX),
        [CODE] INT,
        [DBDATA] VARCHAR(MAX)
    );

    --
    SELECT [spih].[ID]
    INTO [#SALES_INVOICE]
  FROM [SWIFT_EXPRESS].[SONDA].[SONDA_POS_INVOICE_HEADER] [spih]
    WHERE ISNULL([IS_POSTED_ERP], 0) = 0
          AND ISNULL([spih].[IS_SENDING], 0) = 0
          AND ISNULL([spih].[IS_DRAFT], 0) = 0
		  AND ISNULL([spih].[VOIDED_INVOICE], 0) = 0
          AND [spih].[IS_READY_TO_SEND] = 1
          AND CAST([spih].[POSTED_DATETIME] AS DATE) >= CAST(GETDATE()-4 AS DATE)
    ORDER BY [spih].[ID] ASC;

    UPDATE [spih]
    SET [spih].[IS_SENDING] = 1,
        [spih].[LAST_UPDATE_IS_SENDING] = GETDATE()
    FROM [SWIFT_EXPRESS].[SONDA].[SONDA_POS_INVOICE_HEADER] [spih]
        INNER JOIN [#SALES_INVOICE] [SI]
            ON ([SI].[ID] = [spih].[ID])
	WHERE [SI].[ID] = [spih].[ID];

    WHILE EXISTS (SELECT TOP (1) 1 FROM [#SALES_INVOICE])
    BEGIN

        DECLARE @SALES_INVOICE_ID INT = 0,
                @RESPONSE VARCHAR(MAX),
                @REFERENCE VARCHAR(MAX),
                @SUCCESS INT;

        BEGIN TRY
            SELECT TOP (1)
                   @SALES_INVOICE_ID = [ID]
            FROM [#SALES_INVOICE]
            ORDER BY [ID] ASC;

            INSERT INTO @OPERATION
            (
                [RESULT],
                [MESSAGE],
                [CODE],
                [DBDATA]
            )
			--VERIFICAR LA CREACION
            EXEC [ERP_SERVER].[ASPEL_INTERFACES].[dbo].[SAE_CREATE_INVOICE_TO_SALE_ORDER] @SALES_INVOICE_ID = @SALES_INVOICE_ID;

            SELECT TOP (1)
                   @RESPONSE = [MESSAGE],
                   @REFERENCE = LTRIM(RTRIM([DBDATA])),
                   @SUCCESS = [RESULT]
            FROM @OPERATION
            ORDER BY [RESULT];

            IF (@SUCCESS = 1)
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-SEND_INVOICE_TO_SAP] @INVOICE_ID = @SALES_INVOICE_ID,
                                                                              @POSTED_RESPONSE = @RESPONSE,
                                                                              @ERP_REFERENCE = @REFERENCE,
                                                                              @OWNER = @OWNER;
                                                                              --@CUSTOMER_OWNER = @OWNER;

            END;
            ELSE
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-SEND_INVOICE_TO_SAP] @INVOICE_ID = @SALES_INVOICE_ID,
                                                                               @POSTED_RESPONSE = @RESPONSE,
                                                                               @OWNER = @OWNER;
                                                                               --@CUSTOMER_OWNER = @OWNER;
            END;

        END TRY
        BEGIN CATCH

            DECLARE @ERROR_MESSAGE VARCHAR(500) = ERROR_MESSAGE();
            EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-SEND_INVOICE_TO_SAP] @INVOICE_ID = @SALES_INVOICE_ID,
                                                                           @POSTED_RESPONSE = @ERROR_MESSAGE,
                                                                           @OWNER = @OWNER;
                                                                           --@CUSTOMER_OWNER = @OWNER;
        END CATCH;

        DELETE @OPERATION;

        DELETE FROM [#SALES_INVOICE]
        WHERE [ID] = @SALES_INVOICE_ID;

    END;


END;