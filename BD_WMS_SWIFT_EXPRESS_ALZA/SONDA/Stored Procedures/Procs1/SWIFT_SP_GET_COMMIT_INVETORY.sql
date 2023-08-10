-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		07-06-2016
-- Description:			    Reserva el inventario de las ordenes de venta que no se han enviado al ERP

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_COMMIT_INVETORY]
		--
		SELECT * FROM [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_COMMIT_INVETORY
AS
BEGIN
  SET NOCOUNT ON;
  --
	MERGE [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] AS CW
	USING (
		SELECT
			[U].[PRESALE_WAREHOUSE] [CODE_WAREHOUSE]
			,[D].[SKU] [CODE_SKU]
			,SUM([D].[QTY]) [IS_COMITED]
		FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [H]
		INNER JOIN [SONDA].[SONDA_SALES_ORDER_DETAIL] [D] ON (
			[H].[SALES_ORDER_ID] = [D].[SALES_ORDER_ID]
		)
		INNER JOIN [SONDA].[USERS] U ON (
			[H].[POSTED_BY] = [U].[LOGIN]
		)
		WHERE [H].[IS_VOID] = 0
			AND [H].[IS_DRAFT] = 0
			AND [H].[IS_READY_TO_SEND]=0
			AND ([H].[IS_POSTED_ERP] = 0
				OR [H].[IS_POSTED_ERP] IS NULL
			)
		GROUP BY
			[U].[PRESALE_WAREHOUSE]
			,[D].[SKU]
	) [SO]
	ON (
		[CW].[CODE_WAREHOUSE] = [SO].[CODE_WAREHOUSE]
		AND [CW].[CODE_SKU] = [SO].[CODE_SKU]
	)
	WHEN MATCHED
	THEN UPDATE
		SET  [CW].[IS_COMITED] = ([CW].[IS_COMITED] + [SO].[IS_COMITED])
	
	WHEN NOT MATCHED
    THEN INSERT (
		CODE_WAREHOUSE
		,CODE_SKU
		,IS_COMITED
	) VALUES (
		[SO].[CODE_WAREHOUSE]
		,[SO].[CODE_SKU]
		,[SO].[IS_COMITED]
	);
END
