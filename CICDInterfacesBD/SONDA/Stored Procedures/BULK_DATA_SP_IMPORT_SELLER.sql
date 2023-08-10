-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa vendedores de SAP

-- Modificacion 04-Apr-17 @ A-Team Sprint Garai
					-- alberto.ruiz
					-- Se ajusto para que inserte en la tabla de Swift_Express

-- Modificacion 25-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega la columna de GPS

-- Modificacion 08-Jun-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agrega columna source

-- Modificacion 22-Jun-17 @ A-Team Sprint Khalid
					-- alberto.ruiz
					-- Se agrega el campo status

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_SELLER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_SELLER]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [SWIFT_EXPRESS].[SONDA].[SWIFT_SELLER] [TRG]
	USING (SELECT * FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_SELLER) AS [SRC]
	ON TRG.SELLER_CODE = SRC.SELLER_CODE COLLATE DATABASE_DEFAULT
	WHEN MATCHED THEN 
		UPDATE 
			SET [TRG].[SELLER_CODE] = [SRC].[SELLER_CODE]
			  ,[TRG].[SELLER_NAME] = [SRC].[SELLER_NAME]
			  ,[TRG].[OWNER] = [SRC].[OWNER]
			  ,[TRG].[OWNER_ID] = [SRC].[OWNER_ID]
			  ,[TRG].[GPS] = [SRC].[GPS]
			  ,[TRG].[SOURCE] = [SRC].[SOURCE]
			  ,[TRG].[STATUS] = 'ACTIVE'
			  ,[TRG].[EMAIL] = [SRC].[EMAIL]
	WHEN NOT MATCHED THEN 
	INSERT (
		[SELLER_CODE]
		,[SELLER_NAME]
		,[OWNER]
		,[OWNER_ID]
		,[GPS]
		,[SOURCE]
		,[STATUS]
		,[EMAIL]
	)
	VALUES (
		[SRC].[SELLER_CODE]
		,[SRC].[SELLER_NAME]
		,[SRC].[OWNER]
		,[SRC].[OWNER_ID]
		,[SRC].[GPS]
		,[SRC].[SOURCE]
		,'ACTIVE'
		,[SRC].[EMAIL]
	);
END