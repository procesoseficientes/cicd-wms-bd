﻿CREATE PROC [SONDA].[SWIFT_GET_DELIVERY_COMPLIANCE]
@DTBEGIN DATE,
@DTEND DATE
AS
SELECT A.MANIFEST_HEADER, (SELECT COUNT(J.CODE_PICKING) FROM [SONDA].SWIFT_MANIFEST_DETAIL J WHERE J.CODE_MANIFEST_HEADER = A.MANIFEST_HEADER 
) AS 'CANTIDAD_PEDIDOS', A.CREATED_DATE, A.ACCEPTED_STAMP,A.LAST_UPDATE,A.COMPLETED_STAMP, B.NAME_DRIVER, c.NAME_ROUTE
 FROM [SONDA].SWIFT_MANIFEST_HEADER A, [SONDA].SWIFT_DRIVERS B, [SONDA].SWIFT_ROUTES C
 
 WHERE B.CODE_DRIVER = A.CODE_DRIVER AND C.CODE_ROUTE = A.CODE_ROUTE

 AND CONVERT(DATE,@DTBEGIN) >= CONVERT(DATE,A.CREATED_DATE) AND CONVERT(DATE,@DTEND) <= CONVERT(DATE,A.CREATED_DATE)
   ORDER BY A.MANIFEST_HEADER ASC
