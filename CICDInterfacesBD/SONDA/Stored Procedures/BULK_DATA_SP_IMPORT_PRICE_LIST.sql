-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa lista de precios


-- Modificacion 24-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agregan campos de owner y owner id
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_PRICE_LIST]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_PRICE_LIST]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE  [SWIFT_EXPRESS].[SONDA].[SWIFT_PRICE_LIST] AS [TGR]
	USING (SELECT * FROM  [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_PRICE_LIST]) AS [SRC] 
	ON [TGR].[CODE_PRICE_LIST] =  [SRC].[CODE_PRICE_LIST] 
	WHEN  MATCHED THEN 
	UPDATE 
		SET
			[TGR].[CODE_PRICE_LIST] = [SRC].[CODE_PRICE_LIST] 
			,[TGR].[NAME_PRICE_LIST] = [SRC].[NAME_PRICE_LIST] 
			,[TGR].[COMMENT] = [SRC].[COMMENT] 
			,[TGR].[LAST_UPDATE] = [SRC].[LAST_UPDATE] 
			,[TGR].[LAST_UPDATE_BY] = [SRC].[LAST_UPDATE_BY]
			,[TGR].[OWNER] = [SRC].[OWNER]
			,[TGR].[OWNER_ID] = [SRC].[OWNER_ID]
	WHEN NOT MATCHED THEN 
	INSERT (
		[CODE_PRICE_LIST]
		,[NAME_PRICE_LIST]
		,[COMMENT]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[OWNER]
		,[OWNER_ID]
	)
	VALUES (
	 [SRC].[CODE_PRICE_LIST] 
	 ,[SRC].[NAME_PRICE_LIST] 
	 ,[SRC].[COMMENT] 
	 ,[SRC].[LAST_UPDATE]
	 ,[SRC].[LAST_UPDATE_BY] 
	 ,[SRC].[OWNER]
	 ,[SRC].[OWNER_ID]
	);
END