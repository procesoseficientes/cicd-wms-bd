-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-04-2016
-- Description:			Crea detalle de la orden de venta
/*
-- EJEMPLO DE EJECUCION:
		EXEC [SONDA].[SWIFT_SP_VALIDATE_USER_TO_PRESALE]
			@LOGIN = 'RUDI@SONDA'
		--
		EXEC [SONDA].[SWIFT_SP_VALIDATE_USER_TO_PRESALE]
			@LOGIN = 'oper2@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_USER_TO_PRESALE]
		@LOGIN VARCHAR(50)
AS
BEGIN TRY
	DECLARE 
		@CODE_ROUTE VARCHAR(50)
		,@RESULT INT = 0
		,@MESSAGE VARCHAR(500) = ''

	-- ------------------------------------------------------------------------------------
	-- Obtiene la ruta del usuario
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @CODE_ROUTE = U.SELLER_ROUTE
	FROM [SONDA].USERS U
	WHERE U.[LOGIN] = @LOGIN

	-- ------------------------------------------------------------------------------------
	-- Valida si tiene documentos de preventa
	-- ------------------------------------------------------------------------------------
	SELECT @RESULT = [SONDA].[SWIFT_FUNC_VALIDATE_DOCUMENT_PRESALE](@CODE_ROUTE)
	--
	IF @RESULT = 0
	BEGIN
		SET @MESSAGE= 'No tiene documentos de ordenes de venta'
	END
	
	-- ------------------------------------------------------------------------------------
	-- Valida si tiene bodega de preventa
	-- ------------------------------------------------------------------------------------
	SELECT @RESULT = [SONDA].[SWIFT_FUNC_VALIDATE_ROUTE_WH_PRESALE](@CODE_ROUTE)
	--
	IF @RESULT = 0
	BEGIN
		IF @MESSAGE = ''
		BEGIN
			SET @MESSAGE = 'No tiene bodega asignada de Preventa'			
		END
		ELSE
		BEGIN
			SET @MESSAGE= @MESSAGE + ' y no tiene bodega asignada de Preventa'
		END
	END

	IF @MESSAGE = ''
	BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END
	ELSE
	BEGIN
		SELECT  0 as Resultado , @MESSAGE Mensaje ,  0 Codigo, '0' DbData
	END
	--
	IF @@error != 0 
	BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
