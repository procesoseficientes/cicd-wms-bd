-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	4/29/2018 @ G-FORCE TEAM - Sprint CASTOR
-- Description:			SP que importa las facturas vencidas de los clientes

-- Modificacion 10/26/2018 @ A-Team Sprint G-FORCE@LEON
-- diego.as
-- Se elimina condicion de fechas en el openquery para que ahora se puedan importar todas las facturas sin importar si esta vencida o no

/*
-- Ejemplo de Ejecucion:
      		EXEC [SONDA].[SWIFT_SP_IMPORT_OVERDUE_INVOICE]
*/
-- =============================================
CREATE PROC [SONDA].[SWIFT_SP_IMPORT_OVERDUE_INVOICE]
AS
BEGIN
    --
    SET NOCOUNT ON;
    --
    DECLARE @QUERY VARCHAR(MAX);

    BEGIN TRY
        -- -------------------------------------------------------------
        -- Definimos la tabla temporal que almacenara los clientes
        -- -------------------------------------------------------------
        CREATE TABLE [#CUSTOMER]
        (
            [CUSTOMER_ID] INT IDENTITY(1, 1) PRIMARY KEY,
            [CODE_CUSTOMER] VARCHAR(250),
			[DAYS_TO_ADD] INT
        );


        -- ------------------------------------------------------------
        -- Definimos tabla para almacenar las facturas
        -- ------------------------------------------------------------
        CREATE TABLE [#OVERDUE_INVOICE_BY_CUSTOMER]
        (
            [ID] INT IDENTITY(1, 1),
            [INVOICE_ID] VARCHAR(20) NOT NULL,
            [DOC_ENTRY] VARCHAR(20) NOT NULL,
            [CODE_CUSTOMER] VARCHAR(250) NOT NULL,
            [CREATED_DATE] DATETIME,
            [DUE_DATE] DATETIME,
            [TOTAL_AMOUNT] NUMERIC(18, 6),
            [PENDING_TO_PAID] NUMERIC(18, 6),
            PRIMARY KEY (
                            [ID],
                            [INVOICE_ID],
                            [DOC_ENTRY]
                        )
        );

        -- -------------------------------------------------------------
        -- Creamos un indice sobre la tabla
        -- -------------------------------------------------------------
        CREATE NONCLUSTERED INDEX [IDX_CUSTOMER_TO_PROCESS]
        ON [#CUSTOMER] (
                           [CUSTOMER_ID],
                           [CODE_CUSTOMER]
                       );

        -- INICIAMOS TRANSACCION
        BEGIN TRAN;

        -- -------------------------------------------------------------
        -- Limpiamos la tabla
        -- -------------------------------------------------------------
        TRUNCATE TABLE [SONDA].[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER];

        -- -------------------------------------------------------------
        -- Obtenemos los clientes
        -- -------------------------------------------------------------
        INSERT INTO [#CUSTOMER]
        (
            [CODE_CUSTOMER],
			[DAYS_TO_ADD]
        )
        SELECT [CODE_CUSTOMER],CASE WHEN ISNULL([CREDIT_LIMIT],0) = 0 THEN 10 ELSE 20 END
        FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER];

        -- ------------------------------------------------------------
        -- Armamos y Ejecutamos la consulta
        -- ------------------------------------------------------------
        SELECT @QUERY
            = '
				INSERT INTO [#OVERDUE_INVOICE_BY_CUSTOMER]
					SELECT 
						IV.INVOICE_ID
						,IV.DOC_ENTRY
						,IV.CODE_CUSTOMER
						,IV.CREATED_DATE
						,IV.DUE_DATE AS DUE_DATE
						,IV.TOTAL_AMOUNT
						,IV.PENDING_TO_PAID
					FROM OPENQUERY([ERP_SERVER], ''
						 SELECT LTRIM(RTRIM([CUENM].[NO_FACTURA])) [INVOICE_ID],
								LTRIM(RTRIM([CUENM].[REFER])) [DOC_ENTRY],
								LTRIM(RTRIM([CUENM].[CVE_CLIE])) AS [CODE_CUSTOMER],
								[CUENM].[FECHA_APLI] [CREATED_DATE],
								[CUENM].[FECHA_VENC] [DUE_DATE],
								[CUENM].[IMPORTE] [TOTAL_AMOUNT],
								CAST(((CASE WHEN SUM([CUEN].[IMPORTE] * [CUEN].[SIGNO] / 1) IS NULL THEN 0
											ELSE SUM([CUEN].[IMPORTE] * [CUEN].[SIGNO] / 1)
										END
										) + [CUENM].[IMPORTE] * [CUENM].[SIGNO] / 1) 
									AS DOUBLE PRECISION) AS [PENDING_TO_PAID]
						FROM [SAE70EMPRESA01].[dbo].[CUEN_M01] [CUENM]
							LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE01] [CLIENTES]
								ON [CLIENTES].[CLAVE] = [CUENM].[CVE_CLIE]
							LEFT JOIN [SAE70EMPRESA01].[dbo].[CUEN_DET01] [CUEN]
								ON [CUEN].[CVE_CLIE] = [CUENM].[CVE_CLIE]
									AND [CUEN].[REFER] = [CUENM].[REFER]
									AND [CUEN].[NUM_CARGO] = [CUENM].[NUM_CARGO]
									AND [CUEN].[ID_MOV] = [CUENM].[NUM_CPTO]
						WHERE [CUENM].[NUM_CPTO] IN ( 1, 3, 4, 5, 7, 18, 21, 22, 24, 25, 1001 )
						GROUP BY [CUENM].[NO_FACTURA],
									[CUENM].[REFER],
									[CUENM].[CVE_CLIE],
									[CUENM].[FECHA_APLI],
									[CUENM].[FECHA_VENC],
									[CUENM].[IMPORTE],
									[CUENM].[SIGNO],
									[CUENM].[DOCTO]
						HAVING (ABS((CASE WHEN SUM([CUEN].[IMPORTE] * [CUEN].[SIGNO]) IS NULL THEN 0
										ELSE SUM([CUEN].[IMPORTE] * [CUEN].[SIGNO])
									END) + [CUENM].[IMPORTE] * [CUENM].[SIGNO]) >= 0.006)
						ORDER BY [CUENM].[CVE_CLIE],
									[CUENM].[DOCTO]
				'') AS IV
				INNER JOIN #CUSTOMER AS VC
				ON ([IV].CODE_CUSTOMER COLLATE DATABASE_DEFAULT = [VC].[CODE_CUSTOMER] COLLATE DATABASE_DEFAULT)
				WHERE ROUND(IV.PENDING_TO_PAID, 2) > 25.00
					';
        EXECUTE (@QUERY);

        -- -------------------------------------------------------------------
        -- Insertamos en nuestra tabla que almacena toda la informacion
        -- -------------------------------------------------------------------
        INSERT INTO [SONDA].[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER]
        (
            [INVOICE_ID],
            [DOC_ENTRY],
            [CODE_CUSTOMER],
            [CREATED_DATE],
            [DUE_DATE],
            [TOTAL_AMOUNT],
            [PENDING_TO_PAID],
            [IS_EXPIRED]
        )
        SELECT [OI].[INVOICE_ID],
               [OI].[DOC_ENTRY],
               [OI].[CODE_CUSTOMER],
               [OI].[CREATED_DATE],
               [OI].[DUE_DATE],
               [OI].[TOTAL_AMOUNT],
               [OI].[PENDING_TO_PAID],
               CASE
                   WHEN CAST(GETDATE() AS DATE) > [OI].[DUE_DATE] THEN
                       1
                   ELSE
                       0
               END
        FROM [#OVERDUE_INVOICE_BY_CUSTOMER] AS [OI]
        WHERE [OI].[ID] > 0;

        -- FINALIZAMOS TRANSACCION
        COMMIT;
    END TRY
    BEGIN CATCH
        --
        DECLARE @ERROR_MESSAGE VARCHAR(MAX);
        SET @ERROR_MESSAGE = ERROR_MESSAGE();

        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK;
        END;

        --
        EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = '',                                  -- varchar(50)
                                                              @LOGIN = '',                                       -- varchar(50)
                                                              @SOURCE_ERROR = 'SWIFT_SP_IMPORT_OVERDUE_INVOICE', -- varchar(250)
                                                              @DOC_RESOLUTION = '',                              -- varchar(100)
                                                              @DOC_SERIE = '',                                   -- varchar(100)
                                                              @DOC_NUM = 0,                                      -- int
                                                              @MESSAGE_ERROR = @ERROR_MESSAGE,                   -- varchar(max)
                                                              @SEVERITY_CODE = 5000;                             -- int

    --


    END CATCH;

END;











