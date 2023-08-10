



-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	15-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_COMMITED_BY_WAREHOUSE]
*/
-- =============================================

CREATE VIEW [SONDA].[ERP_VIEW_COMMITED_BY_WAREHOUSE]
AS 
SELECT  
	NULL CODE_SKU
   ,NULL CODE_WAREHOUSE 
   ,NULL IS_COMMITED 

--SELECT * FROM OPENQUERY (ERP_SERVER,'SELECT  
--	[ItemCode] COLLATE database_default as CODE_SKU
--   ,[WhsCode] COLLATE database_default as CODE_WAREHOUSE 
--   ,[IsCommited] as IS_COMMITED 
--FROM [Prueba].[dbo].[OITW] ')

