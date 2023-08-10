-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		24-05-2016
-- Description:			    Actualiza la fecha de entrega

-- Modificacion 16-Mar-17 @ A-Team Sprint 
					-- jose.garcia
					-- Se agrego el campo ready tu send en el where 
/*
-- Ejemplo de Ejecucion:
        --
		SELECT * FROM [SONDA].[SONDA_SALES_ORDER_HEADER] WHERE [DOC_SERIE] = 'D' AND [DOC_NUM] = 23
		--
		EXEC [SONDA].[SWIFT_SP_UPDATE_DELIVERY_DATE_BY_SALES_ORDER]
			@DOC_SERIE = 'D'
			,@DOC_NUM = 23
			,@DELIVERY_DATE = '20160606 00:00:00.000'
		--
		SELECT * FROM [SONDA].[SONDA_SALES_ORDER_HEADER] WHERE [DOC_SERIE] = 'D' AND [DOC_NUM] = 23
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_DELIVERY_DATE_BY_SALES_ORDER
	@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
	,@DELIVERY_DATE DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
		SET
			[DELIVERY_DATE] = @DELIVERY_DATE
		WHERE [DOC_SERIE] = @DOC_SERIE 
			AND [DOC_NUM] = @DOC_NUM
			AND IS_READY_TO_SEND=1
		--
		IF @@error = 0 BEGIN		
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
		END		
		ELSE BEGIN		
			SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
		END
	END TRY
	BEGIN CATCH     
		 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
	END CATCH
END
