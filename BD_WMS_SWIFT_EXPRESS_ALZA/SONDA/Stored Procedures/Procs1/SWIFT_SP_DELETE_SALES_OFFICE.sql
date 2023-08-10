-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Donkor 
-- Description:			SP que borra una oficina de ventas

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_SALES_OFFICE]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_SALES_OFFICE]
					@SALES_OFFICE_ID = 3
				-- 
				SELECT * FROM [SONDA].[SWIFT_SALES_OFFICE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_SALES_OFFICE](
	@SALES_OFFICE_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_SALES_OFFICE]
		WHERE [SALES_OFFICE_ID] = @SALES_OFFICE_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE 
			WHEN CAST(@@ERROR AS VARCHAR) = '547' THEN 'La Oficina De Ventas tiene vendedores o bodegas asociadas'
			ELSE ERROR_MESSAGE()
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
