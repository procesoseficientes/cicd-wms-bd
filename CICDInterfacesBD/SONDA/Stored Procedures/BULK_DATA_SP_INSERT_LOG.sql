-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-03-2016
-- Description:			SP que inserta en el log de la ejecucion del bulk data

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_INSERT_LOG]
					@SP = 'PRUEBA'
					,@START_RUN = '20160301 11:33:00.000'
					,@END_RUN = '20160301 11:34:00.000'
					,@MESSAGE = 'Proceso finalizado correctamente'
				--
				SELECT TOP 5 * FROM [SONDA].BULK_DATA_CONFIGURATION_LOG ORDER BY 1 DESC
*/
-- =============================================

CREATE PROCEDURE [SONDA].[BULK_DATA_SP_INSERT_LOG]
(	
	@SP VARCHAR(1000)
	,@START_RUN DATETIME
	,@END_RUN DATETIME
	,@MESSAGE VARCHAR(2000)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	INSERT INTO [SONDA].BULK_DATA_CONFIGURATION_LOG (
		[SP]
		,[START_RUN]
		,[END_RUN]
		,[MESSAGE]
	)
	VALUES (
		@SP
		,@START_RUN
		,@END_RUN
		,@MESSAGE
	)
END