﻿CREATE PROCEDURE [SONDA].[SWIFT_INSERT_DETAIL_MANIFEST]
@CODE_MANIFEST_HEADER VARCHAR(50),
@CODE_PICKING VARCHAR(50),
@LAST_UPDATE_BY VARCHAR(50),
@CODE_COSTUMER VARCHAR(50),
@REFERENCE VARCHAR(50),
@DOC_SAP_PICKING VARCHAR(150),
@TYPE VARCHAR(20)
AS
BEGIN
	BEGIN TRAN t1
		BEGIN
			INSERT INTO SWIFT_MANIFEST_DETAIL
				(CODE_MANIFEST_HEADER,
				CODE_PICKING,
				LAST_UPDATE_BY,
				CODE_CUSTOMER,
				REFERENCE,
				DOC_SAP_PICKING,
				LAST_UPDATE,
				[TYPE])

			VALUES
				(@CODE_MANIFEST_HEADER,
				@CODE_PICKING,
				@LAST_UPDATE_BY,
				@CODE_COSTUMER,
				@REFERENCE,
				@DOC_SAP_PICKING,
				CURRENT_TIMESTAMP,
				@TYPE)
END	
	
		IF @@error = 0 BEGIN
			--SELECT @pResult = ''
			COMMIT TRAN t1
		END		
		ELSE BEGIN
			ROLLBACK TRAN t1
			--SELECT	@pResult	= ERROR_MESSAGE()
	END
END
