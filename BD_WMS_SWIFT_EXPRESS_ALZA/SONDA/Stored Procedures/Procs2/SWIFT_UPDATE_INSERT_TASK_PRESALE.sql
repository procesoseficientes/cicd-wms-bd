﻿CREATE PROC [SONDA].SWIFT_UPDATE_INSERT_TASK_PRESALE
@CODE_CUSTOMER VARCHAR(25),
@NAME_CUSTOMER VARCHAR(100),
@ASSIGNED_TO VARCHAR(25),
@TASK_COMMENTS VARCHAR(150),
@VISIT_HOUR DATETIME,
@SCHEDULE_FOR DATETIME,
@PRIORITY INT,
@pResult VARCHAR(200) OUTPUT
AS
SET @pResult = @ASSIGNED_TO
DECLARE @USER_ROLE VARCHAR(50)
SET @USER_ROLE = (SELECT [USER_TYPE] FROM [SONDA].USERS WHERE RELATED_SELLER = (SELECT SELLER_CODE FROM  [SONDA].[SWIFT_VIEW_SELLER_LOGIN] WHERE [LOGIN] = @ASSIGNED_TO))--(SELECT SELLER_CODE FROM [SONDA].SWIFT_VIEW_ALL_SELLERS WHERE SELLER_NAME = (SELECT DISTINCT SELLER_DEFAULT_CODE FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER WHERE CODE_CUSTOMER = @CODE_CUSTOMER)))
MERGE [SONDA].SWIFT_TASKS TRG
	USING (SELECT @CODE_CUSTOMER AS COSTUMER_CODE) AS SRC
	ON TRG.COSTUMER_CODE = SRC.COSTUMER_CODE 
		AND TRG.TASK_STATUS != 'CLOSED' 
		AND TRG.[ACTION] != 'CLOSED' 
		AND TRG.SCHEDULE_FOR = @SCHEDULE_FOR 
		AND (TRG.TASK_TYPE = 'PRESALE' OR TRG.TASK_TYPE = 'SALE')
		AND TRG.TASK_TYPE = CASE 
            WHEN @USER_ROLE = 'PRE'
               THEN 'PRESALE'
            WHEN @USER_ROLE = 'VEN'
               THEN 'SALE'
		END 
WHEN MATCHED THEN 
	UPDATE SET
		@pResult = TRG.ASSIGEND_TO,
		TRG.ASSIGEND_TO= @ASSIGNED_TO,
		TRG.TASK_COMMENTS = @TASK_COMMENTS,
		TRG.VISIT_HOUR = @VISIT_HOUR,
		TRG.TASK_SEQ = @PRIORITY ,
		TRG.TASK_TYPE = 
		CASE 
            WHEN @USER_ROLE = 'PRE'
               THEN 'PRESALE'
            WHEN @USER_ROLE = 'VEN'
               THEN 'SALE'
		END 
WHEN NOT MATCHED THEN 
	INSERT (
	COSTUMER_CODE,
	COSTUMER_NAME,
	CUSTOMER_PHONE,
	SCHEDULE_FOR,
	TASK_ADDRESS,
	ASSIGEND_TO,
	TASK_STATUS,
	TASK_SEQ,
	EXPECTED_GPS,
	EMAIL_TO_CONFIRM,
	--POSTED_GPS,
	TASK_COMMENTS,
	TASK_TYPE,
	VISIT_HOUR,
	CREATED_STAMP,
	ASSIGNED_STAMP,
	TASK_DATE,
	ASSIGNED_BY,
	[ACTION],
	ROUTE_IS_COMPLETED)
	
	VALUES (
	@CODE_CUSTOMER,
	@NAME_CUSTOMER,
	ISNULL((SELECT TOP 1 PHONE FROM SWIFT_BRANCHES WHERE CUSTOMER_CODE = @CODE_CUSTOMER AND IS_DEFAULT = '1'),'N/A'),
	@SCHEDULE_FOR,
	--MODIFICAR
	ISNULL((SELECT TOP 1 BRANCH_ADDRESS FROM SWIFT_BRANCHES WHERE CUSTOMER_CODE = @CODE_CUSTOMER AND IS_DEFAULT = '1'),'N/A'),
	@ASSIGNED_TO,
	'ASSIGNED',
	@PRIORITY,
	'14.6489976,-90.5397622',--ISNULL((SELECT TOP 1 GPS_LAT_LON FROM SWIFT_BRANCHES WHERE CUSTOMER_CODE = @CODE_CUSTOMER AND IS_DEFAULT = '1'),'N/A'),
	ISNULL((SELECT TOP 1 DELIVERY_EMAIL FROM SWIFT_BRANCHES WHERE CUSTOMER_CODE = @CODE_CUSTOMER AND IS_DEFAULT = '1'),'N/A'),
	--ISNULL((SELECT TOP 1 DELIVERY_EMAIL FROM profisa.SONDA_BRANCHES WHERE CLIENT_CODE = @CLIENT_CODE AND IS_DEFAULT = 1),'n/a'),
	--ISNULL((SELECT TOP 1 GPS_LAT_LON FROM profisa.SONDA_BRANCHES WHERE CLIENT_CODE = @CLIENT_CODE AND IS_DEFAULT = 1),'0,0'),
	@TASK_COMMENTS,
	CASE 
            WHEN @USER_ROLE = 'PRE'
               THEN 'PRESALE'
            WHEN @USER_ROLE = 'VEN'
               THEN 'SALE'
	END ,
	@VISIT_HOUR,
	GETDATE(),
	@SCHEDULE_FOR,
	GETDATE(),
	'SYS',
	'PLAY',
	0
	);
