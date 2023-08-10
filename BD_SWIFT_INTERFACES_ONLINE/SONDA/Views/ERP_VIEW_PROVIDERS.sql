



CREATE VIEW [SONDA].[ERP_VIEW_PROVIDERS]
AS
    SELECT  null PROVIDER ,
            null CODE_PROVIDER ,
            null NAME_PROVIDER ,
            NULL CLASSIFICATION_PROVIDER ,
            null CONTACT_PROVIDER ,
            null FROM_ERP ,
            null NAME_CLASSIFICATION; 
--    SELECT  *
--    FROM    OPENQUERY(ERP_SERVER,
--                      'SELECT     CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS PROVIDER, CardCode COLLATE SQL_Latin1_General_CP1_CI_AS AS CODE_PROVIDER, 
--                      CardName COLLATE SQL_Latin1_General_CP1_CI_AS AS NAME_PROVIDER, cast(NULL as varchar) AS CLASSIFICATION_PROVIDER, CntctPrsn COLLATE SQL_Latin1_General_CP1_CI_AS AS CONTACT_PROVIDER, 
--                      1 AS FROM_ERP,CAST(null as varchar)  NAME_CLASSIFICATION 
--FROM         [Prueba].dbo.OCRD AS c
--WHERE     (CardType = ''S'')');

