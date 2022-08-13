-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Inserta registros en la Tabla 
--                   [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] 
--                   con transacción y control de errores.
/*
Ejemplo de Ejecucion:
                --
                EXEC [wms].OP_WMS_SP_INSERT_CERTIFICATE_DEPOSIT_DETAIL 
                    @ID_DEPOSIT_HEADER = 1
                    ,@DOC_ID = 49231
                    ,@MATERIAL_CODE = '96000988'
                    ,@SKU_DESCRIPTION = 'NARROW CHISEL 600MM'
                    ,@LOCATIONS = 'RACK G'
                    ,@BULTOS = 105
                    ,@QTY = 540.06
                    ,@CUSTOM_AMOUNT = 56706.30
                SELECT * FROM [[wms]].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL]
                --    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_CERTIFICATE_DEPOSIT_DETAIL] (
		@ID_DEPOSIT_HEADER AS INT
		,@DOC_ID NUMERIC
		,@MATERIAL_CODE VARCHAR(50)
		,@SKU_DESCRIPTION VARCHAR(200)
		,@LOCATIONS VARCHAR(200)
		,@BULTOS NUMERIC(18, 0)
		,@QTY NUMERIC(18, 3)
		,@CUSTOM_AMOUNT NUMERIC(18, 2)
	)
AS
BEGIN
	SET NOCOUNT ON;
    --
	DECLARE	@ID INT;
	BEGIN TRAN [TransAdd];
	BEGIN TRY
		INSERT	INTO [wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL]
				(
					[CERTIFICATE_DEPOSIT_ID_HEADER]
					,[DOC_ID]
					,[MATERIAL_CODE]
					,[SKU_DESCRIPTION]
					,[LOCATIONS]
					,[BULTOS]
					,[QTY]
					,[CUSTOMS_AMOUNT]
				)
		VALUES
				(
					@ID_DEPOSIT_HEADER
					,@DOC_ID
					,@MATERIAL_CODE
					,@SKU_DESCRIPTION
					,@LOCATIONS
					,@BULTOS
					,@QTY
					,@CUSTOM_AMOUNT
				);
        --
		SET @ID = SCOPE_IDENTITY();
        --
		COMMIT TRAN [TransAdd];
        --
		SELECT
			@ID AS [ID];
	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@ERROR VARCHAR(1000)= ERROR_MESSAGE();
		RAISERROR (@ERROR,16,1);
	END CATCH;
END;