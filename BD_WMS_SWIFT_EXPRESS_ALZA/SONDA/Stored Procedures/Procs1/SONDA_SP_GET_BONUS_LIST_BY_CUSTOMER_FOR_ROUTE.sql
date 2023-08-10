-- =====================================================
-- Author:         rudi.garcia
-- Create date:    19-08-2016
-- Description:    Trae las listas de bonificacion de los clientes  
--				   de las tareas asignadas al dia de trabajo
			   
-- Modificacion 20-09-2016 @ A-TEAM Sprint 1
	-- alberto.ruiz
	-- Se agrego que genere las bonificaciones de la ruta

-- Modificacion 19-Oct-16 @ A-Team Sprint 3
					-- alberto.ruiz
					-- Se agrego llamada al SP para generar descuentos desde acuerdo comercial
/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_CUSTOMER_FOR_ROUTE]
			@CODE_ROUTE = 'RUDI@SONDA'
		
*/			
-- =====================================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_BONUS_LIST_BY_CUSTOMER_FOR_ROUTE] (
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @GENERATE_BONUS_LIST_FROM_TRADE_AGREEMENT VARCHAR(250)
	--
	SELECT @GENERATE_BONUS_LIST_FROM_TRADE_AGREEMENT = [SONDA].[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES','GENERATE_BONUS_LIST_FROM_TRADE_AGREEMENT')
	
	-- ------------------------------------------------------------------------------------
	-- Valida si tiene que generarce los descuentos desde los acuerdos comerciales
	-- ------------------------------------------------------------------------------------
	IF @GENERATE_BONUS_LIST_FROM_TRADE_AGREEMENT = '1'
	BEGIN
		EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT]
			@CODE_ROUTE = @CODE_ROUTE
	END
	--
	SELECT
		BLC.BONUS_LIST_ID
		,BLC.CODE_CUSTOMER 
	FROM [SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER BLC
	INNER JOIN [SONDA].SWIFT_BONUS_LIST BL ON(
		BL.BONUS_LIST_ID = BLC.BONUS_LIST_ID
	)
	WHERE BL.NAME_BONUS_LIST LIKE (@CODE_ROUTE + '%')
END
