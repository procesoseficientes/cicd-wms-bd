-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Oct-17 @ Nexus Team Sprint ewms
-- Description:			SP que colola el ID de la induccion al pedido
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_SET_INDUCTION_ID_TO_DISTRIBUTED_TASK]
					@ERP_DOC = 'PC-6'
					,@INDUCTION_ID = 6
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_SET_INDUCTION_ID_TO_DISTRIBUTED_TASK](
	@ERP_DOC VARCHAR(25)
	,@INDUCTION_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
	    UPDATE [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK]
	    SET [INDUCTION_ID] = @INDUCTION_ID
	    WHERE [ERP_DOC] = @ERP_DOC
		--
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'' DbData
	END TRY
	BEGIN CATCH
		SELECT
			-1 as Resultado
			,ERROR_MESSAGE()  Mensaje 
			,@@ERROR Codigo
			,'' DbData
	END CATCH
END