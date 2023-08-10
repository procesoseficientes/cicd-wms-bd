-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	03-12-2015
-- Description:			Selecciona las resoluciones de venta filtradas
--                      
/*
-- Ejemplo de Ejecucion:				
				--EXECUTE [SONDA].[SWIFT_SP_GET_DOCUMENT_SEQUENCE] @CODE_ROUTE = '001'
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DOCUMENT_SEQUENCE_BY_ROUTE]
	@CODE_ROUTE [varchar](100)
AS
BEGIN
	SELECT
		CASE S.DOC_TYPE
			WHEN 'SALES_ORDER' THEN 'Orden de Venta'
			WHEN 'PAYMENT' THEN 'Pagos'
			WHEN 'CONSIGNMENT' THEN 'Consignacion'
			ELSE S.DOC_TYPE
		END AS DOC_TYPE
		,S.SERIE
		,CAST(CAST(S.POST_DATETIME AS DATE) AS VARCHAR) POST_DATETIME
		,S.DOC_FROM
		,S.DOC_TO
		,S.CURRENT_DOC
	FROM [SONDA].[SWIFT_DOCUMENT_SEQUENCE] S
	WHERE S.[ASSIGNED_TO] = @CODE_ROUTE 
END
