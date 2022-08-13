-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	

-- Modificacion:	rudi.garcia
-- Fecha de Creacion: 	2017-05-29 @ Team ERGON - Sprint Sheik
-- Description:	      Se agrego la validacion que si el cliente no tiene una poliza de seguro retorne la de la empresa.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_INSURANCE_DOC_BY_CLIENT] @CODE_CLIENT = 'arium' -- varchar(50)
			--
			EXEC [wms].[OP_WMS_SP_GET_INSURANCE_DOC_BY_CLIENT] @CODE_CLIENT = 'wms' -- varchar(50)
*/
-- =============================================
--
--GO

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INSURANCE_DOC_BY_CLIENT] (
		@CODE_CLIENT VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF EXISTS ( SELECT
					1
				FROM
					[wms].[OP_WMS_INSURANCE_DOCS] [I]
				WHERE
					GETDATE() BETWEEN [I].[VALIN_FROM]
								AND		[I].[VALIN_TO]
					AND [I].[AMOUNT] > 0
					AND [I].[CLIENT_CODE] = @CODE_CLIENT )
	BEGIN
		SELECT
			CONVERT(VARCHAR(200), [PS].[DOC_ID]) AS [DOC_ID]
			,[PS].[COMPANY_ID]
			,[PS].[AMOUNT]
			,[PS].[AVAILABLE]
			,[PS].[LAST_TXN_DATE]
			,[PS].[CREATED_DATE]
			,[PS].[CREATED_BY]
			,[PS].[LAST_UPDATED]
			,[PS].[LAST_UPDATED_BY]
			,[PS].[CLIENT_CODE]
			,[PS].[COVERAGE]
			,[PS].[VALIN_FROM]
			,[PS].[VALIN_TO]
			,[PS].[POLIZA_INSURANCE]
			,[PS].[INSURANCE_OWHEN]
		FROM
			[wms].[OP_WMS_INSURANCE_DOCS] [PS]
		WHERE
			GETDATE() BETWEEN [PS].[VALIN_FROM]
						AND		[PS].[VALIN_TO]
			AND [PS].[AMOUNT] > 0
			AND [PS].[CLIENT_CODE] = @CODE_CLIENT;
	END;
	ELSE
	BEGIN
		SELECT
			[C].[TEXT_VALUE] AS [DOC_ID]
			,[C].[PARAM_CAPTION] AS [POLIZA_INSURANCE]
		FROM
			[wms].[OP_WMS_FUNC_GET_PARAMETROS_GENERALES]('POLIZAS',
											'POLIZAS_SEGUROS') [C];
	END;
END;