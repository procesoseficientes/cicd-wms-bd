-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:         sp que reabre una tarea de recepcion completa siempre y cuando no haya sido confirmada o enviada a erp


-- Autor:				marvin.solares
-- Fecha de Creacion: 	03-Sep-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:         reviso que el documento no haya sido enviado a erp o confirmado en BO

/*|
-- Ejemplo de Ejecucion:
        
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_REOPEN_TASK_RECEPTION] (
		@SERIAL_NUMBER NUMERIC(18, 0)
		,@LOGIN VARCHAR(64)
	)
AS
BEGIN
-- ------------------------------------------------------------------------------------
	-- actualizo la tarea como no completada
	-- ------------------------------------------------------------------------------------
	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
					WHERE
						[RDH].[TASK_ID] = @SERIAL_NUMBER
						AND (
								[RDH].[IS_AUTHORIZED] = 1
								OR [RDH].[IS_POSTED_ERP] = 1
							) )
	BEGIN
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[IS_COMPLETED] = 0
			,[COMPLETED_DATE] = NULL
			,[TASK_OWNER] = @LOGIN
		WHERE
			[SERIAL_NUMBER] = @SERIAL_NUMBER;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];

	END;
	ELSE
	BEGIN
		SELECT
			-1 AS [Resultado]
			,'El documento ya fue confirmado o enviado a ERP.' [Mensaje]
			,698 [Codigo]
			,'' [DbData];
	END;
END;