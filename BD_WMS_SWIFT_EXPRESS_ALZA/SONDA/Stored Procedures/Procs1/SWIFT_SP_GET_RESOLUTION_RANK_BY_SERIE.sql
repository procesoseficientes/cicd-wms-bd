﻿CREATE PROC [SONDA].[SWIFT_SP_GET_RESOLUTION_RANK_BY_SERIE]
	@AUTH_SERIE VARCHAR(100)
AS	
	SELECT ISNULL(MAX(AUTH_DOC_TO), 0) AS [RANK]
	FROM [SONDA].SONDA_POS_RES_SAT
	WHERE AUTH_SERIE = @AUTH_SERIE
