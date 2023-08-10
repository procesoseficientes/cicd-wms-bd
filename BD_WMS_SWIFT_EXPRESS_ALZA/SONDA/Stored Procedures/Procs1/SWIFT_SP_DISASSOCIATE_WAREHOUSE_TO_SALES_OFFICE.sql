-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/4/2017 @ A-TEAM Sprint Garai 
-- Description:			SP que desasocia la oficina de ventas de una bodega

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_DISASSOCIATE_WAREHOUSE_TO_SALES_OFFICE]
					@CODE_WAREHOUSE = 'BODEGA_CENTRAL'
				-- 
				SELECT * FROM [SONDA].SWIFT_WAREHOUSES
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DISASSOCIATE_WAREHOUSE_TO_SALES_OFFICE](
	@CODE_WAREHOUSE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].SWIFT_WAREHOUSES
		SET	
			[SALES_OFFICE_ID] = NULL
		WHERE 
			[CODE_WAREHOUSE] = @CODE_WAREHOUSE
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
