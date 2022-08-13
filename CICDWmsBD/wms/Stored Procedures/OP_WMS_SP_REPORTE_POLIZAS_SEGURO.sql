-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REPORTE_POLIZAS_SEGURO]
	-- Add the parameters for the stored procedure here	
	@pResult varchar(250) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRY           
    DECLARE @AmountTotal MONEY
	DECLARE @TotalInventory MONEY	
        
	SET @AmountTotal  = (SELECT SUM(AMOUNT) FROM [wms].OP_WMS_INSURANCE_DOCS)
    SET @TotalInventory = (SELECT SUM(TOTAL_INVENTORY) FROM [wms].OP_WMS_INVENTORY iv	INNER JOIN [wms].OP_WMS_INSURANCE_DOCS ds on iv.CLIENT_CODE = ds.CLIENT_CODE)
    
    SELECT POLIZA_INSURANCE AS NumPoliza
			, VALIN_TO AS FechaVencimiento
			, d.CLIENT_CODE AS CodigoCliente
			, CLIENT_NAME AS NombreCliente
			, AMOUNT AS MontoAsegurado
			, ISNULL(TOTAL_INVENTORY, 0) AS MontoInventario	
			, ((AMOUNT - NULLIF(TOTAL_INVENTORY, 0)) * 100) / AMOUNT AS Porcentaje
			, ((@AmountTotal -@TotalInventory) *100) / @AmountTotal AS TotalPorcentaje
			FROM [wms].OP_WMS_INSURANCE_DOCS d
				INNER JOIN [wms].OP_WMS_VIEW_CLIENTS c ON d.CLIENT_CODE = c.CLIENT_CODE COLLATE DATABASE_DEFAULT
				INNER JOIN [wms].OP_WMS_INVENTORY i ON d.CLIENT_CODE = i.CLIENT_CODE
				ORDER BY VALIN_TO
    
    SELECT @PRESULT = 'OK';
    END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SELECT @PRESULT = ERROR_MESSAGE();
	END CATCH	
END