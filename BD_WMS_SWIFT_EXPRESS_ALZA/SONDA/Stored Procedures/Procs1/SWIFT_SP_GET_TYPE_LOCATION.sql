-- =====================================================
-- Author:         diego.as
-- Create date:    11-03-2016
-- Description:    Trae los Tipos de Location de la tabla 
--				   [SONDA].SWIFT_CLASIFICATION
--				   
--
/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SWIFT_SP_GET_TYPE_LOCATION]
		
*/			
-- =====================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TYPE_LOCATION]
AS
BEGIN
	SELECT SC.CLASSIFICATION
		,SC.NAME_CLASSIFICATION 
	FROM [SONDA].SWIFT_CLASSIFICATION AS SC
	WHERE SC.GROUP_CLASSIFICATION = 'LOCATION'
	ORDER BY (SC.CLASSIFICATION)
END
