
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-17-2016
-- Description:			obtiene el detalle de una orde de compra en sap de la cual se hizo una recepcion 

-- Modificado Fecha
-- anonymous
-- ningun motivo

/*
-- Ejemplo de Ejecucion:
          USE SWIFT_EXPRESS
          GO
          
          DECLARE @RC int
          DECLARE @RECEPTION_HEADER varchar(50)
          
          SET @RECEPTION_HEADER = '1' 
          
          EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_POD @RECEPTION_HEADER
          GO
*/

CREATE PROC [SONDA].SWIFT_SP_GET_ERP_POD @RECEPTION_HEADER VARCHAR(50)
AS

  DECLARE @SQL VARCHAR(MAX);
  DECLARE @DOC_SAP_RECEPTION VARCHAR(50) = '-1';
  DECLARE @OQUERY VARCHAR(MAX);
  DECLARE @NREG INT = 0;
  DECLARE @CONT INT = 0;
  DECLARE @ITEM_ID VARCHAR(MAX);
  DECLARE @QTY INT;
  DECLARE @ALLOCATED INT;
  DECLARE @LINE_NUM INT;



  DECLARE @DocNums VARCHAR(MAX);
  DECLARE @DefaultWarehouse VARCHAR(50);


  SELECT
    @DocNums = COALESCE(@DocNums + ', ', '') + CAST(stxde.ERP_DOC AS VARCHAR(50))   
  FROM [SONDA].SWIFT_TXN_X_DOC_ERP stxde
  INNER JOIN [SONDA].SWIFT_RECEPTION_HEADER srh
    ON srh.DOC_SAP_RECEPTION = stxde.DOC_ENTRY
  WHERE srh.RECEPTION_HEADER = @RECEPTION_HEADER
 
  
  
  SELECT
    srd.RECEPTION_DETAIL
   ,srd.RECEPTION_HEADER
   ,srd.CODE_SKU
   ,srd.DESCRIPTION_SKU
   ,srd.ALLOCATED
   ,srd.SCANNED
   ,srd.RESULT
   ,srd.COMMENTS
   ,srd.LAST_UPDATE
   ,srd.LAST_UPDATE_BY
   ,srd.DIFFERENCE INTO #TMP_RECEPTION_DET
  FROM [SONDA].SWIFT_RECEPTION_DETAIL srd
  INNER JOIN [SONDA].SWIFT_TASKS st
    ON st.RECEPTION_NUMBER = srd.RECEPTION_HEADER
  WHERE srd.RECEPTION_HEADER = @RECEPTION_HEADER;



  CREATE TABLE #TMP_ERP_POD (
    ID INT IDENTITY
   ,DocNum INT
   ,DocEntryErp INT
   ,DoEntry INT
   ,LineNum INT
   ,ItemCode VARCHAR(30)
   ,OpenQty INT
   ,ObjType INT
   ,Expected DECIMAL
   ,WarehouseCode NVARCHAR(50)
  );


  CREATE TABLE #TMP_SWIFT_POD (
    ID INT IDENTITY
   ,DocNum INT
   ,DocEntryErp INT
   ,DoEntry INT
   ,LineNum INT
   ,ItemCode VARCHAR(30)
   ,OpenQty INT
   ,ObjType INT
   ,Expected DECIMAL
   ,WarehouseCode VARCHAR(50)
  );

  -- ------------------------------------------------------------------------------------
  -- Obtiene el detalle de todas las ordenes de compra de sap 
  -- ------------------------------------------------------------------------------------
  SELECT
    @OQUERY = 'INSERT INTO #TMP_ERP_POD  SELECT r.DocNum ,r.DocEntry DocEntryErp , ' + @RECEPTION_HEADER + '  DocEntry, r.LineNum, r.ItemCode,r.OpenQty, r.ObjType,0 Expected, r.WarehouseCode FROM (SELECT * FROM OPENQUERY([ERPSERVER],''
