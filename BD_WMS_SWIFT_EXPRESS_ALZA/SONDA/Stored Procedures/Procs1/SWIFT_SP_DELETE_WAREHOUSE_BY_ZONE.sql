-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene las bodegas asociadas a una zona 

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_DELETE_WAREHOUSE_BY_ZONE] @WAREHOUSE_X_ZONE_ID = 0 ,  @ZONE_ID = 1
SELECT * FROM [SONDA].[SWIFT_WAREHOUSE_X_ZONE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_WAREHOUSE_BY_ZONE (@WAREHOUSE_X_ZONE_ID INT,
@ZONE_ID INT = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
  IF @ZONE_ID IS NULL
    OR @ZONE_ID < 0
  BEGIN

    DELETE [SONDA].[SWIFT_WAREHOUSE_X_ZONE]
    WHERE @WAREHOUSE_X_ZONE_ID = [WAREHOUSE_X_ZONE_ID]
   
 
  END
  ELSE
  BEGIN
      DELETE [SONDA].[SWIFT_WAREHOUSE_X_ZONE]
    WHERE @ZONE_ID = [ID_ZONE]
  END


END
