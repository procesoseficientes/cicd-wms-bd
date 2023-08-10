
-- =============================================
-- Autor:	            Alejandro.Ochoa
-- Fecha de Creacion: 	17/07/2019
-- Description:	        Sp que realiza el envio de modificaciones de Clientes (GPS) de SONDA a SAE 

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SONDA_SP_SENT_SAE_CUSTOMER_CHANGES]
				@OWNER = 'SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_SENT_SAE_CUSTOMER_CHANGES]
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
    SELECT [scc].[CUSTOMER]
    INTO [#CUSTOMER_CHANGES]
    FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_CUSTOMER_CHANGE] [scc]
    WHERE ISNULL([scc].[IS_POSTED_ERP], 0) = 0
		AND [scc].[GPS]<>'0,0'
    ORDER BY [scc].[CUSTOMER] ASC;

    WHILE EXISTS (SELECT TOP (1) 1 FROM [#CUSTOMER_CHANGES])
    BEGIN

        DECLARE @CUSTOMER_CHANGE INT = 0,
                @RESPONSE VARCHAR(MAX),
                @REFERENCE VARCHAR(MAX),
                @SUCCESS INT;

        BEGIN TRY
            SELECT TOP (1)
                   @CUSTOMER_CHANGE = [CUSTOMER]
            FROM [#CUSTOMER_CHANGES]
            ORDER BY [CUSTOMER] ASC;

            INSERT INTO @OPERATION
            (
                [RESULT],
                [MESSAGE],
                [CODE],
                [DBDATA]
            )
            EXEC [ERP_SERVER].[ASPEL_INTERFACES].[dbo].[SAE_UPDATE_CUSTOMER_GPS] @CUSTOMER = @CUSTOMER_CHANGE;

            SELECT TOP (1)
                   @RESPONSE = [MESSAGE],
                   @REFERENCE = LTRIM(RTRIM([DBDATA])),
                   @SUCCESS = [RESULT]
            FROM @OPERATION
            ORDER BY [RESULT];

            IF (@SUCCESS = 1)
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP_SET_STATUS_SEND_CUSTOMER_CHANGE_TO_ERP] @CUSTOMER = @CUSTOMER_CHANGE,        -- int
                                                                                               @POSTED_RESPONSE = @RESPONSE; -- varchar(150)
                
            END;
            ELSE
            BEGIN
                EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP_SET_STATUS_ERROR_CUSTOMER_CHANGE_TO_ERP] @CUSTOMER = @CUSTOMER_CHANGE,       -- varchar(50)
                                                                                                @POSTED_RESPONSE = @RESPONSE; -- varchar(150)
            END;

        END TRY
        BEGIN CATCH

            DECLARE @ERROR_MESSAGE VARCHAR(500) = ERROR_MESSAGE();
            EXEC [SWIFT_EXPRESS].[SONDA].[SWIFT_SP_SET_STATUS_ERROR_CUSTOMER_CHANGE_TO_ERP] @CUSTOMER = @CUSTOMER_CHANGE,       -- varchar(50)
                                                                                            @POSTED_RESPONSE = @ERROR_MESSAGE; -- varchar(150)
            ;
        END CATCH;

        DELETE @OPERATION;

        DELETE FROM [#CUSTOMER_CHANGES]
        WHERE [CUSTOMER] = @CUSTOMER_CHANGE

    END;


END;