
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_WAREHOUSE]
*/
-- =============================================

CREATE VIEW [SONDA].[ERP_VIEW_WAREHOUSE]
AS

	SELECT 
		 CODE_WAREHOUSE 
		,[DESCRIPTION]
		,[WEATHER_WAREHOUSE]
		,[STATUS_WAREHOUSE]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[IS_EXTERNAL]
	FROM OPENQUERY ([ERP_SERVER],'
		SELECT  
			[CVE_ALM]  AS [CODE_WAREHOUSE]  
		   ,[DESCR]  AS [DESCRIPTION]  
		   ,43      AS [WEATHER_WAREHOUSE]
		   ,''ACTIVA''   AS [STATUS_WAREHOUSE]
		   ,GETDATE()  AS [LAST_UPDATE]  
		   ,''BULKDATA'' AS [LAST_UPDATE_BY]
		   ,NULL	   AS [IS_EXTERNAL]	
		FROM [SAE70EMPRESA01].[dbo].[ALMACENES01] 
	')


