-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	10-02-2016
-- Description:			Obtiene todos los documentos de que esten asociados a una ruta

-- Modificacion 5/14/2018 @ A-Team Sprint 
					-- diego.as
					-- Se agregan campos [BRANCH_NAME], [BRANCH_ADDRESS] al SELECT
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SONDA_SP_GET_DOCUMENT_SEQUENCE] @CODE_ROUTE = '46'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DOCUMENT_SEQUENCE]
	(
		@CODE_ROUTE VARCHAR(100)
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		SELECT
			[D].[DOC_TYPE]
			,[D].[DOC_FROM]
			,[D].[DOC_TO]
			,[D].[SERIE]
			,[D].[CURRENT_DOC]
			,[D].[BRANCH_NAME]
			,[D].[BRANCH_ADDRESS]
		FROM
			[SONDA].[SWIFT_DOCUMENT_SEQUENCE] [D]
		WHERE
			[D].[ASSIGNED_TO] = @CODE_ROUTE
			AND [D].[STATUS] = 1;
	END;
