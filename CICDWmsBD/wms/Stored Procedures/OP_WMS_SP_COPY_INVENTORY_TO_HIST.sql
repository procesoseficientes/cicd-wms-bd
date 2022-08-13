-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	08-07-2016 Sprint ζ
-- Description:			    Se agrego los campos de lote y vin a OP_WMS_SP_COPY_INVENTORY_TO_HIST


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-28 Nexus@AgeOfEmpires
-- Description:	 Se agrega where para descartar lineas con cantidad 0. 

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-ZERO
					-- pablo.aguilar
					-- Se agrega material id a historico.




-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_COPY_INVENTORY_TO_HIST
    @pRESULT varchar(300) OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
		

	BEGIN TRY


INSERT INTO [wms].OP_WMS_INV_HISTORY(
         REGIMEN
         ,CLIENT_NAME
         ,CLIENT_OWNER
         ,NUMERO_ORDEN
         ,LICENSE_ID
         ,BARCODE_ID
         ,MATERIAL_NAME
		, MATERIAL_ID
         ,QTY
         ,CURRENT_LOCATION 
         ,BODEGA 
         ,VALOR_UNITARIO
         ,TOTAL_VALOR
         ,VOLUMEN
         ,TOTAL_VOLUMEN
         ,TERMS_OF_TRADE
         ,SNAPSHOT_DATE
         ,PROCESSED_BY_ERP
         ,ERP_REFERENCE
         ,BATCH
         ,DATE_EXPIRATION
         ,VIN
      )
			SELECT
				'FISCAL'
        , A.CLIENT_NAME
        , A.CLIENT_OWNER
        , A.NUMERO_ORDEN
        , A.LICENSE_ID
        , A.BARCODE_ID
        , A.MATERIAL_NAME
		, A.MATERIAL_ID
        , A.QTY
        , A.CURRENT_LOCATION
        , A.BODEGA
        , A.VALOR_UNITARIO
        , A.TOTAL_VALOR
        , A.VOLUMEN
        , A.TOTAL_VOLUMEN
        , A.TERMS_OF_TRADE        
        , GETDATE()
        , NULL
        , 0
        , A.BATCH
        , A.DATE_EXPIRATION
        , A.VIN
			FROM [wms].OP_WMS_VIEW_VALORIZACION_FISCAL A
        WHERE [A].[QTY] > 0 
			
			INSERT INTO [wms].OP_WMS_INV_HISTORY(
         REGIMEN
         ,CLIENT_NAME
         ,CLIENT_OWNER
         ,NUMERO_ORDEN
         ,LICENSE_ID
         ,BARCODE_ID
         ,MATERIAL_NAME
		 ,MATERIAL_ID
         ,QTY
         ,CURRENT_LOCATION 
         ,BODEGA 
         ,VALOR_UNITARIO
         ,TOTAL_VALOR
         ,VOLUMEN
         ,TOTAL_VOLUMEN
         ,TERMS_OF_TRADE
         ,SNAPSHOT_DATE
         ,PROCESSED_BY_ERP
         ,ERP_REFERENCE
         ,BATCH
         ,DATE_EXPIRATION
         ,VIN
      )
			SELECT
				'GENERAL'
        , A.CLIENT_NAME
        , A.CLIENT_OWNER
        , A.NUMERO_ORDEN
        , A.LICENSE_ID
        , A.BARCODE_ID
        , A.MATERIAL_NAME
		, A.MATERIAL_ID
        , A.QTY
        , A.CURRENT_LOCATION
        , A.BODEGA
        , A.VALOR_UNITARIO
        , A.TOTAL_VALOR
        , A.VOLUMEN
        , A.TOTAL_VOLUMEN
        , A.TERMS_OF_TRADE        
        , GETDATE()
        , NULL
        , 0
        , A.BATCH
        , A.DATE_EXPIRATION
        , A.VIN
			FROM [wms].OP_WMS_VIEW_VALORIZACION_ALMGEN A
			WHERE [A].[QTY] > 0 
			
			SELECT	@pResult	= 'OK'								

	END TRY
	BEGIN CATCH
		SELECT	@pResult	= ERROR_MESSAGE()
		INSERT INTO [wms].[OP_LOG]
		VALUES (CURRENT_TIMESTAMP,'OP_WMS_SP_INV_X_LIC_TO_HIST',@pResult)
      PRINT '@pResult: '+  @pResult 
	END CATCH
   
END