-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		12-Jan-17 @ A-Team Sprint Adeben
-- Description:			    Funcion que valida si la ruta tiene la regla para asignar un acuerdo comercial a los clientes nuevo y si esta activa si tiene un acuerdo comercial asignada la ruta

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE]('001')
*/
-- =============================================
CREATE FUNCTION [SONDA].SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE (@CODE_ROUTE VARCHAR(50))
RETURNS INT
AS
BEGIN
  DECLARE @HAS_TRADE_AGREEMENT INT = 1
         ,@HAS_EVENT INT = 0

  -- ------------------------------------------------------------------------------------
  -- Valida si la regla esta activa
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @HAS_EVENT = 1
  FROM [SONDA].[SWIFT_EVENT] [E]
  INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] [RXE]
    ON (
    [RXE].[EVENT_ID] = [E].[EVENT_ID]
    )
  INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] [RXR]
    ON (
    [RXR].[RULE_ID] = [RXE].[RULE_ID]
    )
  WHERE [RXR].[CODE_ROUTE] = @CODE_ROUTE
  AND [E].[type] = 'agregarCliente'
  AND [E].[TYPE_ACTION] = 'AsignarAcuerdoComercial'
  AND [E].[ENABLED] = 'Si'
  AND [RXR].[RULE_ID] > 0
  --
  IF @HAS_EVENT = 1
  BEGIN
    SELECT TOP 1
      @HAS_TRADE_AGREEMENT =
                            CASE
                              WHEN [R].[TRADE_AGREEMENT_ID] IS NULL THEN 0
                              ELSE 1
                            END
    FROM [SONDA].[SWIFT_ROUTES] [R]
    WHERE [R].[CODE_ROUTE] = @CODE_ROUTE
  END
  --
  RETURN @HAS_TRADE_AGREEMENT
END
