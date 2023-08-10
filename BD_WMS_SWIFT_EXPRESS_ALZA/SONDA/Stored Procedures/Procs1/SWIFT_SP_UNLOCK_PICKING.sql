﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_UNLOCK_PICKING]
@PICKING_HEADER INT,
@ERP_DOC VARCHAR(50),
@STATUS VARCHAR(20)
AS

IF @STATUS = 'UNLOCKED'
BEGIN
UPDATE [SONDA].SWIFT_PICKING_HEADER SET [STATUS]=@STATUS
WHERE PICKING_HEADER = @PICKING_HEADER

END
IF @STATUS = 'CLOSED'
BEGIN

UPDATE [SONDA].[SWIFT_TXNS] SET [SAP_REFERENCE] = @ERP_DOC, [TXN_IS_POSTED_ERP] = 0 WHERE [SAP_REFERENCE] = 
(SELECT [DOC_SAP_RECEPTION] FROM [SONDA].[SWIFT_PICKING_HEADER] WHERE [PICKING_HEADER] = @PICKING_HEADER)

UPDATE [SONDA].SWIFT_PICKING_HEADER SET [STATUS]=@STATUS, [DOC_SAP_RECEPTION] = @ERP_DOC
WHERE PICKING_HEADER = @PICKING_HEADER
END
