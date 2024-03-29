﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/27/2016 @ A-TEAM Sprint  
-- Description:			SP que borra un registro de SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER si lleva ambos parametros o borra todos los registros con el @DISTRIBUTION_CENTER_ID

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM 
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_WAREHOUSE_X_DISTRIBUTION_CENTER]
					@DISTRIBUTION_CENTER_ID INT
					,@CODE_WAREHOUSE VARCHAR(50)
				-- 
				SELECT * FROM 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_WAREHOUSE_X_DISTRIBUTION_CENTER](
	@DISTRIBUTION_CENTER_ID INT
	,@CODE_WAREHOUSE VARCHAR(50) = NULL
)
AS
BEGIN
	BEGIN TRY

		IF @CODE_WAREHOUSE IS NULL 
		BEGIN
			DELETE FROM [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER]
			WHERE @DISTRIBUTION_CENTER_ID = [DISTRIBUTION_CENTER_ID] 
		END
		ELSE
		BEGIN
			DELETE FROM [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER]
			WHERE @DISTRIBUTION_CENTER_ID = [DISTRIBUTION_CENTER_ID] AND @CODE_WAREHOUSE = [CODE_WAREHOUSE]
		END

		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
