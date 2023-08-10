
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-17-2016
-- Description:			obtiene una orden de compra del ERP que esté abierta 

-- Modificado Fecha
-- anonymous
-- sin motivo

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        
        DECLARE @RC int
        DECLARE @RECEPTION_HEADER varchar(50)
        
        SET @RECEPTION_HEADER = '1' 
        
        EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_POH @RECEPTION_HEADER
GO
*/
CREATE PROC [SONDA].SWIFT_SP_GET_ERP_POH @RECEPTION_HEADER VARCHAR(50)
AS

  DECLARE @DOC_NUM VARCHAR(50) = '-1';

  SELECT TOP 1
    @DOC_NUM = ERP_DOC
  FROM [SONDA].SWIFT_TXN_X_DOC_ERP stxde INNER JOIN [SONDA].SWIFT_RECEPTION_HEADER srh
    ON stxde.DOC_ENTRY = srh.DOC_SAP_RECEPTION 
  WHERE srh.RECEPTION_HEADER = @RECEPTION_HEADER

  DECLARE @SQL VARCHAR(MAX)
  SELECT
    @SQL = 'SELECT  
      po.DocNum
 ,'+@RECEPTION_HEADER+' AS DocEntry
 ,po.CardCode AS CardCode
 ,po.CardName AS CardName
 ,''N'' AS HandWritten
 ,ISNULL(t.LAST_UPDATE, GETDATE()) AS DocDate
 ,po.COMMENTS
 ,po.DocCur AS DocCur
 ,po.DocRate AS DocRate
 ,CAST(NULL AS VARCHAR) AS UFacSerie
 ,CAST(NULL AS VARCHAR) AS UFacNit
 ,CAST(NULL AS VARCHAR) AS UFacNom
 ,CAST(NULL AS VARCHAR)
  AS UFacFecha
 ,CAST(NULL AS VARCHAR) AS UTienda
 ,CAST(NULL AS VARCHAR) AS UStatusNc
 ,CAST(NULL AS VARCHAR) AS UnoExencion
 ,CAST(NULL AS VARCHAR) AS UtipoDocumento
 ,CAST(NULL AS VARCHAR) AS UUsuario
 ,CAST(NULL AS VARCHAR) AS UFacnum
 ,CAST(NULL AS VARCHAR) AS USucursal
 ,CAST(NULL AS VARCHAR) AS U_Total_Flete
 ,CAST(NULL AS VARCHAR)
  AS UTipoPago
 ,CAST(NULL AS VARCHAR) AS UCuotas
 ,CAST(NULL AS VARCHAR) AS UTotalTarjeta
 ,CAST(NULL AS VARCHAR) AS UFechap
 ,CAST(NULL AS VARCHAR) AS UTrasladoOC
FROM [SONDA].SWIFT_RECEPTION_HEADER  AS t    
    INNER JOIN
   (select * from openquery ([ERPSERVER],''SELECT  po.DocNum as DocNum,    ' + @RECEPTION_HEADER + ' AS DocEntry, po.CardCode AS CardCode, po.CardName AS CardName, ''''N'''' AS HandWritten,  po.Comments, 
                      po.DocCur AS DocCur, po.DocRate AS DocRate, CAST(NULL AS varchar) AS UFacSerie, CAST(NULL AS varchar) AS UFacNit, CAST(NULL AS varchar) AS UFacNom, CAST(NULL AS varchar) 
                      AS UFacFecha, CAST(NULL AS varchar) AS UTienda, CAST(NULL AS varchar) AS UStatusNc, CAST(NULL AS varchar) AS UNoExencion, CAST(NULL AS varchar) AS UTipoDocumento, 
                      CAST(NULL AS varchar) AS UUsuario, CAST(NULL AS varchar) AS UFacnum, CAST(NULL AS varchar) AS USucursal, CAST(NULL AS varchar) AS UTotalFlete, CAST(NULL AS varchar) 
                      AS UTipoPago, CAST(NULL AS varchar) AS UCuotas, CAST(NULL AS varchar) AS UTotalTarjeta, CAST(NULL AS varchar) AS UFechap, CAST(NULL AS varchar) AS UTrasladoOc                                            
FROM         [PRUEBA].dbo.OPOR AS po 
WHERE     (po.DocStatus = ''''O'''') AND (po.DocType = ''''I'''') AND (po.DocNum = ' + @DOC_NUM + ')  '')) as po ON po.DocEntry = t.RECEPTION_HEADER WHERE   (ISNULL(t.IS_POSTED_ERP, 0) = 0) ';

  EXEC (@SQL);
