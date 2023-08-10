-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2016-12-28
-- Description:	Consulta de todos los vendedores disponibles




/*
-- Ejemplo de Ejecucion:
			exec [SONDA].SWIFT_SP_GET_SELLER_AVAILABLE
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SELLER_AVAILABLE]
AS
BEGIN
  SELECT DISTINCT
    [S].[SELLER_CODE]
   ,[S].[SELLER_NAME]
   ,[S].[PHONE1]
   ,[S].[PHONE2]
   ,[S].[RATED_SELLER]
   ,[S].[STATUS]
   ,[S].[EMAIL]
   ,[S].[ASSIGNED_VEHICLE_CODE]
   ,[S].[ASSIGNED_DISTRIBUTION_CENTER]
  FROM [SONDA].[SWIFT_VIEW_ALL_SELLERS] [S]
   
  WHERE [S].[STATUS] = 'ACTIVE'
END
