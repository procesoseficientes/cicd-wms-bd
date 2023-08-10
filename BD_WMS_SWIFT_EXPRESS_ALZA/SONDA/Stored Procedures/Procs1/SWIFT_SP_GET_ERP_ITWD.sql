-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			obtiene el detalle de una orde de compra en sap de la cual se hizo un picking 

-- Modificado Fecha
		-- anonymous
		-- ningun motivo

/*
-- Ejemplo de Ejecucion:
          USE SWIFT_EXPRESS
          GO
          
          DECLARE @RC int
          DECLARE @PICKING_HEADER varchar(50)
          
          SET @PICKING_HEADER = '' 
          
          EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_ITWD @PICKING_HEADER
          GO
*/

CREATE  PROC [SONDA].SWIFT_SP_GET_ERP_ITWD 
@PICKING_HEADER VARCHAR(50)
AS

DECLARE @SQL VARCHAR(MAX);
DECLARE @DOC_SAP_RECEPTION VARCHAR(50)='-1';
DECLARE @OQUERY VARCHAR(MAX);
DECLARE @NREG INT=0;
DECLARE @CONT INT=0;
DECLARE @ITEM_ID VARCHAR(MAX);
DECLARE @QTY INT;
DECLARE @DISPATCH INT;
DECLARE @LINE_NUM INT; 


SELECT
  @DOC_SAP_RECEPTION = ISNULL(DOC_SAP_RECEPTION,'-1')
FROM SWIFT_PICKING_HEADER sph
WHERE sph.PICKING_HEADER = @PICKING_HEADER;

SELECT
  spd.PICKING_DETAIL
 ,spd.PICKING_HEADER
 ,spd.CODE_SKU
 ,spd.DESCRIPTION_SKU
 ,spd.Dispatch
 ,spd.SCANNED
 ,spd.RESULT
 ,spd.COMMENTS
 ,spd.LAST_UPDATE
 ,spd.LAST_UPDATE_BY
 ,spd.DIFFERENCE INTO #TMP_PICKING_DET
FROM  [SONDA].SWIFT_PICKING_DETAIL spd
WHERE spd.PICKING_HEADER = @PICKING_HEADER;



CREATE TABLE #TMP_ERP_SOD (
  ID INT IDENTITY
 ,DocEntryErp INT 
 ,DoEntry INT
 ,LineNum INT
 ,ItemCode VARCHAR(30)
 ,OpenQty INT
 ,ObjType INT
 ,Dispatch INT
);


SELECT
  @OQUERY = 'INSERT INTO #TMP_ERP_SOD  SELECT r.DocEntry DocEntryErp  ,'+ @PICKING_HEADER+ '  DocEntry, r.LineNum, r.ItemCode,r.OpenQty, r.ObjType,0 Dispatch FROM (SELECT * FROM OPENQUERY([ERPSERVER],''
SELECT   r.LineNum , r.ObjType,r.ItemCode,r.DocEntry, r.OpenQty FROM PRUEBA.DBO.WTQ1 r  INNER JOIN PRUEBA.dbo.OWTQ o
  ON r.DocEntry=o.DocEntry
  WHERE o.DocNum =' + @DOC_SAP_RECEPTION + ''')) AS r';




EXECUTE (@OQUERY);

DECLARE @ID INT; 

SET @NREG = (SELECT
    COUNT(*)
  FROM #TMP_ERP_SOD);

WHILE @CONT <> @NREG
BEGIN
  SET @ID=  @CONT+1;
  SELECT 
    @ITEM_ID = tes.ItemCode
   ,@QTY = tes.OpenQty    
  FROM #TMP_ERP_SOD tes
  WHERE tes.ID = @ID;

  
  SET @DISPATCH = NULL; 
  SELECT
    @DISPATCH = tpd.DISPATCH
  FROM #TMP_PICKING_DET tpd
  WHERE tpd.CODE_SKU = @ITEM_ID;
  

  IF (@DISPATCH IS NOT NULL)
  BEGIN
    IF (@QTY >= @DISPATCH)
    BEGIN      
      UPDATE #TMP_PICKING_DET
      SET DISPATCH = 0
      WHERE CODE_SKU = @ITEM_ID;

      UPDATE #TMP_ERP_SOD
      SET Dispatch = @DISPATCH
      WHERE ID = @ID;

      
    END
    ELSE
    BEGIN

      UPDATE #TMP_PICKING_DET
      SET DISPATCH = DISPATCH - @QTY
      WHERE CODE_SKU = @ITEM_ID;

      UPDATE #TMP_ERP_SOD
      SET Dispatch = @QTY
      WHERE ID = @ID;
    END
  END



  SET @CONT = @CONT + 1;
END


SELECT
  tes.DocEntryErp
  ,tes.DoEntry
  , tes.Dispatch  Quantity 
  , tes.ItemCode 
  , tes.ObjType 
  , tes.LineNum 
FROM #TMP_ERP_SOD tes 
WHERE tes.Dispatch >0;
