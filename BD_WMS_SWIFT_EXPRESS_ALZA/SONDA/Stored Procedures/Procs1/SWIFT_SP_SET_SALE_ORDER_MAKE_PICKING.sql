-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	04-Ene-2017 @ A-TEAM Sprint Balder
-- Description:			SP que actualiza el campo HAVE_PICKING en la tabla SONDA_SALES_ORDER_HEADER

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SET_SALE_ORDER_MAKE_PICKING]
					@SALES_ORDER_ID = 1					
				-- 
				SELECT * FROM SONDA_SALES_ORDER_HEADER WHERE SALES_ORDER_ID = @SALES_ORDER_ID
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_SALE_ORDER_MAKE_PICKING](
	@SALES_ORDER_ID INT	
)
AS
BEGIN
	BEGIN TRY

    UPDATE [SONDA].SONDA_SALES_ORDER_HEADER SET
    HAVE_PICKING = 1
    WHERE SALES_ORDER_ID = @SALES_ORDER_ID		
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
