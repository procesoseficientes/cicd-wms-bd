-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	29-Nov-2018 @ G-Force-Team Sprint Ornitorinco
-- Historia: Product Backlog Item 25517: Demanda de despacho con estados por linea
-- Description:			Obtiene el inventario disponible para picking agrupado por material y estado

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyecto

-- Autor:				fabrizio.delcompare
-- Fecha de Creacion: 	23-Jul-2029
-- Description:			Cambio completo del query, ahora automaticamente trae disponibilidad recursiva basada en masterpack

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_GET_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL
					@XML = N'
<ArrayOfOrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>
    <SKU>arium/100112</SKU>
    <DESCRIPTION_SKU>Prueba</DESCRIPTION_SKU>
    <QTY>3000</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
    <IS_MASTER_PACK>1</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>   
    <SKU>wms/RD001</SKU>
    <DESCRIPTION_SKU>Radiadores</DESCRIPTION_SKU>
    <QTY>9500</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
	<IS_MASTER_PACK>1</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
  <OrdenDeVentaDetalle>
    <SKU>wms/C00000123</SKU>
    <DESCRIPTION_SKU>ROSAL VERDE PEQUEO 1UNX24UN  CAJA</DESCRIPTION_SKU>
    <QTY>3.00</QTY>
    <EXTERNAL_SOURCE_ID>1</EXTERNAL_SOURCE_ID>
	<IS_MASTER_PACK>0</IS_MASTER_PACK>
    <MATERIAL_OWNER>wms</MATERIAL_OWNER>
  </OrdenDeVentaDetalle>
</ArrayOfOrdenDeVentaDetalle>'
					,@CODE_WAREHOUSE = 'BODEGA_C002' 

					SELECT * FROM [wms].[OP_WMS_MATERIALS] WHERE [MATERIAL_ID] = 'wms/C00000123'

					
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] (
		@XML XML
		,@CODE_WAREHOUSE VARCHAR(50)
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE	@SKUS TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,UNIQUE NONCLUSTERED ([MATERIAL_ID])
		);
  --
	DECLARE	@INVENTORY TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(200)
			,[CLIENT_CODE] VARCHAR(50)
			,[CLIENT_NAME] VARCHAR(250)
			,[REGIMEN] VARCHAR(50)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[QTY] NUMERIC(18, 4)
			,[COMMITED_QTY] NUMERIC(18, 4)
			,[AVAILABLE_QTY] NUMERIC(18, 4)
			,[STATUS_CODE] VARCHAR(50)
			,[STATUS_NAME] VARCHAR(100)
			,[COLOR] VARCHAR(20)
		);
	DECLARE	@INVENTORY_PROJECT TABLE (
			[MATERIAL_ID] VARCHAR(50)
			,[MATERIAL_NAME] VARCHAR(200)
			,[CLIENT_CODE] VARCHAR(50)
			,[CLIENT_NAME] VARCHAR(250)
			,[REGIMEN] VARCHAR(50)
			,[CURRENT_WAREHOUSE] VARCHAR(25)
			,[QTY] NUMERIC(18, 4)
			,[COMMITED_QTY] NUMERIC(18, 4)
			,[AVAILABLE_QTY] NUMERIC(18, 4)
			,[STATUS_CODE] VARCHAR(50)
			,[STATUS_NAME] VARCHAR(100)
			,[COLOR] VARCHAR(20)
		);



  -- ------------------------------------------------------------------------------------
  -- Obtenemos todos los SKUs desde el XML.
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @SKUS
			(
				[MATERIAL_ID]
			)
	SELECT
		[X].[Rec].[query]('./SKU').[value]('.',
											'varchar(50)') [MATERIAL_ID]
	FROM
		@XML.[nodes]('/ArrayOfOrdenDeVentaDetalle/OrdenDeVentaDetalle')
		AS [X] ([Rec]);

	SELECT 
		MAX(SK.MATERIAL_ID) MATERIAL_ID,
		MAX(OWM.MATERIAL_NAME) MATERIAL_NAME,
		MAX([IP].CLIENT_CODE) CLIENT_CODE,
		MAX([IP].CLIENT_NAME) CLIENT_NAME,
		MAX([IP].REGIMEN) REGIMEN,
		@CODE_WAREHOUSE CURRENT_WAREHOUSE,
		MAX([IP].QTY) QTY,
		MAX([IP].COMMITED_QTY) COMMITED_QTY,		
		wms.OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK(SK.MATERIAL_ID, @CODE_WAREHOUSE) [AVAILABLE_QTY],
		MAX([IP].STATUS_CODE) STATUS_CODE,
		MAX([IP].STATUS_NAME) STATUS_NAME,
		MAX([IP].[COLOR]) [COLOR],
		MAX([IP].AVAILABLE_QTY)
	FROM @SKUS SK
	INNER JOIN wms.OP_WMS_MATERIALS OWM
	ON SK.MATERIAL_ID = OWM.MATERIAL_ID
	INNER JOIN wms.[OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] [IP]
	ON SK.MATERIAL_ID = [IP].MATERIAL_ID
	WHERE wms.OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK(SK.MATERIAL_ID, @CODE_WAREHOUSE) > 0
	GROUP BY
		SK.[MATERIAL_ID],
		[IP].[STATUS_CODE];
END;