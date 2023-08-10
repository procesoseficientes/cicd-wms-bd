-- =============================================
-- Author:         diego.as
-- Create date:    15-02-2016
-- Description:    Inserta registros en la Tabla 
--				   [SONDA].[SONDA_PACK_UNIT]
--				   con transacción y control de errores.

/*
Ejemplo de Ejecucion:

		EXEC [SONDA].[SONDA_SP_INSERT_PACK_CONVERSION]
			@CODE_SKU = '100020'
			,@CODE_PACK_UNIT_FROM = 'CAJAS'
			,@CODE_PACK_UNIT_TO = 'PAQUETES'
			,@CONVERSION_FACTOR = 12
			,@LAST_UPDATE_BY = 'oper1@SONDA'
		----------------------------------------------
		SELECT * FROM [SONDA].[SONDA_PACK_CONVERSION]
		
				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_PACK_CONVERSION]
(
	@CODE_SKU VARCHAR(50)
	,@CODE_PACK_UNIT_FROM  VARCHAR(25)
	,@CODE_PACK_UNIT_TO VARCHAR(25)
	,@CONVERSION_FACTOR NUMERIC(18,6)
	,@LAST_UPDATE_BY VARCHAR(25)
)
AS
BEGIN
    SET NOCOUNT ON;
	--
	DECLARE	@ID INT

    BEGIN TRAN TransAdd
    BEGIN TRY
		
		INSERT INTO [SONDA].[SONDA_PACK_CONVERSION](
			[CODE_SKU]
			,[CODE_PACK_UNIT_FROM]
			,[CODE_PACK_UNIT_TO]
			,[CONVERSION_FACTOR]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			)
		VALUES(
			@CODE_SKU
			,@CODE_PACK_UNIT_FROM
			,@CODE_PACK_UNIT_TO
			,@CONVERSION_FACTOR
			,GETDATE()
			,@LAST_UPDATE_BY
			)
		--
		SET @ID = SCOPE_IDENTITY()
		--
        COMMIT TRAN TransAdd

		SELECT @ID AS ID
    END TRY
    BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
    END CATCH
END