SELECT o.DocNum , r.LineNum , r.ObjType,r.ItemCode,r.DocEntry, r.OpenQty, r.WhsCode WarehouseCode FROM PRUEBA.DBO.POR1 r  INNER JOIN PRUEBA.dbo.OPOR o
  ON r.DocEntry=o.DocEntry
  WHERE o.DocNum in (' + @DocNums + ')'')) AS r';


  EXEC  (@OQUERY);

  

  

  

  

  -- ------------------------------------------------------------------------------------
  -- Filtra las lineas de los documentos de sap que se agregaron en la recepcion
  -- ------------------------------------------------------------------------------------
  INSERT INTO #TMP_SWIFT_POD
    SELECT
      tep.DocNum
     ,tep.DocEntryErp
     ,tep.DoEntry
     ,tep.LineNum
     ,tep.ItemCode
     ,tep.OpenQty
     ,tep.ObjType
     ,tep.Expected
     ,tep.WarehouseCode
    FROM #TMP_ERP_POD tep
    INNER JOIN [SONDA].SWIFT_TXN_X_DOC_ERP stxde
      ON stxde.ERP_DOC = tep.DocNum
      AND stxde.LINE_NUM = tep.LineNum


  
  -- ------------------------------------------------------------------------------------
  -- Obtiene el contador de las lineas que se agregaron en la recepcion de sap
  -- ------------------------------------------------------------------------------------
  SET @NREG = (SELECT
      COUNT(*)
    FROM #TMP_ERP_POD);
  
  

DECLARE @ID INT = 0;   

  WHILE @CONT <> @NREG
  BEGIN
    SET @ID = @CONT+1;
    SELECT
      @ITEM_ID = tes.ItemCode
     ,@QTY = tes.OpenQty
     ,@DefaultWarehouse = tes.WarehouseCode
    FROM #TMP_SWIFT_POD tes
    WHERE tes.ID = @ID;

     
    

    SET @ALLOCATED = NULL;
    SELECT
      @ALLOCATED = tpd.ALLOCATED
    FROM #TMP_RECEPTION_DET tpd
    WHERE tpd.CODE_SKU = @ITEM_ID;


    IF (@ALLOCATED IS NOT NULL)
    BEGIN
      IF (@QTY >= @ALLOCATED)
      BEGIN
        UPDATE #TMP_RECEPTION_DET
        SET ALLOCATED = 0
        WHERE CODE_SKU = @ITEM_ID;

        UPDATE #TMP_SWIFT_POD
        SET Expected = @ALLOCATED
        WHERE ID = @ID;


      END
      ELSE
      BEGIN

        UPDATE #TMP_RECEPTION_DET
        SET ALLOCATED = ALLOCATED - @QTY
        WHERE CODE_SKU = @ITEM_ID;

        UPDATE #TMP_SWIFT_POD
        SET Expected = @QTY
        WHERE ID = @ID;
      END
    END



    SET @CONT = @CONT + 1;
  END


  

  -- ------------------------------------------------------------------------------------
  -- Agrega los productos que fueron ingresados de mas 
  -- ------------------------------------------------------------------------------------
  INSERT INTO #TMP_SWIFT_POD
    SELECT
      -1 DocNum
     ,-1 DocEntryErp
     ,RECEPTION_HEADER DoEntry
     ,-1 LineNum
     ,CODE_SKU ItemCode
     ,ALLOCATED OpenQty
     ,22 ObjType
     ,0 Expected
     ,@DefaultWarehouse
    FROM #TMP_RECEPTION_DET trd
    WHERE trd.ALLOCATED > 0;


  


  SELECT
    tes.DoEntry
   ,tes.DocEntryErp
   ,tes.Expected Quantity
   ,tes.ItemCode
   ,CAST(tes.ObjType as VARCHAR)  ObjType
   ,tes.LineNum
  FROM #TMP_SWIFT_POD tes
  WHERE tes.Expected > 0;
