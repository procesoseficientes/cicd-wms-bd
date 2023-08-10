-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		24-10-2016 @ A-TEAM SRINT 3
-- Description:			      SP que obtiene el reporte consolidado de carga 

/*
-- Ejemplo de Ejecucion:
		--
		EXEC [SONDA].SWIFT_SP_GET_MANIFEST_HEADER_FROM_PICKING
			@MANIFEST_HEADER = 3071 
					EXEC [SONDA].SWIFT_SP_GET_MANIFEST_HEADER
			@MANIFEST_HEADER = 3071 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_MANIFEST_HEADER_FROM_PICKING (@MANIFEST_HEADER INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    ISNULL([U].[LOGIN], 'DEFAULT') [LOGIN]
   ,[C].[CODE_CUSTOMER]
   ,MAX([C].[NAME_CUSTOMER]) [NAME_CUSTOMER]
   ,ISNULL(MAX([C].[ADRESS_CUSTOMER]), '...') [ADDRESS_CUSTOMER]
   ,SUM([PD].[SCANNED]) QTY
   ,0 [TOTAL_AMOUNT]
  FROM [SONDA].[SWIFT_MANIFEST_HEADER] [MH]
  INNER JOIN [SONDA].[SWIFT_MANIFEST_DETAIL] [MD]
    ON (
    [MH].[MANIFEST_HEADER] = [MD].[CODE_MANIFEST_HEADER]
    )
  INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    ON (
    [C].[CODE_CUSTOMER] = [MD].[CODE_CUSTOMER]
    )
  INNER JOIN [SONDA].[SWIFT_PICKING_HEADER] [PH]
    ON (
    [MD].[CODE_PICKING] = [PH].[PICKING_HEADER]
    )
  INNER JOIN [SONDA].[SWIFT_PICKING_DETAIL] [PD]
    ON (
    [PH].[PICKING_HEADER] = [PD].[PICKING_HEADER]
    )
  LEFT JOIN [SONDA].[USERS] [U]
    ON (-----------------------------------------------------
    [U].[LOGIN] = [PH].[CODE_USER]
    )  
  WHERE [MH].[MANIFEST_HEADER] = @MANIFEST_HEADER
  GROUP BY [U].[LOGIN]
          ,[C].[CODE_CUSTOMER]
  ORDER BY [U].[LOGIN]
END
