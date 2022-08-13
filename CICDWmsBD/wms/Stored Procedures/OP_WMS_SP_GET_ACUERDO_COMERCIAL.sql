-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 4
-- Description:			    SP que obtiene el acuerdo comercia

/*
-- Ejemplo de Ejecucion:
        DECLARE @pResult VARCHAR(250) = ''
		--
		EXEC [wms].[OP_WMS_SP_GET_ACUERDO_COMERCIAL]
			@AcuerdoComercialId = 12
			,@pResult = @pResult OUTPUT
		--
		SELECT @pResult [pResult]
		--
		SELECT * FROM  [wms].[OP_WMS_TARIFICADOR_HEADER] WHERE [ACUERDO_COMERCIAL_ID] = 12
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ACUERDO_COMERCIAL] (
  @pClientId VARCHAR(50)
	,@AcuerdoComercialId INT
	,@pResult VARCHAR(250) OUTPUT
)AS
BEGIN
	SET NOCOUNT ON;	
	--
	BEGIN
		SELECT
			[ACUERDO_COMERCIAL_NOMBRE] AS [Nombre]
			,[VALID_FROM] AS [FechaInicio]
			,[VALID_TO] AS [FechaFinal]
			,[th].[CURRENCY] AS [Moneda]
			,[STATUS] AS [Estado]
			,[th].[WAREHOUSE_WEATHER] AS [Clima]
			,[th].[REGIMEN] AS [Regimen]
			,[LOGIN_NAME] AS [Autorizador]
			,[c].[CLIENT_NAME] AS [Cliente]
			,[th].[COMMENTS] AS [ComentarioEnc]
			,[DESCRIPTION] AS [TipoCobro]
			,[UNIT_PRICE] AS [PrecioUnitario]
			,[BILLING_FRECUENCY] AS [Frecuencia]
			,[LIMIT_TO] AS [Limite]
			,[U_MEASURE] AS [Medida]
			,[TX_SOURCE] AS [Transaccion]
			,[td].[COMMENTS] AS [ComentarioDet]
		FROM [wms].[OP_WMS_TARIFICADOR_HEADER] [th]
		INNER JOIN [wms].[OP_WMS_TARIFICADOR_DETAIL] [td]ON	(
			[th].[ACUERDO_COMERCIAL_ID] = [ACUERDO_COMERCIAL]
		)
		INNER JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [ac] ON (
			[th].[ACUERDO_COMERCIAL_ID] = [ac].[ACUERDO_COMERCIAL]
		)
		INNER JOIN [wms].[OP_WMS_TYPE_CHARGE] [tc] ON (
			[tc].[TYPE_CHARGE_ID] = [td].[TYPE_CHARGE_ID]
		)
		INNER JOIN [wms].[OP_WMS_LOGINS] [l] ON (
			[th].[AUTHORIZER] = [l].[LOGIN_ID]
		)
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [c] ON (
			[ac].[CLIENT_ID] = [c].[CLIENT_CODE] COLLATE DATABASE_DEFAULT
		)
		WHERE [th].[ACUERDO_COMERCIAL_ID] = @AcuerdoComercialId
    AND [ac].[CLIENT_ID] = @pClientId;
	END;	
	IF @@ERROR = 0
	BEGIN
		SELECT
			@pResult = 'OK';
	END;
	ELSE
	BEGIN
		SELECT
			@pResult = ERROR_MESSAGE();
	END;
		
END;