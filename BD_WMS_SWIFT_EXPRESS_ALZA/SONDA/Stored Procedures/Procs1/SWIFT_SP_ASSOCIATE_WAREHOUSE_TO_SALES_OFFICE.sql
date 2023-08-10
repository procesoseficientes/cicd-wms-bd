-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/4/2017 @ A-TEAM Sprint Garai 
-- Description:			Se asigna la oficina de ventas a la bodega enviada

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ASSOCIATE_WAREHOUSE_TO_SALES_OFFICE]
					@SALES_OFFICE_ID = 1
					,@CODE_WAREHOUSE = 'BODEGA_CENTRAL'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ASSOCIATE_WAREHOUSE_TO_SALES_OFFICE](
	@SALES_OFFICE_ID INT
	,@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_WAREHOUSES]
		SET [SALES_OFFICE_ID] = @SALES_OFFICE_ID
		WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
