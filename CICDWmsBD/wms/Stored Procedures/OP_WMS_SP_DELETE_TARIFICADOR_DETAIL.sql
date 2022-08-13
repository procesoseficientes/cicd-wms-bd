-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 4
-- Description:			    SP que elimina el detalle

/*
-- Ejemplo de Ejecucion:
        DECLARE @pResult VARCHAR(250) = ''
		--
		EXEC [wms].[OP_WMS_SP_DELETE_TARIFICADOR_DETAIL]
			@ACUERDO_COMERCIAL = '12'
			,@SERIAL_ID = 1
			,@pResult = @pResult OUTPUT
		--
		SELECT @pResult [pResult]
		--
		SELECT * FROM  [wms].[OP_WMS_TARIFICADOR_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_TARIFICADOR_DETAIL]	(
	@ACUERDO_COMERCIAL  INT
	,@SERIAL_ID INT
	,@pResult varchar(250) OUTPUT
)AS
BEGIN
	SET NOCOUNT ON;	
	BEGIN TRAN
		BEGIN
			DELETE [wms].OP_WMS_TARIFICADOR_DETAIL
			WHERE ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL
			AND SERIAL_ID = @SERIAL_ID
						
		END	
	IF @@error = 0 BEGIN
		SELECT @pResult = 'OK'
		COMMIT TRAN
	END
	ELSE
		BEGIN
			ROLLBACK TRAN
			SELECT	@pResult	= ERROR_MESSAGE()
		END
		
END