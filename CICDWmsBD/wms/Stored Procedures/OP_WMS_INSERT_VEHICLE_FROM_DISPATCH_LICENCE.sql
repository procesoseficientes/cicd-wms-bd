-- =============================================
-- Autor:               rudi.garcia 
-- Fecha de Creacion:   22-Jan-2019 G-Force@Quetal
-- Description:         SP que inserta EL vehicula desde el HH
/*
                                                    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_VEHICLE_FROM_DISPATCH_LICENCE] (
		@PLATE_NUMBER VARCHAR(10)
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@VEHICLE_CODE INT;

	BEGIN TRY;

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_VEHICLE] [V]
					WHERE
						[V].[PLATE_NUMBER] = @PLATE_NUMBER )
		BEGIN
			SELECT TOP 1
				@VEHICLE_CODE = [V].[VEHICLE_CODE]
			FROM
				[wms].[OP_WMS_VEHICLE] [V];
		END;
		ELSE
		BEGIN
			INSERT	[wms].[OP_WMS_VEHICLE]
					(
						[PLATE_NUMBER]
						,[RATING]
						,[IS_ACTIVE]
						,[STATUS]
						,[FILL_RATE]
					)
			VALUES
					(
						@PLATE_NUMBER
						,0
						,0
						,'DISPONIBLE'
						,0
					);

			SET @VEHICLE_CODE = SCOPE_IDENTITY();
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@VEHICLE_CODE AS VARCHAR(20)) [DbData];
	END TRY
	BEGIN CATCH

		DECLARE	@message VARCHAR(1000) = @@ERROR;
		PRINT @message;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];

		RAISERROR (@message, 16, 1);

	END CATCH;
END;
