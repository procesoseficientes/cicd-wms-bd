-- =============================================
-- Author:     	diego.as
-- Create date: 2018-04-30
-- Description: La cuenta corriente de todos los clientes del plan de ruta o de uno especifico

/*
Ejemplo de Ejecucion:
          
	-- Para obtener la cuenta corriente de todos los clientes del plan de ruta
    EXEC [SONDA].[SONDA_SP_GET_CUSTOMER_ACCOUNTING_INFORMATION] @CODE_ROUTE = '32'
          
	-- Para obtener la cuenta corriente de un cliente en especifico
	EXEC [SONDA].[SONDA_SP_GET_CUSTOMER_ACCOUNTING_INFORMATION] @CODE_ROUTE = '46', @CODE_CUSTOMER = '860802'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_CUSTOMER_ACCOUNTING_INFORMATION]
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
		---- Se valida si se obtienen toda la cuenta corriente de los clientes del plan de ruta o solo con un cliente especifico
		---- ----------------------------------------------------------------------------------------------------------------
		IF @CODE_CUSTOMER IS NULL
		BEGIN
	
			-- ----------------------------------------------------------------------------------
			-- Se obtienen todos los clientes del plan de ruta
			-- ----------------------------------------------------------------------------------
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
			--  -- Se estable el cliente para el que se obtendra la cuenta corriente
			--  -- ----------------------------------------------------------------------------------
			INSERT	INTO [#CUSTOMER]
					([CODE_CUSTOMER])
			VALUES
					(@CODE_CUSTOMER);

		END;

		-- -------------------------------------------------------------------------------------------
		-- Obtenemos la cuenta corriente del cliente o los clientes que se hayan configurado
		-- -------------------------------------------------------------------------------------------
		SELECT
			[AI].[ID]
			,[AI].[CODE_CUSTOMER]
			,[AI].[GROUP_NUM]
			,[AI].[CREDIT_LIMIT]
			,[AI].[OUTSTANDING_BALANCE]
			,[AI].[EXTRA_DAYS]
		FROM
			[SONDA].[SWIFT_CUSTOMER_ACCOUNTING_INFORMATION] AS [AI]
		INNER JOIN [#CUSTOMER] AS [C]
		ON	[C].[CODE_CUSTOMER] = [AI].[CODE_CUSTOMER]
		WHERE
			[AI].[ID] > 0;

	END;
