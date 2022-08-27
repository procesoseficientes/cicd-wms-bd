﻿-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		17-Dec-2017 @ Reborn-Team Sprint Quiterio 
-- Description:			    funcion que obtiene los saldos de lineas de las polizas

/*
-- Ejemplo de Ejecucion:
        
*/
-- =============================================
CREATE FUNCTION [wms].[fn_saldo_linea_poliza]()
RETURNS @SALDOS_TABLE TABLE (
 DOC_ID NUMERIC(18,0),
 LINE_NUMBER NUMERIC(18,0),
 QTY NUMERIC(18,4),
 BULTOS NUMERIC(18,4),
 CUSTOMS_AMOUNT NUMERIC(18,3),
 DAI NUMERIC(18,3),
 IVA NUMERIC(18,3)
) AS
BEGIN
 DECLARE 
  @DOC_ID NUMERIC(18,0),
  @LINE_NUMBER NUMERIC(18,0),
  @QTY NUMERIC(18,4),
  @BULTOS NUMERIC(18,4),
  @CUSTOMS_AMOUNT NUMERIC(18,3),
  @DAI NUMERIC(18,3),
  @IVA NUMERIC(18,3),
  @QTYO NUMERIC(18,4),
  @BULTOSO NUMERIC(18,4),
  @CUSTOMS_AMOUNTO NUMERIC(18,3),
  @DAIO NUMERIC(18,3),
  @IVAO NUMERIC(18,3)

  DECLARE ING_CURSOR CURSOR FOR 
  SELECT DISTINCT A.DOC_ID,A.LINE_NUMBER FROM [wms].OP_WMS_POLIZA_DETAIL A
  INNER JOIN [wms].OP_WMS_POLIZA_HEADER B ON A.DOC_ID = B.DOC_ID
  WHERE B.TIPO = 'INGRESO';
  
  OPEN ING_CURSOR;
  
  FETCH NEXT FROM ING_CURSOR INTO @DOC_ID,@LINE_NUMBER;
  
  WHILE @@FETCH_STATUS = 0
 BEGIN 
		 SELECT @BULTOS = ISNULL(SUM(BULTOS),0),
		 @QTY = ISNULL(SUM(QTY),0),
		 @CUSTOMS_AMOUNT= ISNULL(SUM(CUSTOMS_AMOUNT),0),
		 @DAI = ISNULL(SUM(DAI),0),
		 @IVA = ISNULL(SUM(IVA),0)
		FROM [wms].OP_WMS_POLIZA_DETAIL WHERE ORIGIN_DOC_ID = @DOC_ID 
		AND ORIGIN_LINE_NUMBER = @LINE_NUMBER;

		SELECT @BULTOSO = ISNULL(SUM(BULTOS),0),
		 @QTYO = ISNULL(SUM(QTY),0),
		 @CUSTOMS_AMOUNTO = ISNULL(SUM(CUSTOMS_AMOUNT),0),
		 @DAIO = ISNULL(SUM(DAI),0),
		 @IVAO = ISNULL(SUM(IVA),0)
		FROM [wms].OP_WMS_POLIZA_DETAIL WHERE DOC_ID = @DOC_ID AND LINE_NUMBER = @LINE_NUMBER;
		IF @BULTOSO > 0 OR @QTYO > 0 
			BEGIN
				INSERT @SALDOS_TABLE
				SELECT @DOC_ID,@LINE_NUMBER,@QTYO + @QTY,@BULTOSO + @BULTOS,@CUSTOMS_AMOUNTO + @CUSTOMS_AMOUNT,@DAIO + @DAI,@IVAO + @IVA;
			END;
		ELSE
			BEGIN
				INSERT @SALDOS_TABLE
				SELECT @DOC_ID,@LINE_NUMBER,0,0,0,0,0;
			END;
	FETCH NEXT FROM ING_CURSOR INTO @DOC_ID,@LINE_NUMBER;
	END;		
			CLOSE ING_CURSOR;
			DEALLOCATE ING_CURSOR;

 RETURN;

END