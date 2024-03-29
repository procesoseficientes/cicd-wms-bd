﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_BARCODE_SCANNED]
@BARCODE	VARCHAR(75),
@SERVICE_ID	VARCHAR(50)
AS
	DECLARE @lBARCODE VARCHAR(75);
	
	--SELECT @lBARCODE = UPPER(REPLACE(@BARCODE,' ',''));
	
	SELECT @lBARCODE = UPPER(@BARCODE);
	
	IF @SERVICE_ID = 'GET_SKU_INFO' BEGIN
		SELECT * FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @lBARCODE OR BARCODE_SKU = @lBARCODE)
		IF(@@ROWCOUNT >= 1) BEGIN
			RETURN 0;
		END 
		ELSE RETURN -1;
	END
	IF @SERVICE_ID = 'GET_LOCATION_INFO' BEGIN
		SELECT * FROM SWIFT_LOCATIONS WHERE CODE_LOCATION = @lBARCODE
		IF(@@ROWCOUNT >= 1) BEGIN
			RETURN 0;
		END 
		ELSE RETURN -1;
	END
	IF @SERVICE_ID = 'GET_LOCATION_INVENTORY' BEGIN
		SELECT * FROM SWIFT_INVENTORY WHERE LOCATION = @lBARCODE
		IF(@@ROWCOUNT >= 1) BEGIN
			RETURN 0;
		END 
		ELSE RETURN -1;
	END
	IF @SERVICE_ID = 'GET_SKU_INVENTORY' BEGIN
		SELECT * FROM SWIFT_INVENTORY WHERE SKU = (SELECT TOP 1 CODE_SKU FROM SWIFT_VIEW_SKU  WHERE CODE_SKU = @lBARCODE OR BARCODE_SKU = @lBARCODE)
		IF(@@ROWCOUNT >= 1) BEGIN
			RETURN 0;
		END 
		ELSE RETURN -1;
	END
	IF @SERVICE_ID = 'GET_BATCH_INVENTORY' BEGIN
		SELECT * FROM SWIFT_INVENTORY WHERE BATCH_ID = @lBARCODE
		IF(@@ROWCOUNT >= 1) BEGIN
			RETURN 0;
		END 
		ELSE RETURN -1;
	END
