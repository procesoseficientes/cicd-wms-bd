-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	19-02-2016
-- Description:			Valida la existencia del batch

/*
-- Ejemplo de Ejecucion:				
	--
	EXECUTE [SONDA].[SWIFT_SP_VALIDATE_BATCH] 
	@BATCH_ID = 2222
	--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_BATCH]
(
	 @BATCH_ID AS INT
)
AS
BEGIN 

  SET NOCOUNT ON;

  DECLARE  @RESULTADO AS INT = 0;
      
  SELECT  TOP 1 @RESULTADO = 1
	FROM  [SONDA].[SWIFT_BATCH] AS SB 
  WHERE [SB].[BATCH_ID] = @BATCH_ID

  SELECT @RESULTADO AS EXISTENCE_BATCH


END
