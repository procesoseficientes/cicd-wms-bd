-- =============================================
-- Author:     	diego.as
-- Create date: 2018-04-30
-- Description: Obtiene los encabezados de facturas vencidas de todos los clientes del plan de ruta o de uno especifico

-- Author:     	diego.as
-- Create date: 2018-10-30
-- Description: Se agrega columna IS_EXPIRED que indica si la factura esta expirada (valor 1) o aun no (valor 0)


/*
Ejemplo de Ejecucion:
          
	-- Para obtener todas las facturas
    EXEC [SONDA].[SONDA_SP_GET_OVERDUE_INVOICE_BY_CUSTOMER] @CODE_ROUTE = '32'
          
	-- Para obtener todas las facturas por cliente
	EXEC [SONDA].[SONDA_SP_GET_OVERDUE_INVOICE_BY_CUSTOMER] @CODE_ROUTE = '46', @CODE_CUSTOMER = 'BO-2091'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_OVERDUE_INVOICE_BY_CUSTOMER]
	(
		@CODE_ROUTE AS VARCHAR(50)
		,@CODE_CUSTOMER AS VARCHAR(250) = NULL
	)
AS
	BEGIN
  --
		CREATE TABLE [#CUSTOMER]
			(
				[CODE_CUSTOMER] VARCHAR(50)
			);
  --
		---- ----------------------------------------------------------------------------------------------------------------
		---- Se valida si se obtienen todas las factuas de los clientes del plan de ruta o solo con un cliente especifico
		---- ----------------------------------------------------------------------------------------------------------------
		IF @CODE_CUSTOMER IS NULL
		BEGIN
	
			--  -- ----------------------------------------------------------------------------------
			--  -- Se obtienen todos los clientes del plan de ruta
			--  -- ----------------------------------------------------------------------------------
			INSERT	INTO [#CUSTOMER]
			SELECT
				[RELATED_CLIENT_CODE]
			FROM
				[SONDA].[SONDA_ROUTE_PLAN]
			WHERE
				[CODE_ROUTE] = @CODE_ROUTE
				AND CAST([TASK_DATE] AS DATE) = CAST(GETDATE() AS DATE)
				AND [TASK_TYPE] = 'SALE'
			ORDER BY
				[TASK_SEQ] ASC;

		END;
		ELSE
		BEGIN
			--  -- ----------------------------------------------------------------------------------
			--  -- Se estable el cliente para el que se obtendran las facturas
			--  -- ----------------------------------------------------------------------------------
			INSERT	INTO [#CUSTOMER]
					([CODE_CUSTOMER])
			VALUES
					(@CODE_CUSTOMER);

		END;

		-- -------------------------------------------------------------------------------------------
		-- Obtenemos las facturas del cliente o los clientes que se hayan configurado
		-- -------------------------------------------------------------------------------------------
		SELECT
			[OI].[ID]
			,[OI].[INVOICE_ID]
			,[OI].[DOC_ENTRY]
			,[OI].[CODE_CUSTOMER]
			,[OI].[CREATED_DATE]
			,[OI].[DUE_DATE]
			,[OI].[TOTAL_AMOUNT]
			,[OI].[PENDING_TO_PAID]
			,[OI].[IS_EXPIRED]
		FROM
			[SONDA].[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER] AS [OI]
		INNER JOIN [#CUSTOMER] AS [C]
		ON	[C].[CODE_CUSTOMER] = [OI].[CODE_CUSTOMER]
		WHERE OI.[ID] > 0;

	END;
