﻿
CREATE PROC [SONDA].[SWIFT_SP_UPDATELOCATION]
@CODE_LOCATION [varchar](50),
@CODE_WAREHOUSE VARCHAR(50),
@CLASSIFICATION_LOCATION VARCHAR(50),
@HALL_LOCATION VARCHAR(30),
@ALLOW_PICKING VARCHAR(5),
@LAST_UPDATE VARCHAR(50),
@LAST_UPDATE_BY VARCHAR(50),
@BARCODE_LOCATION VARCHAR(50),
@DESCRIPTION_LOCATION VARCHAR(MAX),
@RACK_LOCATION VARCHAR(30),
@COLUMN_LOCATION VARCHAR(30),
@LEVEL_LOCATION VARCHAR(30),
@SQUARE_METER_LOCATION numeric(6, 0),
@FLOOR_LOCATION varchar(5),
@ALLOW_STORAGE varchar(5),
@ALLOW_RELOCATION varchar(5),
@STATUS_LOCATION varchar(10)
AS


BEGIN TRY	


	UPDATE SWIFT_LOCATIONS SET CODE_WAREHOUSE = @CODE_WAREHOUSE,CLASSIFICATION_LOCATION=@CLASSIFICATION_LOCATION,
	HALL_LOCATION=@HALL_LOCATION,ALLOW_PICKING=@ALLOW_PICKING,LAST_UPDATE=GETDATE(),LAST_UPDATE_BY=@LAST_UPDATE_BY,
	BARCODE_LOCATION=@BARCODE_LOCATION,DESCRIPTION_LOCATION=@DESCRIPTION_LOCATION,RACK_LOCATION=@RACK_LOCATION,
	COLUMN_LOCATION=@COLUMN_LOCATION,LEVEL_LOCATION=@LEVEL_LOCATION,SQUARE_METER_LOCATION=@SQUARE_METER_LOCATION,
	FLOOR_LOCATION=@FLOOR_LOCATION,ALLOW_STORAGE=@ALLOW_STORAGE,ALLOW_RELOCATION=@ALLOW_RELOCATION,STATUS_LOCATION=@STATUS_LOCATION
	WHERE [CODE_LOCATION] = @CODE_LOCATION


	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= 'ERROR: verifique que los datos de barcode y el ID no esten repetidos.'
		RAISERROR (@ERROR,16,1)
	END CATCH