﻿



CREATE VIEW [SONDA].[ERP_PRICE_LIST_BY_CUSTOMER]
AS 

	SELECT * FROM OPENQUERY (ERP_SERVER,'
		SELECT DISTINCT
			 ISNULL(CAST([LISTA_PREC] AS varchar),''2'') as CODE_PRICE_LIST
			 ,RTRIM(LTRIM([CLAVE])) COLLATE database_default as CODE_CUSTOMER  
			 ,CAST(''SONDA'' AS VARCHAR(50)) [OWNER]
		from [SAE70EMPRESA01].[dbo].[CLIE01]
		WHERE CAST([CVE_VEND] AS VARCHAR)<>''''
		
	')





