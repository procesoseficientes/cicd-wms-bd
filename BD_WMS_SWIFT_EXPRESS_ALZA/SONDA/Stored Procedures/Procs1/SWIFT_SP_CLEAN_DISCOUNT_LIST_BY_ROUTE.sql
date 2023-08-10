-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos

-- Modificacion 16-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrego que limpie la tabla SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT

-- Modificacion 25-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta

-- Modificacion 07-May-2018 @ G-Force Team Sprint Caribú
-- rudi.garcia
-- Se agregaron las tablas [SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT_AND_FAMILY] y [SWIFT_DISCOUNT_LIST_BY_PAYMENT_TYPE_AND_FAMILY]

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_CLEAN_DISCOUNT_LIST_BY_ROUTE]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_CLEAN_DISCOUNT_LIST_BY_ROUTE (@CODE_ROUTE VARCHAR(250)) WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DISCOUNT_LIST TABLE (
    [DISCOUNT_LIST_ID] INT NOT NULL
    UNIQUE ([DISCOUNT_LIST_ID])
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene las listas de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DISCOUNT_LIST
    SELECT DISTINCT
      [D].[DISCOUNT_LIST_ID]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST] [D]
    WHERE [D].[CODE_ROUTE] = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Limpia las tablas
  -- ------------------------------------------------------------------------------------	
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
  --
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_SKU] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
  --
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
  --
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT_AND_FAMILY] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
    --
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST_BY_PAYMENT_TYPE_AND_FAMILY] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
  --
  DELETE [D]
    FROM [SONDA].[SWIFT_DISCOUNT_LIST] [D]
    INNER JOIN @DISCOUNT_LIST [DL]
      ON (
      [D].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
  WHERE [DL].[DISCOUNT_LIST_ID] > 0
END
