-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que borra un combo

-- Modificacion 7/26/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agrega el mensaje de error con la tabla SWIFT_PROMO_BY_COMBO_PROMO_RULE

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_COMBO]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_COMBO]
					@COMBO_ID = 5
				-- 
				SELECT * FROM [SONDA].[SWIFT_COMBO]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_COMBO](
	@COMBO_ID INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_COMBO]
		WHERE [COMBO_ID] = @COMBO_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE 
			WHEN CAST(@@ERROR AS VARCHAR) = '547' AND ERROR_MESSAGE() LIKE '%SWIFT_SKU_BY_COMBO%' THEN 'El combo tiene productos asociados'
			WHEN CAST(@@ERROR AS VARCHAR) = '547' AND ERROR_MESSAGE() LIKE '%SWIFT_TRADE_AGREEMENT%' THEN 'El combo esta relacionado a un acuerdo comercial'
			WHEN CAST(@@ERROR AS VARCHAR) = '547' AND ERROR_MESSAGE() LIKE '%SWIFT_PROMO_BY_COMBO_PROMO_RULE%' THEN 'El combo esta relacionado a una promoción.'
			ELSE ERROR_MESSAGE()
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
