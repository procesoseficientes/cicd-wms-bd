﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa proveederoes

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_PROVIDER]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_PROVIDER]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [wms].SWIFT_ERP_PROVIDERS TRG
	USING (SELECT * FROM SWIFT_INTERFACES_ONLINE.[wms].ERP_VIEW_PROVIDERS) AS SRC
	ON TRG.CODE_PROVIDER = SRC.CODE_PROVIDER
	WHEN MATCHED THEN 
		UPDATE 
		SET TRG.[PROVIDER] = SRC.[PROVIDER]
		  ,TRG.[CODE_PROVIDER] = SRC.[CODE_PROVIDER]
		  ,TRG.[NAME_PROVIDER] = SRC.[NAME_PROVIDER]
		  ,TRG.[CLASSIFICATION_PROVIDER] = SRC.[CLASSIFICATION_PROVIDER] 
		  ,TRG.[CONTACT_PROVIDER] = SRC.[CONTACT_PROVIDER]
		  ,TRG.[FROM_ERP] = SRC.[FROM_ERP]
		  ,TRG.[NAME_CLASSIFICATION] = SRC.[NAME_CLASSIFICATION]
	WHEN NOT MATCHED THEN 
	INSERT (
		[PROVIDER]
		,[CODE_PROVIDER]
		,[NAME_PROVIDER]
		,[CLASSIFICATION_PROVIDER]
		,[CONTACT_PROVIDER]
		,[FROM_ERP]
		,[NAME_CLASSIFICATION])
	VALUES (
		SRC.[PROVIDER]
		,SRC.[CODE_PROVIDER]
		,SRC.[NAME_PROVIDER]
		,SRC.[CLASSIFICATION_PROVIDER]
		,SRC.[CONTACT_PROVIDER]
		,SRC.[FROM_ERP]
		,SRC.[NAME_CLASSIFICATION]
	);
END

