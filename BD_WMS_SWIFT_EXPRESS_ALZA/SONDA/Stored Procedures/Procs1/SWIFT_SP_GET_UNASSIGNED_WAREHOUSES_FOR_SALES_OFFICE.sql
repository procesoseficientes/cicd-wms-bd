-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/4/2017 @ A-TEAM Sprint Garai 
-- Description:			Obtiene todas las bodegas no asignadas a ninguna Oficina de Ventas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_UNASSIGNED_WAREHOUSES_FOR_SALES_OFFICE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_UNASSIGNED_WAREHOUSES_FOR_SALES_OFFICE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [WAREHOUSE]
			,[CODE_WAREHOUSE]
			,[DESCRIPTION_WAREHOUSE]
			,[WEATHER_WAREHOUSE]
			,[STATUS_WAREHOUSE]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[IS_EXTERNAL]
			,[BARCODE_WAREHOUSE]
			,[SHORT_DESCRIPTION_WAREHOUSE]
			,[TYPE_WAREHOUSE]
			,[ERP_WAREHOUSE]
			,[ADDRESS_WAREHOUSE]
			,[GPS_WAREHOUSE]
			,[CODE_WAREHOUSE_3PL]
			,[SALES_OFFICE_ID] 
	FROM [SONDA].[SWIFT_WAREHOUSES]
	WHERE [SALES_OFFICE_ID] IS NULL

END
