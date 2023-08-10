
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	12-01-2016
-- Description:			Obtiene las unidades de medida por tipo

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_GET_UNIT_MEASURE] 
@TYPE = 'PESO'

				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_UNIT_MEASURE]
    @TYPE [varchar](50)
AS
BEGIN 


	SET NOCOUNT ON;

	SELECT [CODE]
		  ,[DESCRIPTION]
		  ,[TYPE]
	FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_MEASURE_UNIT]
	WHERE [TYPE] = @TYPE 
	ORDER BY [DESCRIPTION] ASC


END
