
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
CREATE FUNCTION [wms].[OP_WMS_FUNC_TIMEDELAY] 
(
	@pINITIAL_DATE	DATETIME,
	@pFINISHED_DATE	DATETIME
)
RETURNS varchar(75)
AS
BEGIN
	DECLARE @TIMEDELAY varchar(5000)
	
	SELECT @TIMEDELAY =
    + CAST(DATEDIFF(second, @pINITIAL_DATE, @pFINISHED_DATE) / 60 / 60 / 24 % 7 AS NVARCHAR(50)) 
    + ':'+ CAST(DATEDIFF(second, @pINITIAL_DATE, @pFINISHED_DATE) / 60 / 60 % 24  AS NVARCHAR(50))
    + ':'+ CAST(DATEDIFF(second, @pINITIAL_DATE, @pFINISHED_DATE) / 60 % 60 AS NVARCHAR(50))
    + ':'+ CAST(DATEDIFF(second, @pINITIAL_DATE, @pFINISHED_DATE) % 60 AS NVARCHAR(50));
	
	RETURN @TIMEDELAY

END

--GO