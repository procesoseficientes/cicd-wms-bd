﻿
CREATE PROCEDURE [dbo].[SWIFT_SP_GETUSEREXTERAL_FOR_CORRELATIVE]
@CORRELATIVE INT
AS
SELECT * FROM dbo.SWIFT_EXTERNAL_USER WHERE CORRELATIVE=@CORRELATIVE
