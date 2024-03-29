﻿-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	05-10-16 @ A-TEAM Sprint 2
-- Description:			Obtener propueste de frecuencia de un cliente asociado a un poligno

-- Modificacion 2/27/2017 @ A-Team Sprint Donkor
					-- rodrigo.gomez
					-- Se agrego la columna TYPE_TASK
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PROPOSAL_FROM_FREQUENCY_BY_POLYGON]
					@POLYGON_ID = 1111
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_PROPOSAL_FROM_FREQUENCY_BY_POLYGON(
	@POLYGON_ID INT
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @TASK_TYPE VARCHAR(1000) = ''
--
SELECT	
	@TASK_TYPE = CASE WHEN @TASK_TYPE = '' THEN [TASK_TYPE] ELSE @TASK_TYPE + '|' + [TASK_TYPE] END
	 FROM [SONDA].[SWIFT_TASK_BY_POLYGON]
	 WHERE [POLYGON_ID] = @POLYGON_ID
--
  SELECT TOP 1 
    CONVERT(INT, CF.SUNDAY) SUNDAY
    ,CONVERT(INT,CF.MONDAY) MONDAY
    ,CONVERT(INT, CF.TUESDAY) TUESDAY
    ,CONVERT(INT, CF.WEDNESDAY) WEDNESDAY
    ,CONVERT(INT, CF.THURSDAY) THURSDAY
    ,CONVERT(INT, CF.FRIDAY) FRIDAY
    ,CONVERT(INT, CF.SATURDAY) SATURDAY
    ,CONVERT(INT, CF.FREQUENCY_WEEKS) FREQUENCY_WEEKS
	,@TASK_TYPE TYPE_TASK
  FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY CF
  INNER JOIN [SONDA].SWIFT_POLYGON_X_CUSTOMER PC ON (
    PC.CODE_CUSTOMER = CF.CODE_CUSTOMER
  )
  WHERE PC.POLYGON_ID = @POLYGON_ID

END
