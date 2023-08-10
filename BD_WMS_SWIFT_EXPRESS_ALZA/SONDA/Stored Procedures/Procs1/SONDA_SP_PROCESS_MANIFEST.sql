-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/23/2017 @ Reborn -TEAM Sprint Drache
-- Description:			SP que ejecuta el procesado del manifiesto que recibe 

-- Modificacion 12/8/2017 @ Reborn-Team Sprint Pannen
					-- diego.as
					-- Se agrega parametro de gps actual del operador para enviarlo al sp que procesa el plan de ruta de entrega

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_PROCESS_MANIFEST]
				@MANIFES_HEADER_ID = 1108
				, @LOGIN_ID = 'ADOLFO@SONDA'
				, @CURRENT_GPS_USER = '14.64986000,-90.53980000'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_PROCESS_MANIFEST](
	@MANIFES_HEADER_ID INT
	,@LOGIN_ID VARCHAR(50)
	,@CURRENT_GPS_USER VARCHAR(50)
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		
		-- -----------------------------------------------------------------------------------------
		-- Se manda a validar la existencia del manifiesto escaneado
		-- -----------------------------------------------------------------------------------------
		EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXIST_3PL_MANIFEST] @MANIFEST_HEADER_ID = @MANIFES_HEADER_ID,@LOGIN_ID = @LOGIN_ID -- int

		-- -----------------------------------------------------------------------------------------
		-- Se manda a validar el ESTADO del manifiesto escaneado
		-- -----------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_VALIDATE_MANIFEST_3PL] @MANIFEST_HEADER_ID = @MANIFES_HEADER_ID -- int

		-- -----------------------------------------------------------------------------------------
		-- Se manda a generar el listado de tareas del manifiesto si la validacion fue exitosa
		-- -----------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_GENERATE_DELIVERY_PLAN_FROM_MANIFEST_3PL] 
			@MANIFEST_HADER_ID = @MANIFES_HEADER_ID , -- int
			@LOGIN_ID = @LOGIN_ID, -- varchar(25)
			@CURRENT_GPS_USER = @CURRENT_GPS_USER

		-- ----------------------------------------------------------------------------------------
		-- Se retorna el resultado como exitoso
		-- ----------------------------------------------------------------------------------------
		SELECT  1 as Resultado
		,'Proceso Exitoso' Mensaje 
		,@@ERROR Codigo 
		--
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
