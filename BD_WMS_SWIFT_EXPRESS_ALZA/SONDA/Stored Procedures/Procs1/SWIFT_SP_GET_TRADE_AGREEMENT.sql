-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			    SP que obtiene todos los acuerdos comerciales o uno en especifico

-- Modificacion 12-09-2016 @ A-TEAM Sprint 1
						-- alberto.ruiz
						-- Se agrego columna de LINKED_TO

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 2
				--
				EXEC [SONDA].SWIFT_SP_GET_TRADE_AGREEMENT
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT = NULL)
AS
BEGIN
  SELECT

    TRADE_AGREEMENT_ID
   ,CODE_TRADE_AGREEMENT
   ,NAME_TRADE_AGREEMENT
   ,DESCRIPTION_TRADE_AGREEMENT
   ,VALID_START_DATETIME
   ,VALID_END_DATETIME
   ,STATUS
   ,CASE STATUS
      WHEN 1 THEN 'ACTIVO'
      ELSE 'INACTIVO'
    END AS STATUS_DESCRIPTION
   ,LAST_UPDATE
   ,LAST_UPDATE_BY
   ,CASE LINKED_TO
		WHEN 'CHANNEL' THEN 'CANAL'
		WHEN 'CUSTOMER' THEN 'CLIENTE'
	END AS LINKED_TO
  FROM [SONDA].SWIFT_TRADE_AGREEMENT
  WHERE @TRADE_AGREEMENT_ID IS NULL
  OR TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
END
