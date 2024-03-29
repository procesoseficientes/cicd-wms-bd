﻿-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	07-07-2016 Sprint ζ
-- Description:			    Estable la poliza de rectificacion.

-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_SET_POLIZA_PENDING_RECTIFICATION
    @DOC_ID NUMERIC(18)    
    ,@CODIGO_POLIZA_RECTIFADA VARCHAR(18)
    ,@COMENTARIO_RECTIFICACION VARCHAR (250)
    ,@CLASE_POLIZA_RECTIFICACION VARCHAR(200)
    ,@LAST_UPDATED_BY VARCHAR(25)
AS
BEGIN  
  BEGIN TRY   
    INSERT INTO [wms].OP_WMS_RECTIFICATION_HISTORY(
      DOC_ID_RECTIFADA 
      ,NUMERO_ORDEN_RECTIFADA
      ,CODIGO_POLIZA_RECTIFADA
      ,CLASE_POLIZA_RECTIFADA
      ,COMENTARIO_RECTIFADA      
      ,LICENSE_ID
      ,MATERIAL_ID
      ,MATERIAL_NAME
      ,BARCODE_ID
      ,QTY
      ,BATCH
      ,DATE_EXPIRATION
      ,VIN
      ,FECHA_RECTIFICADA
      ,OPERADOR_RECTIFICADA
    )
    SELECT
      PH.DOC_ID
      ,PH.NUMERO_ORDEN
      ,PH.CODIGO_POLIZA
      ,@CLASE_POLIZA_RECTIFICACION
      ,@COMENTARIO_RECTIFICACION
      ,IL.LICENSE_ID
      ,IL.MATERIAL_ID
      ,IL.MATERIAL_NAME
      ,IL.BARCODE_ID
      ,IL.ENTERED_QTY
      ,IL.BATCH
      ,IL.DATE_EXPIRATION
      ,IL.VIN
      ,GETDATE()
      ,@LAST_UPDATED_BY
    FROM [wms].OP_WMS_INV_X_LICENSE IL
    INNER JOIN [wms].OP_WMS_LICENSES L ON (IL.LICENSE_ID  = L.LICENSE_ID)
    INNER JOIN [wms].OP_WMS_POLIZA_HEADER PH ON (L.CODIGO_POLIZA = PH.CODIGO_POLIZA)
    WHERE
      PH.DOC_ID = @DOC_ID

    UPDATE [wms].OP_WMS_POLIZA_HEADER SET 
      PENDIENTE_RECTIFICACION = 1    
      ,COMENTARIO_RECTIFICADO = @COMENTARIO_RECTIFICACION
      ,CLASE_POLIZA_RECTIFICACION = @CLASE_POLIZA_RECTIFICACION
      ,LAST_UPDATED = GETDATE()
      ,LAST_UPDATED_BY = @LAST_UPDATED_BY
    WHERE DOC_ID = @DOC_ID
    
    
    UPDATE [wms].OP_WMS_LICENSES SET
      CODIGO_POLIZA_RECTIFICACION = @CODIGO_POLIZA_RECTIFADA
      ,CODIGO_POLIZA = NULL
      ,LAST_UPDATED = GETDATE()
      ,LAST_UPDATED_BY = @LAST_UPDATED_BY
    WHERE CODIGO_POLIZA = @CODIGO_POLIZA_RECTIFADA

   END TRY	
	 BEGIN CATCH
	    SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO
	 END CATCH
END