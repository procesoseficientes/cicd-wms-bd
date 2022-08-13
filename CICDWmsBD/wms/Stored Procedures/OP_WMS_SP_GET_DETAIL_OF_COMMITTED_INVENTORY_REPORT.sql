-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	1/9/2018 @ A-TEAM Sprint   
-- Description:			SP que obtiene los detalles de las demandas de despacho de entrega no inmediata para el reporte de inventario comprometido


-- Modificacion 4/18/2018 @ GForce-Team Sprint Búho
					-- rodrigo.gomez
					-- Se agregan campos necesarios para el inventario preparado

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_DETAIL_OF_COMMITTED_INVENTORY_REPORT]
			@DEMAND_HEADER_XML = N'<?xml version="1.0" encoding="utf-16"?>
<ArrayOfInventarioComprometidoEncabezado xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <InventarioComprometidoEncabezado>
    <DOC_NUM>71</DOC_NUM>
    <DELIVERY_DATE>2017-08-31T00:00:00</DELIVERY_DATE>
    <CLIENT_CODE>wms_ALMACENADORA</CLIENT_CODE>
    <CLIENT_NAME>Almacenes y Servicios, S.A.  -wms-</CLIENT_NAME>
    <IS_FROM_SONDA>NO</IS_FROM_SONDA>
    <IS_FROM_ERP>NO</IS_FROM_ERP>
    <WAVE_PICKING_ID>4829</WAVE_PICKING_ID>
    <ERP_DOCUMENT>N/A</ERP_DOCUMENT>
    <STATUS>Finalizado</STATUS>
    <IS_SELECTED>false</IS_SELECTED>
  </InventarioComprometidoEncabezado>
  <InventarioComprometidoEncabezado>
    <DOC_NUM>55</DOC_NUM>
    <DELIVERY_DATE>2017-08-31T00:00:00</DELIVERY_DATE>
    <CLIENT_CODE>wms_ALMACENADORA</CLIENT_CODE>
    <CLIENT_NAME>Almacenes y Servicios, S.A.  -wms-</CLIENT_NAME>
    <IS_FROM_SONDA>NO</IS_FROM_SONDA>
    <IS_FROM_ERP>NO</IS_FROM_ERP>
    <WAVE_PICKING_ID>4833</WAVE_PICKING_ID>
    <ERP_DOCUMENT>N/A</ERP_DOCUMENT>
    <STATUS>En Espera</STATUS>
    <IS_SELECTED>false</IS_SELECTED>
  </InventarioComprometidoEncabezado>
  <InventarioComprometidoEncabezado>
    <DOC_NUM>42</DOC_NUM>
    <DELIVERY_DATE>2017-08-25T00:00:00</DELIVERY_DATE>
    <CLIENT_CODE>wms_ALMACENADORA</CLIENT_CODE>
    <CLIENT_NAME>Almacenes y Servicios, S.A.  -wms-</CLIENT_NAME>
    <IS_FROM_SONDA>NO</IS_FROM_SONDA>
    <IS_FROM_ERP>NO</IS_FROM_ERP>
    <WAVE_PICKING_ID>4834</WAVE_PICKING_ID>
    <ERP_DOCUMENT>N/A</ERP_DOCUMENT>
    <STATUS>En Espera</STATUS>
    <IS_SELECTED>false</IS_SELECTED>
  </InventarioComprometidoEncabezado>
  <InventarioComprometidoEncabezado>
    <DOC_NUM>10</DOC_NUM>
    <DELIVERY_DATE>2017-08-24T00:00:00</DELIVERY_DATE>
    <CLIENT_CODE>wms_ALMACENADORA</CLIENT_CODE>
    <CLIENT_NAME>Almacenes y Servicios, S.A.  -wms-</CLIENT_NAME>
    <IS_FROM_SONDA>NO</IS_FROM_SONDA>
    <IS_FROM_ERP>NO</IS_FROM_ERP>
    <WAVE_PICKING_ID>4835</WAVE_PICKING_ID>
    <ERP_DOCUMENT>N/A</ERP_DOCUMENT>
    <STATUS>En Espera</STATUS>
    <IS_SELECTED>false</IS_SELECTED>
  </InventarioComprometidoEncabezado>
  <InventarioComprometidoEncabezado>
    <DOC_NUM>53</DOC_NUM>
    <DELIVERY_DATE>2017-08-30T00:00:00</DELIVERY_DATE>
    <CLIENT_CODE>wms_ALMACENADORA</CLIENT_CODE>
    <CLIENT_NAME>Almacenes y Servicios, S.A.  -wms-</CLIENT_NAME>
    <IS_FROM_SONDA>NO</IS_FROM_SONDA>
    <IS_FROM_ERP>NO</IS_FROM_ERP>
    <WAVE_PICKING_ID>4836</WAVE_PICKING_ID>
    <ERP_DOCUMENT>N/A</ERP_DOCUMENT>
    <STATUS>En Espera</STATUS>
    <IS_SELECTED>false</IS_SELECTED>
  </InventarioComprometidoEncabezado>
</ArrayOfInventarioComprometidoEncabezado>
			'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DETAIL_OF_COMMITTED_INVENTORY_REPORT]
    (
     @DEMAND_HEADER_XML XML
    )
AS
BEGIN
	--
    SET NOCOUNT ON;
	
	--
    DECLARE @DEMAND_HEADER TABLE
        (
         [WAVE_PICKING_ID] INT
        );

	--
    INSERT  INTO @DEMAND_HEADER
            (
             [WAVE_PICKING_ID]
            )
    SELECT
        [x].[Rec].[query]('./WAVE_PICKING_ID').[value]('.', 'int')
    FROM
        @DEMAND_HEADER_XML.[nodes]('./ArrayOfInventarioComprometidoEncabezado/InventarioComprometidoEncabezado')
        AS [x] ([Rec]);
	--
    SELECT
        [L].[LICENSE_ID]
       ,[L].[CURRENT_LOCATION]
       ,[IL].[MATERIAL_ID]
       ,[IL].[QTY]
       ,[DH].[WAVE_PICKING_ID]
    INTO
        #LICENSE_TARGET
    FROM
        @DEMAND_HEADER [DH]
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
    INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    WHERE
        [IL].[QTY] > 0;

	--
    SELECT DISTINCT
        [DD].[MATERIAL_ID]
       ,[M].[MATERIAL_NAME]
       ,(CASE [M].[IS_MASTER_PACK]
           WHEN 1 THEN 'Si'
           ELSE 'No'
         END) AS [IS_MASTER_PACK]
       ,ISNULL([LT].[QTY], [DD].[QTY]) [QTY]
       ,[DH].[WAVE_PICKING_ID]
       ,[TL].[LICENSE_ID_SOURCE]
       ,[TL].[LOCATION_SPOT_SOURCE]
       ,[LT].[LICENSE_ID] [LICENSE_ID_TARGET]
       ,ISNULL([LT].[CURRENT_LOCATION],[TL].[LOCATION_SPOT_TARGET]) [LOCATION_SPOT_TARGET]
	   ,[DH].[PICKING_DEMAND_HEADER_ID]
    FROM
        @DEMAND_HEADER [DHX]
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[WAVE_PICKING_ID] = [DHX].[WAVE_PICKING_ID]
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [DD].[MATERIAL_ID]
    INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
                                                    AND [TL].[MATERIAL_ID] = [DD].[MATERIAL_ID]
    LEFT JOIN [#LICENSE_TARGET] [LT] ON [LT].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
                                         AND [LT].[MATERIAL_ID] = [DD].[MATERIAL_ID];
END;