-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	21-10=2017 @ Team REBORN - Sprint Nach
-- Description:	        Sp que marca que la factura genero xml

/*
-- Ejemplo de Ejecucion:
			EXEC [SONDA].[SWIFT_SP_MARK_THAT_GENERATED_XML_THE_INVOICE] @INVOICE_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_MARK_THAT_GENERATED_XML_THE_INVOICE] (@INVOICE_ID INT, @CDF_RESOLUCION VARCHAR(50) , @CDF_SERIE VARCHAR(50))

AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER] SET
      [IS_EXPORTED_TO_XML] = 1   
    WHERE [INVOICE_ID] = @INVOICE_ID
    AND [CDF_RESOLUCION] = @CDF_RESOLUCION
    AND [CDF_SERIE] = @CDF_SERIE

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,'0' [DbData];


  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
  END CATCH;

END
