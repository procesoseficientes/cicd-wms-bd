﻿CREATE PROC [SONDA].[SWIFT_SP_INSERTPROVIDER]
@CODE_PROVIDER VARCHAR(50),
@NAME_PROVIDER VARCHAR(50),
@CLASSIFICATION_PROVIDER VARCHAR(50),
@CONTACT_PROVIDER VARCHAR(50),
@LAST_UPDATE VARCHAR(50),
@LAST_UPDATE_BY VARCHAR(50)
AS
INSERT INTO SWIFT_PROVIDERS (CODE_PROVIDER,NAME_PROVIDER,CLASSIFICATION_PROVIDER,
CONTACT_PROVIDER,LAST_UPDATE,LAST_UPDATE_BY) VALUES (@CODE_PROVIDER,
@NAME_PROVIDER,
@CLASSIFICATION_PROVIDER,
@CONTACT_PROVIDER,
GETDATE(),
@LAST_UPDATE_BY)
