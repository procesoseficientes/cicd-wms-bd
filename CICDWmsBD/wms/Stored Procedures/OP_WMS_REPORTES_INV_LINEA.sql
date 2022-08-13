-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_REPORTES_INV_LINEA] 
	-- Add the parameters for the stored procedure here
	@CLIENT_NAME VARCHAR(150)= NULL
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT 
			CLIENT_NAME 'Nombre Cliente',
			NUMERO_ORDEN  'No. Orden',
			NUMERO_DUA  'DUA',
			   (CASE WHEN FECHA_LLEGADA !='0'
			THEN
			convert(datetime,FECHA_LLEGADA,103)
			ELSE 
			NULL
			 END ) AS  'Fecha Llegada',
			LICENSE_ID 'Licencia',
			TERMS_OF_TRADE 'Acuerdo Comercial',
			MATERIAL_ID 'Cod. Material',
			MATERIAL_CLASS 'Clase Material',
			BARCODE_ID  'Codigo Barra',
			--ALTERNATE_BARCODE,
			MATERIAL_NAME 'Descripcion',
			QTY 'Inv. Disp',
			--CLIENT_OWNER,
			REGIMEN 'Regimen',
			CODIGO_POLIZA 'Poliza',
			CURRENT_LOCATION 'Ubicacion',
			VOLUME_FACTOR 'Factor Volumen',
			--VOLUMEN,
			--TOTAL_VOLUMEN,
			LAST_UPDATED_BY,
			SERIAL_NUMBER 'Serial/Chasis'
		FROM [wms].OP_WMS_VIEW_INVENTORY_DETAIL where QTY>0 
		AND CLIENT_NAME= ISNULL(@CLIENT_NAME,CLIENT_NAME)
		
END