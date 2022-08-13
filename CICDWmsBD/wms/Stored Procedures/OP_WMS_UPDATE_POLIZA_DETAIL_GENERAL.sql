-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        actualiza en la tabla de OP_WMS_POLIZA_DETAIL

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_UPDATE_POLIZA_DETAIL_GENERAL] @DOC_ID = 0
                                                          , @SKU_DESCRIPTION = ''
                                                          , @QTY = 1
                                                          , @CUSTOMS_AMOUNT = 1
                                                          , @CLIENT_CODE = 'q12'
                                                          , @LINE_NUMBER =1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_UPDATE_POLIZA_DETAIL_GENERAL] (@DOC_ID NUMERIC
, @SKU_DESCRIPTION VARCHAR(250)
, @QTY NUMERIC(18, 3)
, @CUSTOMS_AMOUNT NUMERIC(18, 2)
, @CLIENT_CODE VARCHAR(25)
, @LINE_NUMBER NUMERIC
, @UNITARY_PRICE NUMERIC(18,2)
, @LOGIN VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --
  
  BEGIN TRY    

    UPDATE [wms].[OP_WMS_POLIZA_DETAIL] SET
      [SKU_DESCRIPTION] = @SKU_DESCRIPTION
      ,[BULTOS] = @QTY
      ,[QTY] = @QTY
      ,[CUSTOMS_AMOUNT] = @CUSTOMS_AMOUNT
      ,[CLIENT_CODE] = @CLIENT_CODE
      ,[UNITARY_PRICE] = @UNITARY_PRICE
      ,[LAST_UPDATED_BY] =@LOGIN
      ,[LAST_UPDATED] = GETDATE()
    WHERE [DOC_ID] = @DOC_ID
    AND [LINE_NUMBER] = @LINE_NUMBER

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH



END