﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-Apr-17 @ A-Team Sprint Garai
-- Description:			SP que importa las organizaciones de venta

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_SALES_ORGANIZATION]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_SALES_ORGANIZATION]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [SWIFT_EXPRESS].[SONDA].[SWIFT_SALES_ORGANIZATION] SG
	USING (SELECT * FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_SALES_ORGANIZATION]) AS VSG
	ON [SG].[NAME_SALES_ORGANIZATION] = [VSG].[NAME_SALES_ORGANIZATION]
	WHEN MATCHED THEN 
		UPDATE 
			SET [SG].[DESCRIPTION_SALES_ORGANIZATION] = [VSG].[NAME_SALES_ORGANIZATION]
	WHEN NOT MATCHED THEN 
	INSERT (
			[NAME_SALES_ORGANIZATION]
			,[DESCRIPTION_SALES_ORGANIZATION]
		)
	VALUES (
		[VSG].[NAME_SALES_ORGANIZATION]
		,[VSG].[NAME_SALES_ORGANIZATION]
	);
END