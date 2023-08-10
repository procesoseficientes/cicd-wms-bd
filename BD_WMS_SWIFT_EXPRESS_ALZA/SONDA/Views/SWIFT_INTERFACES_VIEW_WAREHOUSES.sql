

/****** Object:  StoredProcedure [SONDA].[SWIFT_INTERFACES_VIEW_WAREHOUSES]   Script Date: 14/01/2016 9:09:38 AM ******/
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	14-01-2016
-- Description:			Vista que llama las bodegas de intefaces

/*
-- Ejemplo de Ejecucion:				
				--
				 SELECT * FROM [SONDA].[SWIFT_INTERFACES_VIEW_WAREHOUSES]
				--				
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_INTERFACES_VIEW_WAREHOUSES]
AS
/****** Script for SelectTopNRows command from SSMS  ******/
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
  FROM [SONDA].[SWIFT_WAREHOUSES]
