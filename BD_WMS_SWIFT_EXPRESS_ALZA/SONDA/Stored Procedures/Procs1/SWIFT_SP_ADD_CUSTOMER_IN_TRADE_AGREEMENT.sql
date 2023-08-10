
/*==================================================

Autor:				diego.as
Fecha de Creacion:	12-09-2016 @ A-TEAM Sprint 1
Descripcion:		Elimina a un cliente de un acuerdo comercial
					, si tiene alguno asociado
					, y lo inserta con los nuevos datos

Ejemplo de Ejecución:

	EXEC [SONDA].[SWIFT_SP_ADD_CUSTOMER_IN_TRADE_AGREEMENT]
		@TRADE_AGREEMENT_ID = 21
		,@CODE_CUSTOMER = 'C002'

==================================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_CUSTOMER_IN_TRADE_AGREEMENT]
(
	@TRADE_AGREEMENT_ID INT
	,@CODE_CUSTOMER VARCHAR(50)
)AS
BEGIN
	BEGIN TRY
		--
		DECLARE @EXISTE_EN_ACUERDO INT = 0
            ,@ID INT
            ,@OLD_TRADE_AGREEMENT_ID INT

		--
		SELECT @EXISTE_EN_ACUERDO = 1, @OLD_TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] AS TA
		WHERE TA.CODE_CUSTOMER = @CODE_CUSTOMER

		--
		IF(@EXISTE_EN_ACUERDO = 1) BEGIN
			PRINT('TIENE ACUERDO COMERCIAL')
			--
			EXEC [SONDA].[SWIFT_SP_DELETE_CUSTOMER_FROM_TRADE_AGREEMENT]
				@TRADE_AGREEMENT_ID = @OLD_TRADE_AGREEMENT_ID
				,@CODE_CUSTOMER = @CODE_CUSTOMER

			--
			INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] 
				(
					TRADE_AGREEMENT_ID
					,CODE_CUSTOMER
				) VALUES (
						@TRADE_AGREEMENT_ID
						, @CODE_CUSTOMER
				)
			--
		END 
		ELSE BEGIN
			PRINT('NO TIENE ACUERDO COMERCIAL')
			--
			INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] 
				(
					TRADE_AGREEMENT_ID
					,CODE_CUSTOMER
				) 
				VALUES (
						@TRADE_AGREEMENT_ID
						, @CODE_CUSTOMER
						)
			--
		END
		--
    	--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData

	END TRY
	BEGIN CATCH
	SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta el cliente relacionado a un acuerdo comercial'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
