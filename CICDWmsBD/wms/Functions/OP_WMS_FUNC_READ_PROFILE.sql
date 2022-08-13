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
CREATE FUNCTION [wms].[OP_WMS_FUNC_READ_PROFILE] 
(
	@pProfileModuleID varchar(25),
	@pProfileName varchar(100),
	@pUser varchar(30)	
)
RETURNS varchar(5000)
AS
BEGIN

	DECLARE @layout_id varchar(5000)

	select @layout_id = profile_layout_id FROM OP_WMS_MAIN_PROFILES where profile_module_id = @pProfileModuleID and profile_name = @pProfileName and profile_user = @pUser

	RETURN @layout_id

END

--GO