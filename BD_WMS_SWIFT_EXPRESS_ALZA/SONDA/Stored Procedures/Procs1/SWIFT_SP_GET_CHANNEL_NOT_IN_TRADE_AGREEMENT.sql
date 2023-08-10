-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que obtiene todos los canales que no estan asociados a ningun acuerdo comercial

-- Modificacion:				rudi.garcia
-- Fecha de Creacion: 	25-07-2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			    Se agrego el parametro y la condicion de @TRADE_AGREEMENT_ID

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_CHANNEL_NOT_IN_TRADE_AGREEMENT 
						@TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CHANNEL_NOT_IN_TRADE_AGREEMENT(
  @TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	DECLARE @TYPE_CHANNEL VARCHAR(50) 
	--
	SET @TYPE_CHANNEL = [SONDA].SWIFT_FN_GET_PARAMETER('TRADE_AGREEMENT','CHANNEL_FOR_TRADE_AGREEMENT')
	--
	SELECT
		C.CHANNEL_ID
		,C.CODE_CHANNEL
		,C.NAME_CHANNEL
		,C.DESCRIPTION_CHANNEL
		,C.TYPE_CHANNEL
		,(CASE WHEN TAC.CHANNEL_ID IS NULL THEN 'NO ASIGNADO' ELSE 'ASIGNADO' END) AS [STATUS]
	FROM [SONDA].SWIFT_CHANNEL C
	LEFT JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL TAC ON (
		C.CHANNEL_ID = TAC.CHANNEL_ID
	)
	WHERE C.TYPE_CHANNEL = @TYPE_CHANNEL
  AND ([TAC].[TRADE_AGREEMENT_ID] IS NULL OR [TAC].[TRADE_AGREEMENT_ID] <> @TRADE_AGREEMENT_ID)
END
