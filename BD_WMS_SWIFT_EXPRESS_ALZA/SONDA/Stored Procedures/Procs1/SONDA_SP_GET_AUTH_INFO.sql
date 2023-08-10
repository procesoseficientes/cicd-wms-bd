-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-03-2016
-- Description:			Obtiene la informacion de la resolucion de una ruta

-- Modificacion: 15-07-2016 Sprint ζ
		-- Autor: diego.as
		-- Descripcion: Se agregaron columnas 
						--BRANCH_ADDRESS2
						--BRANCH_ADDRESS3
						--BRANCH_ADDRESS4
						--NIT_ENTERPRISE

-- Modificacion 6/20/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se agrega la columna E.ENTERPRISE_EMAIL_ADDRESS

-- Modificacion 11/17/2017 @ Reborn - Team Sprint Eberhard
					-- diego.as
					-- Se agrega validacion para ver si factura en ruta o no

/*
-- Ejemplo de Ejecucion:
		-- 
		EXEC [SONDA].[SONDA_SP_GET_AUTH_INFO]
			@AUTH_ASSIGNED_TO = '46'
			,@AUTH_DOC_TYPE = 'FACTURA'
			,@AUTH_STATUS = '1'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_AUTH_INFO]
(	
	@AUTH_ASSIGNED_TO VARCHAR(100)
	,@AUTH_DOC_TYPE VARCHAR(100)
	,@AUTH_STATUS VARCHAR(10)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INVOICE_IN_ROUTE INT = NULL;

	SELECT @INVOICE_IN_ROUTE = [SONDA].[SWIFT_FN_GET_PARAMETER]('DELIVERY','INVOICE_IN_ROUTE');
	
	
	IF (@INVOICE_IN_ROUTE IS NULL) BEGIN
		EXEC [SONDA].[SONDA_SP_GET_COMPLETE_AUTHORIZATION_INFO]
			@AUTH_ASSIGNED_TO = @AUTH_ASSIGNED_TO
			,@AUTH_DOC_TYPE = @AUTH_DOC_TYPE
			,@AUTH_STATUS = @AUTH_STATUS
			,@INVOICE_IN_ROUTE = 1
	END
	
	
	IF(@INVOICE_IN_ROUTE = 1) BEGIN
		EXEC [SONDA].[SONDA_SP_GET_COMPLETE_AUTHORIZATION_INFO]
			@AUTH_ASSIGNED_TO = @AUTH_ASSIGNED_TO
			,@AUTH_DOC_TYPE = @AUTH_DOC_TYPE
			,@AUTH_STATUS = @AUTH_STATUS
			,@INVOICE_IN_ROUTE = @INVOICE_IN_ROUTE
	END

	
	IF(@INVOICE_IN_ROUTE = 0) BEGIN
		EXEC [SONDA].[SONDA_SP_GET_BRANCH_INFO]
				@AUTH_ASSIGNED_TO = @AUTH_ASSIGNED_TO
				,@INVOICE_IN_ROUTE = @INVOICE_IN_ROUTE
	END
	
END
