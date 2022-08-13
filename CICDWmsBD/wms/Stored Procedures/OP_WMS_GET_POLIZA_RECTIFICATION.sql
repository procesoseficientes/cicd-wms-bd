-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	07-07-2016 Sprint ζ
-- Description:			    Obtiene las polizas rectificadas.

-- =============================================

CREATE PROCEDURE [wms].OP_WMS_GET_POLIZA_RECTIFICATION
    
AS
BEGIN
  SELECT 
    PH.*
    ,VC.CLIENT_NAME    
  FROM [wms].OP_WMS_POLIZA_HEADER PH
  INNER JOIN [wms].OP_WMS_VIEW_CLIENTS VC ON (PH.CLIENT_CODE = VC.CLIENT_CODE)
  WHERE 
    PH.PENDIENTE_RECTIFICACION = 1

END