-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-Apr-17 @ A-Team Sprint Garai
-- Description:			SP que importa las organizaciones de venta

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_SALES_OFFICE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_SALES_OFFICE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [SWIFT_EXPRESS].[SONDA].[SWIFT_SALES_OFFICE] SO
	USING (SELECT * FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_SALES_OFFICE]) AS VSO
	ON [SO].[NAME_SALES_OFFICE] = [VSO].[NAME_SALES_OFFICE]
	WHEN MATCHED THEN 
		UPDATE 
			SET [SO].[DESCRIPTION_SALES_OFFICE] = [VSO].[DESCRIPTION_SALES_OFFICE]
	WHEN NOT MATCHED THEN 
	INSERT (
			[NAME_SALES_OFFICE]
			,[DESCRIPTION_SALES_OFFICE]
		)
	VALUES (
		[VSO].[NAME_SALES_OFFICE]
		,[VSO].[NAME_SALES_OFFICE]
	);
END