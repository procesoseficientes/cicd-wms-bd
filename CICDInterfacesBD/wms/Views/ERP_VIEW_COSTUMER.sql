﻿
-- Modificacion 8/31/2017 @ A-Team Sprint 
					-- diego.as
					-- Se agrega columna CODE_CUSTOMER_ALTERNATE

/* Ejemplo de ejecucion
	
		SELECT * FROM [wms].ERP_VIEW_COSTUMER

*/

CREATE VIEW [wms].[ERP_VIEW_COSTUMER]
AS
SELECT
  [C].[CUSTOMER]
 ,[C].[CODE_CUSTOMER]
 ,[C].[NAME_CUSTOMER]
 ,[C].[PHONE_CUSTOMER]
 ,[C].[ADRESS_CUSTOMER]
 ,[C].[CLASSIFICATION_CUSTOMER]
 ,[C].[CONTACT_CUSTOMER]
 ,[C].[CODE_ROUTE]
 ,[C].[LAST_UPDATE_BY]
 ,[C].[LAST_UPDATE]
 ,[C].[SELLER_DEFAULT_CODE]
 ,999999 [CREDIT_LIMIT]
 ,[C].[FROM_ERP]
 ,[C].[NAME_ROUTE]
 ,[C].[NAME_CLASSIFICATION]
 ,[C].[GPS]
 ,[C].[LATITUDE]
 ,[C].[LONGITUDE]
 ,[C].[FREQUENCY]
 ,[C].[SUNDAY]
 ,[C].[MONDAY]
 ,[C].[TUESDAY]
 ,[C].[WEDNESDAY]
 ,[C].[THURSDAY]
 ,[C].[FRIDAY]
 ,[C].[SATURDAY]
 ,[C].[SCOUTING_ROUTE]
 ,[C].[EXTRA_DAYS]
 ,[C].[EXTRA_MONT]
 ,[C].[DISCOUNT]
 ,[C].[OFIVENTAS]
 ,[C].[RUTAVENTAS]
 ,[C].[RUTAENTREGA]
 ,[C].[SECUENCIA]
 ,[C].[RGA_CODE]
 ,[C].[ORGANIZACION_VENTAS]
 ,[C].[PAYMENT_CONDITIONS]
 ,[C].[OWNER]
 ,[C].[OWNER_ID]
 ,[C].[BALANCE]
 ,[C].[TAX_ID] [TAX_ID_NUMBER]
 ,[C].[INVOICE_NAME]
 ,[C].[DEPARTAMENT]
 ,[c].[MUNICIPALITY]
 ,[C].[COLONY]
 ,[C].[CODE_CUSTOMER_ALTERNATE]
FROM [wms].[SWIFT_ERP_CUSTOMERS] [C]
