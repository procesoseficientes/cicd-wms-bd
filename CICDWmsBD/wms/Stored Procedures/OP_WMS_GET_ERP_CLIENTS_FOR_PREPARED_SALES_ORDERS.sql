﻿-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	4/13/2018 @ G-FORCE Sprint Buho 
-- Description:			Obtiene los clientes de ORDENES DE VENTA PREPARADAS DE ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_ERP_CLIENTS_FOR_PREPARED_SALES_ORDERS]
				 @START_DATE='2017-09-01 00:00:00',@END_DATE='2017-09-01 23:59:59',@WAREHOUSE_CODE=N'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ERP_CLIENTS_FOR_PREPARED_SALES_ORDERS]
	(
		@START_DATE DATETIME
		,@END_DATE DATETIME
		,@WAREHOUSE_CODE VARCHAR(50)
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		SELECT
			[DH].[CLIENT_CODE] [CLIENT_ID]
			,[DH].[CLIENT_CODE] [MASTER_ID]
			,[DH].[CLIENT_NAME]
			,[DH].[EXTERNAL_SOURCE_ID]
			,[DH].[OWNER]
			,[DH].[ADDRESS_CUSTOMER]
			,[DH].[STATE_CODE]
			,MAX([DH].[DEMAND_DELIVERY_DATE]) [DELIVERY_DATE]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS [DH]
		WHERE
			[DH].[DEMAND_DELIVERY_DATE] BETWEEN @START_DATE
										AND		@END_DATE
			AND [DH].[CODE_WAREHOUSE] = @WAREHOUSE_CODE
			AND [DH].[IS_FOR_DELIVERY_IMMEDIATE] = 0
			AND	[DH].[SOURCE_TYPE] = 'SO - ERP'
		GROUP BY
			[DH].[CLIENT_CODE]
			,[DH].[CLIENT_CODE]
			,[DH].[CLIENT_NAME]
			,[DH].[EXTERNAL_SOURCE_ID]
			,[DH].[OWNER]
			,[DH].[ADDRESS_CUSTOMER]
			,[DH].[STATE_CODE];
	END;