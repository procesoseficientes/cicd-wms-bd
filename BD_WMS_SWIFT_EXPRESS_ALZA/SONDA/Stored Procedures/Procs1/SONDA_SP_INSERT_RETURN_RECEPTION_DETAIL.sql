

-- =============================================
-- Author:         diego.as
-- Create date:    05-02-2016
-- Description:    Procedimiento para Insertar registros en la Tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_DETAIL 
--				   con transacción y control de errores.
/*
Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SONDA_SP_INSERT_RETURN_RECEPTION_DETAIL] 
				@ID_DOC_RETURN_HEADER = 1 
				,@CODE_SKU = '100020'
				,@QTY = 10
				,@DESCRIPTION_SKU = 'BATERIAS AAA 2PACK'

				SELECT * FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_DETAIL]
				--	
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_RETURN_RECEPTION_DETAIL]
(
	@ID_DOC_RETURN_HEADER AS INT
	,@CODE_SKU AS VARCHAR(50)
	,@QTY AS NUMERIC(18,6)
	,@DESCRIPTION_SKU AS VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN TransAdd
	BEGIN TRY
        INSERT INTO [SONDA].[SONDA_DOC_ROUTE_RETURN_DETAIL] (
				[ID_DOC_RETURN_HEADER]
				,[CODE_SKU]
				,[QTY]
				,[DESCRIPTION_SKU]
		)
		VALUES (
				@ID_DOC_RETURN_HEADER
				,@CODE_SKU
				,@QTY
				,@DESCRIPTION_SKU
		)

        COMMIT TRAN TransAdd

    END TRY
    BEGIN CATCH
	    ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
END
