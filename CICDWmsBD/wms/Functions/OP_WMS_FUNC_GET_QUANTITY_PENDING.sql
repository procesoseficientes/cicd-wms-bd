
--USE [OP_WMS]
--GO

--/****** Object:  UserDefinedFunction [wms].[OP_WMS_FUNC_CONSOL_TERMINAL_BYUSR]    Script Date: 06/02/2011 10:41:47 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


---- =============================================
---- Author:		<Author,,Name>
---- Create date: <Create Date, ,>
---- Description:	<Description, ,>
---- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_QUANTITY_PENDING] 
(
	@pQUANTITY_ASSIGNED NUMERIC(18,2),
	@pQTY_AVAILABLE NUMERIC(18,2)
)
RETURNS NUMERIC(18,0)
AS
BEGIN

	DECLARE @QUANTITY_PENDING NUMERIC(18,0)

	IF((@pQUANTITY_ASSIGNED > @pQTY_AVAILABLE))
		select @QUANTITY_PENDING = @pQTY_AVAILABLE
	ELSE
		select @QUANTITY_PENDING = @pQUANTITY_ASSIGNED
		
	RETURN @QUANTITY_PENDING

END

--GO