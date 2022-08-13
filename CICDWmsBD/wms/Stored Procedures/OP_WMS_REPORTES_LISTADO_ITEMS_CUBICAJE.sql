-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_REPORTES_LISTADO_ITEMS_CUBICAJE]
	-- Add the parameters for the stored procedure here
	@CLASIFICACION VARCHAR(250)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    IF @CLASIFICACION='CLIENT_NAME'
     BEGIN
		SELECT
		CLIENT_NAME
		from
		[wms].OP_WMS_VIEW_RPT_ALMGEN
		WHERE QTY > 0
		group by CLIENT_NAME
		UNION
		select 
		CLIENT_NAME from
		[wms].OP_WMS_VIEW_RPT_FISCAL
		WHERE QTY > 0
		group by CLIENT_NAME
     END 
     
    IF @CLASIFICACION='BODEGA'
     BEGIN   
		SELECT
		DISTINCT SUBSTRING(CURRENT_LOCATION,1,3) AS BODEGA
		from
		[wms].OP_WMS_VIEW_RPT_ALMGEN
		WHERE QTY > 0
		group by CURRENT_LOCATION
		UNION
		select 
		 DISTINCT SUBSTRING(CURRENT_LOCATION,1,3) AS BODEGA
		from
		[wms].OP_WMS_VIEW_RPT_FISCAL
		WHERE QTY > 0
		group bY CURRENT_LOCATION
     END 
    IF @CLASIFICACION='SKU'
     BEGIN 		
		SELECT
		 BARCODE_ID
		from
		[wms].OP_WMS_VIEW_RPT_ALMGEN
		WHERE QTY > 0
		group by BARCODE_ID
		UNION
		select 
		 BARCODE_ID
		from
		[wms].OP_WMS_VIEW_RPT_FISCAL
		WHERE QTY > 0
		group by BARCODE_ID
     END 
    IF @CLASIFICACION='MATERIAL_CLASS'
     BEGIN 
		SELECT
		MATERIAL_CLASS
		from
		[wms].OP_WMS_VIEW_RPT_ALMGEN
		WHERE QTY > 0 and MATERIAL_CLASS !=''
		group by MATERIAL_CLASS
		UNION
		select 
		 MATERIAL_CLASS
		from
		[wms].OP_WMS_VIEW_RPT_FISCAL
		WHERE QTY > 0 and MATERIAL_CLASS !=''
		group by MATERIAL_CLASS
     END 
    IF @CLASIFICACION='REGIMEN'
     BEGIN 
		select 'FISCAL' AS REGIMEN 
		UNION 
		SELECT 'GENERAL' AS REGIMEN
     END 
     
END