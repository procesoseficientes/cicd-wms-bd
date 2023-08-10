-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/20/2017 @ A-TEAM Sprint Hondo 
-- Description:			SP que importa las compañias

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_COMPANY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_COMPANY]
AS
BEGIN
	SET NOCOUNT ON;
	--
	MERGE [SWIFT_EXPRESS].[SONDA].[SWIFT_COMPANY] SC 
	USING ( SELECT * FROM  [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_COMPANY]) VC 
	ON [SC].[COMPANY_ID]   =  [VC].[COMPANY_ID]
	WHEN MATCHED THEN 
	UPDATE 
		SET [SC].[COMPANY_ID]	=	[VC].[COMPANY_ID]
			,[SC].[COMPANY_NAME]   =  [VC].[COMPANY_NAME]
	WHEN NOT MATCHED THEN 
	INSERT (
		[COMPANY_ID],
		[COMPANY_NAME]
	) 
	VALUES (
		[VC].[COMPANY_ID],
		[VC].[COMPANY_NAME]
	 );
END