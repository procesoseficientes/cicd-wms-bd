/*
	-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	21-01-2016
-- Description:			Obtiene la localizacion del pallet
						--
-- Ejemplo de Ejecucion:	
						SELECT [SONDA].[SWIFT_FUNC_VALIDATE_PALLET_EXISTENCE]('6211','20GE','60')
						--						--
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_PALLET_ALLOCATED]
( 
@PALLET_ID AS INT
)
RETURNS BIT
	AS
BEGIN

	DECLARE @RESULT BIT = 0
	--
	SELECT TOP 1 @RESULT = 1  
	FROM [SONDA].[SWIFT_PALLET] TP 
	WHERE TP.PALLET_ID = @PALLET_ID AND TP.STATUS = 'LOCATED'

	--
	RETURN @RESULT
 END;
