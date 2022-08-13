-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        Inserta en la tabla de OP_WMS_POLIZA_DETAIL

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_INSERT_POLIZA_DETAIL_GENERAL] @DOC_ID = 0
                                                          , @SKU_DESCRIPTION = ''
                                                          , @QTY = 1
                                                          , @CUSTOMS_AMOUNT = 1
                                                          , @CLIENT_CODE = 'q12'
                                                          , @LINE_NUMBER =1

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_POLIZA_DETAIL_GENERAL] (@DOC_ID NUMERIC
, @SKU_DESCRIPTION VARCHAR(250)
, @QTY NUMERIC(18, 3)
, @CUSTOMS_AMOUNT NUMERIC(18, 2)
, @CLIENT_CODE VARCHAR(25)
, @MATERIAL_ID VARCHAR(50)
, @UNITARY_PRICE NUMERIC(18, 2)
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @LINEID INT
  BEGIN TRY
    SELECT
      @LINEID = ISNULL(LINE_NUMBER, 0) + 1
    FROM [wms].OP_WMS_POLIZA_DETAIL
    WHERE DOC_ID = @DOC_ID

    IF @LINEID IS NULL
    BEGIN
      SET @LINEID = 1
    END

    INSERT INTO [wms].[OP_WMS_POLIZA_DETAIL] ([DOC_ID], [LINE_NUMBER], [SKU_DESCRIPTION], [BULTOS], [QTY], [CUSTOMS_AMOUNT], [QTY_UNIT], [CLIENT_CODE], [MATERIAL_ID], [UNITARY_PRICE], [LAST_UPDATED_BY], [LAST_UPDATED], [SAC_CODE], [DAI], [IVA], [MISC_TAXES])
      VALUES (@DOC_ID, @LINEID, @SKU_DESCRIPTION, @QTY, @QTY, @CUSTOMS_AMOUNT, 'UN', @CLIENT_CODE, @MATERIAL_ID, @UNITARY_PRICE, @LOGIN, GETDATE(), '',0,0,0)

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CONVERT(VARCHAR(25), @LINEID) DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH



END