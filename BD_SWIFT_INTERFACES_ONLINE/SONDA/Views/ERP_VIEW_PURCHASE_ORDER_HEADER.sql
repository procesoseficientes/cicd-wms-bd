


CREATE VIEW [SONDA].[ERP_VIEW_PURCHASE_ORDER_HEADER]
AS
    SELECT  null  Doc_Entry ,
            null  Card_Code ,
            null  Card_Name ,
            'N'  Hand_Written ,
            NULL Comments ,
            null  Doc_Cur ,
            null  Doc_Rate ,
            null U_FacSerie ,
            null U_FacNit ,
            null U_FacNom ,
            null U_FacFecha ,
            null U_Tienda ,
            null U_STATUS_NC ,
            null U_NO_EXENCION ,
            null U_TIPO_DOCUMENTO ,
            null U_usuario ,
            null U_Facnum ,
            null U_SUCURSAL ,
            null U_Total_Flete ,
            null U_Tipo_Pago ,
            null U_Cuotas ,
            null U_Total_Tarjeta ,
            null U_FECHAP ,
            null U_TrasladoOC;                                            

--    SELECT  *
--    FROM    OPENQUERY(ERP_SERVER,
--                      'SELECT     po.DocEntry AS Doc_Entry, po.CardCode AS Card_Code, po.CardName AS Card_Name, ''N'' AS Hand_Written,  po.Comments, 
--                      po.DocCur AS Doc_Cur, po.DocRate AS Doc_Rate, CAST(NULL AS varchar) AS U_FacSerie, CAST(NULL AS varchar) AS U_FacNit, CAST(NULL AS varchar) AS U_FacNom, CAST(NULL AS varchar) 
--                      AS U_FacFecha, CAST(NULL AS varchar) AS U_Tienda, CAST(NULL AS varchar) AS U_STATUS_NC, CAST(NULL AS varchar) AS U_NO_EXENCION, CAST(NULL AS varchar) AS U_TIPO_DOCUMENTO, 
--                      CAST(NULL AS varchar) AS U_usuario, CAST(NULL AS varchar) AS U_Facnum, CAST(NULL AS varchar) AS U_SUCURSAL, CAST(NULL AS varchar) AS U_Total_Flete, CAST(NULL AS varchar) 
--                      AS U_Tipo_Pago, CAST(NULL AS varchar) AS U_Cuotas, CAST(NULL AS varchar) AS U_Total_Tarjeta, CAST(NULL AS varchar) AS U_FECHAP, CAST(NULL AS varchar) AS U_TrasladoOC                                            
--FROM         [Prueba].dbo.OPOR AS po 
--WHERE     (po.DocStatus = ''O'') AND (po.DocType = ''I'')  ');

