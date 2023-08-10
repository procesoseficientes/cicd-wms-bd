-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-Team Sprint 3
-- Description:			SP que limpia la lista de bonificaciones

-- Modificacion 21-Nov-16 @ A-Team Sprint 5
-- alberto.ruiz
-- Se agrego que tambien limpie la tabla SWIFT_BONUS_LIST_BY_SKU_MULTIPLE

-- Modificacion 10-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agregaron las nuevas tablas para combos

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta 

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_CLEAN_BONUS_LIST_BY_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_BONUS_LIST_BY_ROUTE] (@CODE_ROUTE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @BONUS TABLE (
    [BONUS_LIST_ID] INT
   ,UNIQUE ([BONUS_LIST_ID])
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene las listas de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO @BONUS
    SELECT DISTINCT
      [B].[BONUS_LIST_ID]
    FROM [SONDA].[SWIFT_BONUS_LIST] [B]
    WHERE [B].[CODE_ROUTE] = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Limpia las tablas
  -- ------------------------------------------------------------------------------------	
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU_MULTIPLE] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO_SKU] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_GENERAL_AMOUNT] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
  --
  DELETE [B]
    FROM [SONDA].[SWIFT_BONUS_LIST] [B]
    INNER JOIN @BONUS [BL]
      ON (
      [B].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      )
  WHERE [BL].[BONUS_LIST_ID] > 0
END
