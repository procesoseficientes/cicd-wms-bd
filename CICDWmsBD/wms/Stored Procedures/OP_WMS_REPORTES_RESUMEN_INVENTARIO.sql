-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_REPORTES_RESUMEN_INVENTARIO]
	-- Add the parameters for the stored procedure here
	 @CLASIFICACION VARCHAR(250),
	 @DATE VARCHAR(250),
	 @REGIMEN VARCHAR(250)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    IF @CLASIFICACION='BODEGA'
		BEGIN
			select 
			BODEGA,
			REGIMEN,
			SUM(TOTAL_VALOR)AS 'TOTAL_VALOR' from
			[wms].OP_WMS_INV_HISTORY
			where (SNAPSHOT_DATE between cast(@DATE+' 00:00AM' as datetime) AND  cast(@DATE+' 23:59PM' as datetime))
			AND REGIMEN=@REGIMEN
			AND QTY>0
			group by BODEGA,REGIMEN
		END	
      ELSE IF   @CLASIFICACION='CLIENTE'
		BEGIN
			select 
		    CLIENT_NAME,
		    regimen,
			SUM(TOTAL_VALOR)AS 'TOTAL_VALOR' from
			[wms].OP_WMS_INV_HISTORY
			where (SNAPSHOT_DATE between cast(@DATE+' 00:00AM' as datetime) AND  cast(@DATE+' 23:59PM' as datetime))
			AND REGIMEN=@REGIMEN
			AND QTY>0
			group by CLIENT_NAME,REGIMEN
			
		END
END