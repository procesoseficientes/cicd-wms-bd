-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	 Consulta a los acuerdos comerciales por cliente




/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_TRADE_AGREEMENT_BY_CLIENT (@CLIENT_CODE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
--
  SELECT 
  [T].[CLIENT_CODE]
 ,[T].[ACUERDO_COMERCIAL]
 ,[T].[DESCRIPCION] FROM [wms].[OP_WMS_VIEW_CUSTOMER_TERMS_OF_TRADE] [T]
    WHERE [T].[CLIENT_CODE] = @CLIENT_CODE

END