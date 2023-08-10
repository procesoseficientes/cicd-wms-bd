-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-09-2016 @ A-TEAM Sprint 1
-- Description:			Actualiza el descuento del producto del acuerdo comercial

-- Modificacion 2/10/2017 @ A-Team Sprint Chatuluka
					-- rodrigo.gomez
					-- Se adapto el SP para la nueva estructura de la tabla y se agrego la validacion de rangos.
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_UPDATE_DISCOUNT_IN_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID  = 2
	        ,@CODE_SKU = '100002'
          ,@DISCOUNT = 8
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT WHERE TRADE_AGREEMENT_ID = 21
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_DISCOUNT_IN_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_DISCUOUNT_ID INT
	--,@TRADE_AGREEMENT_ID  INT
	--,@CODE_SKU  VARCHAR(50)
	--,@PACK_UNIT INT
	--,@LOW_LIMIT INT
	--,@HIGH_LIMIT INT
	,@DISCOUNT NUMERIC(18,6)
)
AS
BEGIN
	BEGIN TRY		
		--
		/*EXEC [SONDA].[SWIFT_SP_VALIDATED_DISCOUNT_SCALe] 
			@TRADE_AGREEMENT_DISCUOUNT_ID = @TRADE_AGREEMENT_DISCUOUNT_ID , -- int
			@TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID , -- int
			@CODE_SKU = @CODE_SKU , -- varchar(50)
			@PACK_UNIT = @PACK_UNIT , -- int
			@LOW_LIMIT = @LOW_LIMIT , -- int
			@HIGH_LIMIT = @HIGH_LIMIT -- int
			*/
		--
		UPDATE [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT SET
			--TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
			--,[CODE_SKU] = @CODE_SKU
			--,[PACK_UNIT] = @PACK_UNIT
			--,[LOW_LIMIT] = @LOW_LIMIT
			--,[HIGH_LIMIT] = @HIGH_LIMIT
			[DISCOUNT] = @DISCOUNT
		WHERE [TRADE_AGREEMENT_DISCUOUNT_ID] = @TRADE_AGREEMENT_DISCUOUNT_ID
		
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
