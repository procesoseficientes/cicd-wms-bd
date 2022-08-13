-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/13/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			Obtiene si la tarea es de una recepcion general, de erp o devolucion

/*
-- Ejemplo de Ejecucion:
				DECLARE @TYPE_OUT VARCHAR(50) = ''
				--
				EXEC [wms].[OP_WMS_SP_GET_RECEPTION_TYPE]
					@TASK_ID = 518218
					@TYPE = @TYPE_OUT OUT
				--
				SELECT @TYPE_OUT
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_TYPE](
	@TASK_ID INT
	,@TYPE VARCHAR(50) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--

	IF EXISTS (SELECT TOP 1 1 
				FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
				WHERE [TASK_ID] = @TASK_ID)
	BEGIN
		SELECT @TYPE = [SOURCE]
		FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		WHERE [TASK_ID] = @TASK_ID
	END
    ELSE
    BEGIN
        SET @TYPE = 'RECEPCION_GENERAL'
    END

	SELECT @TYPE
END