﻿CREATE PROC [SONDA].SWIFT_UPDATE_FREQUENCY_NEW
@MONDAY VARCHAR(2),
@TUESDAY VARCHAR(2),
@WEDNESDAY VARCHAR(2),
@THURSDAY VARCHAR(2),
@FRIDAY VARCHAR(2),
@SATURDAY VARCHAR(2),
@SUNDAY VARCHAR(2),
@CODE_CUSTOMER VARCHAR(100),
@FREQUENCY_WEEKS VARCHAR(2) = NULL,
@LAST_DATE_VISITED DATETIME = NULL
AS
MERGE [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW TRG
	USING (SELECT @CODE_CUSTOMER AS COSTUMER_CODE) AS SRC
	ON TRG.CODE_CUSTOMER = SRC.COSTUMER_CODE
WHEN MATCHED THEN 
	UPDATE SET 
		TRG.SUNDAY = @SUNDAY,
		TRG.MONDAY = @MONDAY,
		TRG.TUESDAY = @TUESDAY,
		TRG.WEDNESDAY = @WEDNESDAY,
		TRG.THURSDAY = @THURSDAY,
		TRG.FRIDAY = @FRIDAY,
		TRG.SATURDAY =  @SATURDAY,
		TRG.LAST_UPDATED =  CURRENT_TIMESTAMP,
		TRG.FREQUENCY_WEEKS = @FREQUENCY_WEEKS,
		TRG.LAST_DATE_VISITED = @LAST_DATE_VISITED
		
WHEN NOT MATCHED THEN 
	INSERT (
	CODE_CUSTOMER,
	SUNDAY,
	MONDAY,
	TUESDAY,
	WEDNESDAY,
	THURSDAY,
	FRIDAY,
	SATURDAY,
	LAST_UPDATED,
	FREQUENCY_WEEKS,
	LAST_DATE_VISITED
	)
	
	VALUES (
	@CODE_CUSTOMER,
	@SUNDAY,
	@MONDAY,
	@TUESDAY,
	@WEDNESDAY,
	@THURSDAY,
	@FRIDAY,
	@SATURDAY,
	CURRENT_TIMESTAMP,
	@FREQUENCY_WEEKS,
	@LAST_DATE_VISITED
	);
