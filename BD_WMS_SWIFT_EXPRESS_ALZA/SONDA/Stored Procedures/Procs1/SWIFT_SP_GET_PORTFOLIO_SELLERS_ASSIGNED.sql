﻿CREATE PROC [SONDA].[SWIFT_SP_GET_PORTFOLIO_SELLERS_ASSIGNED]
	@CODE_PORTFOLIO VARCHAR(50)
AS	
	SELECT S.*
	FROM [SONDA].SWIFT_VIEW_PORTFOLIO_BY_SELLER 
		INNER JOIN [SONDA].SWIFT_VIEW_ALL_SELLERS S ON SELLER_CODE = CODE_SELLER
	WHERE CODE_PORTFOLIO = @CODE_PORTFOLIO
