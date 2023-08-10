
-- =============================================
-- Autor:	            Alejandro.Ochoa
-- Fecha de Creacion: 	17/07/2019
-- Description:	        Sp que realiza el envio de documentos de Venta (Pedidos) de SONDA a SAE 

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SONDA_SP_SENT_SAE_SALES_ORDER_DOCUMENTS]
				@OWNER = 'SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_SENT_SAE_SALES_ORDER_DOCUMENTS]
(@OWNER VARCHAR(50))
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
    SELECT [ssoh].[SALES_ORDER_ID]
    INTO [#SALES_ORDER]
    FROM [SWIFT_EXPRESS].[SONDA].[SONDA_SALES_ORDER_HEADER] [ssoh]
    WHERE ISNULL([IS_POSTED_ERP], 0) = 0
          AND ISNULL([ssoh].[IS_SENDING], 0) = 0
          AND ISNULL([ssoh].[IS_DRAFT], 0) = 0
		  AND ISNULL([ssoh].[IS_VOID], 0) = 0
          AND [ssoh].[IS_READY_TO_SEND] = 1
          AND CAST([ssoh].[POSTED_DATETIME] AS DATE) >= CAST(GETDATE()-4 AS DATE)
    ORDER BY [ssoh].[SALES_ORDER_ID] ASC;

    UPDATE [SSOH]
    SET [SSOH].[IS_SENDING] = 1,
        [SSOH].[LAST_UPDATE_IS_SENDING] = GETDATE()
    FROM [SWIFT_EXPRESS].[SONDA].[SONDA_SALES_ORDER_HEADER] [SSOH]
        INNER JOIN [#SALES_ORDER] [SO]
            ON ([SO].[SALES_ORDER_ID] = [SSOH].[SALES_ORDER_ID])
	WHERE [SO].[SALES_ORDER_ID] = [SSOH].[SALES_ORDER_ID];

    WHILE EXISTS (SELECT TOP (1) 1 FROM [#SALES_ORDER])
    BEGIN

        DECLARE @SALES_ORDER_ID INT = 0,
                @RESPONSE VARCHAR(MAX),
                @REFERENCE VARCHAR(MAX),
                @SUCCESS INT;

        BEGIN TRY
            SELECT TOP (1)
                   @SALES_ORDER_ID = [SALES_ORDER_ID]
            FROM [#SALES_ORDER]
            ORDER BY [SALES_ORDER_ID] ASC;

            INSERT INTO @OPERATION
            (
                [RESULT],
                [MESSAGE],
                [CODE],
                [DBDATA]
            )
            EXEC [ERP_SERVER].[ASPEL_INTERFACES].[dbo].[SAE_CREATE_SALES_ORDER] @SALES_ORDER_ID = @SALES_ORDER_ID;

            SELECT TOP (1)
                   @RESPONSE = [MESSAGE],
                   @REFERENCE = LTRIM(RTRIM([DBDATA])),
                   @SUCCESS = [RESULT]
            FROM @OPERATION
            ORDER BY [RESULT];

            IF (@SUCCESS = 1)
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-SEND_SO_TO_SAP] @SALES_ORDER_ID = @SALES_ORDER_ID,
                                                                              @POSTED_RESPONSE = @RESPONSE,
                                                                              @ERP_REFERENCE = @REFERENCE,
                                                                              @OWNER = @OWNER,
                                                                              @CUSTOMER_OWNER = @OWNER;
            END;
            ELSE
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-ERROR_SO_TO_SAP] @SALES_ORDER_ID = @SALES_ORDER_ID,
                                                                               @POSTED_RESPONSE = @RESPONSE,
                                                                               @OWNER = @OWNER,
                                                                               @CUSTOMER_OWNER = @OWNER;
            END;

        END TRY
        BEGIN CATCH

            DECLARE @ERROR_MESSAGE VARCHAR(500) = ERROR_MESSAGE();
            EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP-STATUS-ERROR_SO_TO_SAP] @SALES_ORDER_ID = @SALES_ORDER_ID,
                                                                           @POSTED_RESPONSE = @ERROR_MESSAGE,
                                                                           @OWNER = @OWNER,
                                                                           @CUSTOMER_OWNER = @OWNER;
        END CATCH;

        DELETE @OPERATION;

        DELETE FROM [#SALES_ORDER]
        WHERE [SALES_ORDER_ID] = @SALES_ORDER_ID;

    END;


END;