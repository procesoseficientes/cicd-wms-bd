
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2016-08-16
-- Description:			    Vista que obtiene los vendedores 

-- MODIFICADO 18-08-2016
--		diego.as
--		Se agregaron los campos SELLER_TYPE, SELLER_TYPE_DESCRIPTION, CODE_ROUTE, NAME_ROUTE, CODE_WAREHOUSE, NAME_WAREHOUSE a la vista

-- Modificacion 25-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega la columna de GPS

-- Modificacion 08-Jun-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agrega campo de source

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_SELLER]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SELLER]
AS

	SELECT
			SELLER_CODE AS SELLER_CODE 
		,SELLER_NAME   AS SELLER_NAME
		,EMAIL
		,CAST('SONDA' AS VARCHAR(10)) [OWNER]
		,SELLER_CODE [OWNER_ID]
		,CAST('0,0' AS VARCHAR(50)) [GPS]
		,CAST('SONDA' AS VARCHAR(50))[SOURCE]
	FROM 
		(SELECT DISTINCT
			RTRIM(LTRIM(BO.[CVE_VEND])) AS SELLER_CODE 
			,BO.[NOMBRE] COLLATE DATABASE_DEFAULT AS SELLER_NAME
			,BO.[CORREOE] AS EMAIL
		FROM [SAE70EMPRESA01].[dbo].[VEND01] AS BO
		WHERE BO.[STATUS] = 'A'
	) AS ID
