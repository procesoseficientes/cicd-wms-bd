-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion:   12-Nov-2018 G-FORCE@Narwhal
-- Description:			    SP que obtiene el orden de aplicar los descuentos.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SONDA_SP_GET_ORDER_FOR_DISCOUNT_FOR_APPLY
				@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE SONDA.SONDA_SP_GET_ORDER_FOR_DISCOUNT_FOR_APPLY (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
   [ODD].[ORDER_FOR_DISCOUNT_HEADER_ID]
   ,[ODD].[ORDER_FOR_DISCOUNT_DETAIL_ID]   
   ,[ODD].[ORDER]
   ,[ODD].[CODE_DISCOUNT]
   ,[ODD].[DESCRIPTION]   
  FROM [SONDA].[SWIFT_ORDER_FOR_DISCOUNT_DETAIL] [ODD]
  INNER JOIN [SONDA].[SWIFT_ORDER_FOR_DISCOUNT_BY_ROUTE] [ODR]
    ON ([ODD].[ORDER_FOR_DISCOUNT_HEADER_ID] = [ODR].[ORDER_FOR_DISCOUNT_HEADER_ID])
  WHERE [ODR].[ROUTE_ID] = @CODE_ROUTE



END;
