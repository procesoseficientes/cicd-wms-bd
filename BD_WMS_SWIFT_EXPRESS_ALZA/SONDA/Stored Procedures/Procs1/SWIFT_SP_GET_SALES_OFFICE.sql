-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Donkor  
-- Description:			SP que obtiene Una Oficina de Ventas o Todas

-- Modificacion 4/5/2017 @ A-Team Sprint Garai
					-- rodrigo.gomez
					-- se cambio de inner a left join
/*
-- Ejemplo de Ejecucion:
				
		//Una en especifico
		EXEC [SONDA].[SWIFT_SP_GET_SALES_OFFICE]
		@SALES_OFFICE_ID = 2
				
		--

		// Todas
		EXEC [SONDA].[SWIFT_SP_GET_SALES_OFFICE]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SALES_OFFICE](
	@SALES_OFFICE_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [SOFF].[SALES_OFFICE_ID]
			,[SOFF].[SALES_ORGANIZATION_ID]
			,[SOFF].[NAME_SALES_OFFICE]
			,[SOFF].[DESCRIPTION_SALES_OFFICE]
			,[SORG].[NAME_SALES_ORGANIZATION]
			,[SORG].[DESCRIPTION_SALES_ORGANIZATION]
	FROM [SONDA].[SWIFT_SALES_OFFICE] [SOFF]
		LEFT JOIN [SONDA].[SWIFT_SALES_ORGANIZATION] [SORG] ON [SOFF].[SALES_ORGANIZATION_ID] = [SORG].[SALES_ORGANIZATION_ID]
	WHERE [SALES_OFFICE_ID] = @SALES_OFFICE_ID
	OR @SALES_OFFICE_ID IS NULL
	--
END
