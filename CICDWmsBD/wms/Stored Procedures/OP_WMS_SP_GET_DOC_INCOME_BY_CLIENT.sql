-- =============================================
-- Author:     	rudi.garcia
-- Create date: 2016-03-07 17:41:53
-- Description: Obtiene los documentos de ingreso de un cliente especifico con un rango de fecha


/*
Ejemplo de Ejecucion:
							EXEC [wms].OP_WMS_SP_GET_DOC_INCOME_BY_CLIENT @CODE_CLIENT = 'C40' , @START_DATE = '20160101', @END_DATE = '20160703'
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_GET_DOC_INCOME_BY_CLIENT @CODE_CLIENT VARCHAR(25)
, @START_DATE DATE
, @END_DATE DATE
AS
  SELECT DISTINCT
    PH.DOC_ID
   ,PH.CODIGO_POLIZA
   ,PH.NUMERO_ORDEN
   ,PH.NUMERO_DUA
   ,PH.FECHA_LLEGADA
   ,PH.LAST_UPDATED
   ,PH.CLIENT_CODE
  FROM [wms].OP_WMS_POLIZA_HEADER PH
  INNER JOIN [wms].OP_WMS_LICENSES L
    ON (PH.CODIGO_POLIZA = L.CODIGO_POLIZA
    AND PH.CLIENT_CODE = L.CLIENT_OWNER)
  WHERE PH.TIPO = 'INGRESO'
  AND PH.CLIENT_CODE = @CODE_CLIENT
  AND CONVERT(DATE, PH.LAST_UPDATED) BETWEEN @START_DATE AND @END_DATE