﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_HEADER_INCOME]

@CLASSIFICATIONINCOME VARCHAR(50),

@CODEPROVIDER VARCHAR(50),

@CODEOPERATOR VARCHAR(50),

@REFERENCE VARCHAR(50),

@DOC_SAP_RECEPTION VARCHAR(150),

@LASTUPDATEBY VARCHAR(50)

AS

 

INSERT INTO SWIFT_RECEPTION_HEADER(TYPE_RECEPTION,CODE_PROVIDER,CODE_USER,REFERENCE,DOC_SAP_RECEPTION,LAST_UPDATE_BY,STATUS,LAST_UPDATE)

VALUES(@CLASSIFICATIONINCOME,@CODEPROVIDER,@CODEOPERATOR,@REFERENCE,@DOC_SAP_RECEPTION,@LASTUPDATEBY,'ASSIGNED',GETDATE())
