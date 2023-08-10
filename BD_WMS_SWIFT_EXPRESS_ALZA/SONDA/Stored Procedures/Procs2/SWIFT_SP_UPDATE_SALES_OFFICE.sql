-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Donkor 
-- Description:			SP que actualiza una oficina de ventas

-- Modificacion 4/4/2017 @ A-Team Sprint Garai
					-- rodrigo.gomez
					-- Se establece el @SALES_ORGANIZATION_ID como NULL

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SALES_OFFICE]
				@SALES_OFFICE_ID = 2
				,@SALES_ORGANIZATION_ID = 1
				,@NAME_SALES_OFFICE = 'prueba oficina de ventas'
				,@DESCRIPTION_SALES_OFFICE = 'descripcion oficina de ventas'
				-- 
				SELECT * FROM [SONDA].[SWIFT_SALES_OFFICE] WHERE SALES_OFFICE_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SALES_OFFICE](
	@SALES_OFFICE_ID INT
	,@SALES_ORGANIZATION_ID INT = NULL
	,@NAME_SALES_OFFICE VARCHAR(50)
	,@DESCRIPTION_SALES_OFFICE VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_SALES_OFFICE]
		SET	
			[SALES_ORGANIZATION_ID] = @SALES_ORGANIZATION_ID
			,[NAME_SALES_OFFICE] = @NAME_SALES_OFFICE
			,[DESCRIPTION_SALES_OFFICE] = @DESCRIPTION_SALES_OFFICE
		WHERE 
			[SALES_OFFICE_ID] = @SALES_OFFICE_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Registro ya existe'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
