-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-05-25 @ Team ERGON - Sprint Sheik
-- Description:	        actualiza en la tabla de op_wms_poliza_header

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_UPDATE_POLIZA_HEADER_GENERAL] @DOC_ID = 0
                                                          , @POLIZA_ASEGURADA = '23123'
                                                          , @ACUERDO_COMERCIAL = '12'        
                                                          , @LOGIN = 'admin'                                                  
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_UPDATE_POLIZA_HEADER_GENERAL (@DOC_ID NUMERIC
, @POLIZA_ASEGURADA VARCHAR(50)
, @ACUERDO_COMERCIAL VARCHAR(25)
, @LOGIN VARCHAR(25)
)
AS
BEGIN
  SET NOCOUNT ON;
  --
  
  BEGIN TRY    

    UPDATE [wms].[OP_WMS_POLIZA_HEADER] SET
      [POLIZA_ASEGURADA] = @POLIZA_ASEGURADA
      ,[ACUERDO_COMERCIAL] = @ACUERDO_COMERCIAL
      ,[LAST_UPDATED_BY] = @LOGIN
      ,[LAST_UPDATED] = GETDATE()
    WHERE [DOC_ID] = @DOC_ID;  
    
    UPDATE [IL] SET 
      [IL].[TERMS_OF_TRADE] = @ACUERDO_COMERCIAL
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
    INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON (
      [IL].[LICENSE_ID] = [L].[LICENSE_ID]
    )
    WHERE [L].[CODIGO_POLIZA] = CONVERT(VARCHAR(25), @DOC_ID);
    

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