-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Donkor  
-- Description:			SP que obtiene los registros de Vendedores asociados a una oficina de ventas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ASSIGNED_SELLERS_BY_SALES_OFFICE]
				@SALES_OFFICE_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ASSIGNED_SELLERS_BY_SALES_OFFICE](
	@SALES_OFFICE_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [SELLER_CODE]
			,[SELLER_NAME]
			,ISNULL([PHONE1], '') [PHONE1]
			,ISNULL([PHONE2], '') [PHONE2]
			,[RATED_SELLER]
			,[STATUS]
			,ISNULL([EMAIL], '') [EMAIL]
			,[ASSIGNED_VEHICLE_CODE]
			,[ASSIGNED_DISTRIBUTION_CENTER]
			,[LAST_UPDATED]
			,[LAST_UPDATED_BY]
			,[SALES_OFFICE_ID] 
	FROM [SONDA].[SWIFT_SELLER]
	WHERE [SALES_OFFICE_ID] = @SALES_OFFICE_ID
END
