-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 4
-- Description:			    SP que elimina el tipo de cargo

/*
-- Ejemplo de Ejecucion:
        DECLARE @pResult VARCHAR(250) = ''
		--
		EXEC [wms].[OP_WMS_SP_DELETE_TYPE_CHANGE]
			@TYPE_CHARGE_ID = 1
			,@pResult = @pResult OUTPUT
		--
		SELECT @pResult [pResult]
		--
		SELECT * FROM  [wms].[OP_WMS_TYPE_CHARGE] WHERE TYPE_CHARGE_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_TYPE_CHANGE](
	@TYPE_CHARGE_ID INT,	
	@pResult varchar(250) OUTPUT
)AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @Cantidad INT
	
	SELECT @Cantidad = COUNT(*)
	FROM [wms].OP_WMS_TARIFICADOR_DETAIL 
	WHERE [TYPE_CHARGE_ID] = @TYPE_CHARGE_ID
	
	IF @Cantidad = 0 
	BEGIN	
		BEGIN TRAN
			BEGIN
				DELETE [wms].OP_WMS_TYPE_CHARGE
				WHERE TYPE_CHARGE_ID = @TYPE_CHARGE_ID							   
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
	ELSE
	BEGIN
		SELECT @pResult = 'No se puede borrar el registro, esta relacionada con un acuerdo comercial'
	END
		
END