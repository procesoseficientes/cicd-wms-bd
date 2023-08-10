-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que agrega una venta por multiplo al acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_SKU_SALES_BY_MULTIPLE]
					@TRADE_AGREEMENT_ID = 21
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 8
					,@MULTIPLE = 2
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_SKU_SALES_BY_MULTIPLE](
	@TRADE_AGREEMENT_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@MULTIPLE INT
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
				(
					[TRADE_AGREEMENT_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[MULTIPLE]
				)
		VALUES
				(
					@TRADE_AGREEMENT_ID
					,@CODE_SKU
					,@PACK_UNIT
					,@MULTIPLE
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe una venta minima para el producto y unidad de medida seleccionado'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
