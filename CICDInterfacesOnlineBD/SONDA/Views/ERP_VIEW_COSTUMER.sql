-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	11-09-2015
-- Description:			Vista que obtiene los clientes de sap

-- Modificacion 11-09-2015
-- joel.delcompare
-- se cambio el SELLER_DEFAULT_CODE por el codigo del vendedor  dado que estaba usando el nombre 

-- Modificacion 23-01-2016
-- alberto.ruiz
-- Se agregaron los campos de latitud, longitud, frecuancia y dias de visita
--,/*c.CreditLine*/99999 AS CREDIT_LIMIT     sustituir para regresar la vista a su estado normal

-- Modificacion 06-04-2016
-- hector.gonzalez
-- Se agrego el campo "Discount" de la tabla "OCRD" con el alias de "DISCOUNT".

-- Modificado 2016-05-02
	-- joel.delcompare
	-- Se agregaron los campos U_RTOfiVentas, U_RTRutaVentas, U_RTRutaEntrega, U_RTSecuencia 

-- Modificacion 01-08-2016  
		-- alberto.ruiz
		-- Se agrego isnull al nombre del cliente

  -- Modificacion 27-11-2016  
		-- hector.gonzalez
		-- Se agrego la columna itemCode

-- Modificacion 28-Feb-17 @ A-Team Sprint Donkor
		-- alberto.ruiz
		-- Se agregaron los campos de organizacion de ventas y payment_conditions

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
		-- diego.as
		-- Se agrega columna VatIdUnCmp con el alias CODE_CUSTOMER_ALTERNATE

/*
-- Ejemplo de Ejecucion:
	--
	SELECT distinct CREDIT_LIMIT FROM [SONDA].[ERP_VIEW_COSTUMER] WHERE CODE_CUSTOMER = '2324'
*/
--================U_RTRutaVentas ===============
CREATE VIEW [SONDA].[ERP_VIEW_COSTUMER]
AS
	
	SELECT
	  *
	FROM OPENQUERY(ERP_SERVER, '
	  SELECT 
		CAST(RTRIM(LTRIM(c.[CLAVE])) as VARCHAR) COLLATE DATABASE_DEFAULT AS CUSTOMER
		,CAST(RTRIM(LTRIM(c.[CLAVE])) as VARCHAR(50)) COLLATE DATABASE_DEFAULT AS CODE_CUSTOMER
		,CAST(ISNULL(REPLACE(c.[NOMBRE],''|'','' ''),''NA'') AS VARCHAR(255)) COLLATE DATABASE_DEFAULT AS NAME_CUSTOMER
		,CAST(c.[TELEFONO] as VARCHAR(20)) COLLATE DATABASE_DEFAULT AS PHONE_CUSTOMER
		,CAST(c.[CALLE] as VARCHAR) COLLATE DATABASE_DEFAULT AS ADRESS_CUSTOMER
		, ''7'' AS CLASSIFICATION_CUSTOMER
		,CAST(c.[NOMBRE] as VARCHAR) COLLATE DATABASE_DEFAULT AS CONTACT_CUSTOMER
		,cast(NULL as varchar) AS CODE_ROUTE
		,GETDATE() AS LAST_UPDATE
		,CAST(''BULK_DATA'' AS VARCHAR) AS LAST_UPDATE_BY
		,cast(RTRIM(LTRIM([CVE_VEND])) as varchar) COLLATE DATABASE_DEFAULT AS SELLER_DEFAULT_CODE
		,[LIMCRED] AS CREDIT_LIMIT
		, 1 AS FROM_ERP 
		,CAST(null as varchar) NAME_ROUTE
		,CAST(null as varchar) NAME_CLASSIFICATION
		,ISNULL(CAST([LAT_GENERAL] as varchar),''0'') LATITUDE
		,ISNULL(CAST([LON_GENERAL]as varchar),''0'') LONGITUDE
		,0 FREQUENCY
		,0 SUNDAY
		,0 MONDAY
		,0 TUESDAY
		,0 WEDNESDAY
		,0 THURSDAY
		,0 FRIDAY
		,0 SATURDAY
		,0 SCOUTING_ROUTE
		,''1'' AS GROUP_NUM
		,c.[DIASCRED] AS EXTRA_DAYS
		,''0'' AS EXTRA_MONT
		,''0'' AS DISCOUNT
		,CAST('''' AS VARCHAR(50)) AS OFICINA_VENTAS
		,CAST('''' AS VARCHAR(50)) AS RUTA_VENTAS
		,CAST('''' AS VARCHAR(50)) AS RUTA_ENTREGA
		,CAST('''' AS VARCHAR(50)) AS SECUENCIA
		,RTRIM(LTRIM(c.[CLAVE])) AS RGA_CODE 
		,''1'' AS [PAYMENT_CONDITIONS]
		,CAST(NULL AS VARCHAR(250)) AS [ORGANIZACION_VENTAS]	
		,CAST(''SONDA'' AS VARCHAR) AS OWNER
		,RTRIM(LTRIM(c.[CLAVE])) COLLATE DATABASE_DEFAULT AS OWNER_ID
		,c.[SALDO] Balance
		,c.[RFC] TAX_ID
		,c.[NOMBRE] INVOICE_NAME
		,NULL CODE_CUSTOMER_ALTERNATE
	  FROM [SAE70EMPRESA01].[dbo].[CLIE01] AS c 
	  WHERE ISNULL(RTRIM(LTRIM([CVE_VEND])),'''')<>''''
	  AND [c].[CLAVE]<>''1207''
	')









