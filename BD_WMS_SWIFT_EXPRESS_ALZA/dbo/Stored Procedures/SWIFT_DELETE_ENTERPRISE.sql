﻿create PROCEDURE [dbo].[SWIFT_DELETE_ENTERPRISE]
@ENTERPRISE INT
AS
DELETE dbo.SWIFT_ENTERPRISE WHERE ENTERPRISE=@ENTERPRISE
