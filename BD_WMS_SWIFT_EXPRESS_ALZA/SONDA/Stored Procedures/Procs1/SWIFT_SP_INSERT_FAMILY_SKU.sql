-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Inserta en la Tabla [SONDA].[SWIFT_FAMILY_SKU] para almacenar
--					las FAMILIAS de PRODUCTOS.
/*
Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_INSERT_FAMILY_SKU]
			@CODE_FAMILY_SKU = 1
			,@DESCRIPTION_FAMILY_SKU = 'EJEMPLO'
			,@ORDER = 1
			,@LAST_UPDATE_BY = 'oper1@SONDA'
		-----------------------------------------
		SELECT * FROM [SONDA].[SWIFT_FAMILY_SKU]
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_FAMILY_SKU]
(
	@CODE_FAMILY_SKU VARCHAR(50)
	,@DESCRIPTION_FAMILY_SKU VARCHAR(250)
	,@ORDER INT
	,@LAST_UPDATE_BY VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID INT;

	BEGIN TRAN AddTrans
	BEGIN TRY
	
		INSERT INTO [SONDA].[SWIFT_FAMILY_SKU](
				[CODE_FAMILY_SKU]
				,[DESCRIPTION_FAMILY_SKU]
				,[ORDER]
				,[LAST_UPDATE]
				,[LAST_UPDATE_BY]
				)
		VALUES (
			@CODE_FAMILY_SKU
			,@DESCRIPTION_FAMILY_SKU
			,@ORDER
			,GETDATE()
			,@LAST_UPDATE_BY
		)

	SET @ID = SCOPE_IDENTITY()
	COMMIT TRAN AddTrans
	END TRY
	
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
	
		
END
