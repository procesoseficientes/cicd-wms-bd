
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-01-2016
-- Description:			obtiene las bodegas del ERP

/*
-- Ejemplo de Ejecucion:				
				-- EXEC [SONDA].[SWIFT_SP_GET_ERP_WAREHOUSE]


				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ERP_WAREHOUSE]

AS
BEGIN 
	SET NOCOUNT ON;

SELECT [CODE_WAREHOUSE]
      ,[DESCRIPTION_WAREHOUSE]
  FROM [SONDA].[SWIFT_VIEW_ERP_WAREHOUSE]
  ORDER BY [DESCRIPTION_WAREHOUSE] ASC

END
