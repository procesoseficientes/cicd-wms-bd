-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	25-Nov-16 @ A-TEAM Sprint 5
-- Description:			    SP que obtiene la moneda default

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_DEFAULT_CURRENCY]					 
				-- 				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DEFAULT_CURRENCY]
AS
BEGIN

  SELECT TOP 1
    C.[CURRENCY_ID]
   ,C.[CODE_CURRENCY]
   ,C.[NAME_CURRENCY]
   ,C.[SYMBOL_CURRENCY]
   ,C.[IS_DEFAULT]
  FROM [SONDA].[SWIFT_CURRENCY] C
  WHERE C.IS_DEFAULT = 1

END
