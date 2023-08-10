-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	23-Nov-16 @ A-TEAM Sprint 5 
-- Description:			Valida si ya esta asociada la seria al sku

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_EXIST_SKU_SERIAL]
					@CODE_SKU = '100003'
					,@SERIAL = 'ASDB12315'
				--
				EXEC [SONDA].[SWIFT_SP_VALIDATE_EXIST_SKU_SERIAL]
					@CODE_SKU = '100003'
					,@SERIAL = 'ASDB12316'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_EXIST_SKU_SERIAL](
	@CODE_SKU VARCHAR(50)
	,@SERIAL VARCHAR(150)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @EXIST INT = 0
	--
	SELECT TOP 1 @EXIST = 1
	FROM [SONDA].[SWIFT_INVENTORY] [I]
	WHERE [I].[SKU] = @CODE_SKU
		AND [I].[SERIAL_NUMBER] = @SERIAL
	--
	IF @EXIST = 0
	BEGIN
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,CAST(@EXIST AS VARCHAR) DbData
	END
	ELSE
	BEGIN
		SELECT 
			-1 as Resultado
			,'Ya esta asociada la serie ' + @SERIAL + ' al SKU ' + @CODE_SKU + ' en el inventario' Mensaje 
			,0 Codigo
			,CAST(@EXIST AS VARCHAR) DbData
	END
END
