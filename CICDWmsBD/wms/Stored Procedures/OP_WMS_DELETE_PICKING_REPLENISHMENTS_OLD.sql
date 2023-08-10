
-- =============================================
-- Autor:				Jonatan Palacios
-- Fecha de Creacion:	25/01/2023
-- Description:			Cancela tareas de reabastecimiento en la task list

--EXEC [wms].[OP_WMS_DELETE_PICKING_REPLENISHMENTS_OLD]

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_DELETE_PICKING_REPLENISHMENTS_OLD] AS
BEGIN TRAN;
	BEGIN TRY
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Se cancela la ola de picking para que no aparezca en el administrador de tareas
			-- ------------------------------------------------------------------------------------
			UPDATE [wms].[OP_WMS_TASK_LIST] SET	
				[IS_PAUSED] = 3,
				[IS_COMPLETED] = 1,
				[IS_CANCELED] = 1,
				[CANCELED_DATETIME] = CURRENT_TIMESTAMP,
				[CANCELED_BY] = 'SOPORTE'
				WHERE
				IS_COMPLETED = 0 AND IS_CANCELED = 0 AND (IS_PAUSED = 3 OR IS_PAUSED = 0) AND ASSIGNED_DATE < GETDATE() AND ACCEPTED_DATE IS NULL AND TASK_SUBTYPE = 'REUBICACION_BUFFER'
		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CONVERT(VARCHAR(16), 1) [DbData];
		COMMIT TRAN;
	END TRY
BEGIN CATCH
	ROLLBACK;
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo];
END CATCH;