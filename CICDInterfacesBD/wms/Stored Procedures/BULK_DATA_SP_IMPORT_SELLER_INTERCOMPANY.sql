﻿-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade
-- Description:			    SP para obtener el codigo de cliente por cada base de datos de la multiempresa

-- Modificacion 06-Sep-17 @ Nexus Team Sprint CommandAndConquer
					-- alberto.ruiz
					-- Se agrega filtro para que solo obtenga

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_SELLER_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_SELLER_INTERCOMPANY]
AS
BEGIN
	SET NOCOUNT ON;
	--
	TRUNCATE TABLE [SWIFT_EXPRESS].[wms].[SWIFT_SELLER_INTERCOMPAY]
	--
	INSERT INTO [SWIFT_EXPRESS].[wms].[SWIFT_SELLER_INTERCOMPAY]
			(
				[MASTER_ID]
				,[SLP_CODE]
				,[SOURCE]
			)
	SELECT
		[MASTER_ID]
		,[SLP_CODE]
		,[SOURCE]
	FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_SELLER_SOURCE]
	WHERE [MASTER_ID] IS NOT NULL
END

