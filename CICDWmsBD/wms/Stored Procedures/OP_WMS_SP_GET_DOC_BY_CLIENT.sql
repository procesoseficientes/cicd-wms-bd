-- =============================================
-- Author:		rudi.garcia
-- Create date: 15-02-2016
-- Description:	Obtiene las recepciones por cliente
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_DOC_BY_CLIENT
	@CLIENT_CODE VARCHAR(25)
	,@DATE_START DATETIME
	,@DATE_END DATETIME
AS
BEGIN
	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT 
		DOC_ID
		,CODIGO_POLIZA
		,WAREHOUSE_REGIMEN
		,FECHA_DOCUMENTO
		,CLIENT_CODE
	FROM [wms].[OP_WMS_POLIZA_HEADER] PH
	WHERE 
    TIPO = 'INGRESO'
    AND CLIENT_CODE = @CLIENT_CODE
	  AND CONVERT(DATE, PH.FECHA_DOCUMENTO) BETWEEN @DATE_START AND @DATE_END   
	ORDER BY FECHA_DOCUMENTO ASC
END