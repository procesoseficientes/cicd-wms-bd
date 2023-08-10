-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que actualiza una zona 

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_UPDATE_ZONE] @ZONE_ID = 2,  @CODE_ZONE = '2', @DESCRIPTION_ZONE = 'Zona 2/1'
SELECT * FROM [SONDA].[SWIFT_ZONE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_ZONE] (
  @ZONE_ID INT
  ,@CODE_ZONE VARCHAR(50)
  ,@DESCRIPTION_ZONE VARCHAR(200),
  @LOGIN VARCHAR(50)
  )
AS
BEGIN
  SET NOCOUNT ON;
  --

  -- ------------------------------------------------------------------------------------
  -- Operar
  -- ------------------------------------------------------------------------------------
UPDATE [SONDA].[SWIFT_ZONE]
SET [CODE_ZONE] = @CODE_ZONE
   ,[DESCRIPTION_ZONE] = @DESCRIPTION_ZONE
  ,[LAST_UPDATED_BY] =   @LOGIN 
  ,[LAST_UPDATE] = GETDATE()
WHERE ZONE_ID = @ZONE_ID;


END
