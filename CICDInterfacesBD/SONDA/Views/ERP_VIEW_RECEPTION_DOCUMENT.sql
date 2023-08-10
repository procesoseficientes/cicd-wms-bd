

-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	 Consultar documentos de recepción de ERP 

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	        Se agrego DocCur y DocRate


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 Se agrega para que retorne a su vez DocNum de SAP

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por SAPSERVER

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-11 @ Team REBORN - Sprint Drado-Collin
-- Description:	   Se agrega NumAtCard

/*
-- Ejemplo de Ejecucion:
			select * from [wms].ERP_VIEW_RECEPTION_DOCUMENT  ORDER BY DOC_DATE
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_RECEPTION_DOCUMENT]
AS

--SELECT * FROM [ERP_SERVER].[SAE70EMPRESA01].dbo.


SELECT *
FROM OPENQUERY
     ([ERP_SERVER],
      '
SELECT LTRIM([P].[CVE_DOC]) [SAP_REFERENCE],
       ''OC'' [DOC_TYPE],
       ''Orden de Compra SAE'' [DESCRIPTION_TYPE],
       LTRIM([P].[CVE_CLPV]) [CUSTOMER_ID],
       --,NULL COD_WAREHOUSE
       [PROV].[NOMBRE] [CUSTOMER_NAME],
       --,NULL WAREHOUSE_NAME
       [P].[FECHA_DOC] [DOC_DATE],
       [P].[NUM_MONED] [DOC_CUR],
       [P].[TIPCAMB] [DOC_RATE],
       [P].[STATUS] [COMMENTS],
       LTRIM([P].[CVE_DOC]) [DocNum],
       [P].[CVE_CLPV] [MASTER_ID_PROVIDER],
       ''ALZA'' [OWNER_PROVIDER],
       ''ALZA'' [OWNER],
       0 AS [NumAtCard],
       ''1'' AS [UFacserie],
       1 AS [UFacnum],
       -1 AS [Series]
FROM [SAE70EMPRESA01].[dbo].[COMPO01] [P]
    LEFT JOIN [SAE70EMPRESA01].[dbo].[PROV01] [PROV]
        ON [PROV].[CLAVE] = [P].[CVE_CLPV]
WHERE [P].[STATUS] = ''E''
AND [P].[BLOQ] = ''N'' 
AND P.[DOC_SIG] IS NULL

'
     );



--	WHERE P.DocStatus = 'O'