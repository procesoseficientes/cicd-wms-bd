-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	06-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene el inventario de una zona asociada a un login 

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_GET_ZONE]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ZONE] (@ID_ZONE INT = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --


  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    [Z].[ZONE_ID]
   ,[Z].[CODE_ZONE]
   ,[Z].[DESCRIPTION_ZONE]
  FROM [SONDA].[SWIFT_ZONE] [Z]
    WHERE @ID_ZONE IS  NULL OR  @ID_ZONE = [Z].[ZONE_ID]


END
