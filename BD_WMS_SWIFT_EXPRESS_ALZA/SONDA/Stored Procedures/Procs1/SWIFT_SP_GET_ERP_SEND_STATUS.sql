﻿CREATE PROC [SONDA].[SWIFT_SP_GET_ERP_SEND_STATUS]
@DTBEGIN DATETIME,
@DTEND DATETIME
AS
SELECT * FROM [SONDA].[SWIFT_VIEW_ERP_SEND_STATUS]
 WHERE SAP_REFERENCE IS NOT NULL
 AND CONVERT(DATE,@DTBEGIN) >= CONVERT(DATE,DOCUMENT_DATE) AND CONVERT(DATE,@DTEND) <= CONVERT(DATE,DOCUMENT_DATE)
