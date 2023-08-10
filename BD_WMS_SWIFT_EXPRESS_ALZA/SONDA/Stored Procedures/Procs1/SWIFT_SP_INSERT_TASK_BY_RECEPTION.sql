
-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	26-02-2016
/* Description: SP que INSERTA un TAREA DE RECEPCIÓN POR DEVOLUCIÓN 
				en base al @RECEPTION_HEADER 
				que recibe como parametro.
*/

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_INSERT_TASK_BY_RECEPTION]
			@RECEPTION_HEADER = 1020
		---------------------------------------------------------
		SELECT * FROM [SONDA].[SWIFT_TASKS] order by TASK_DATE desc WHERE TASK_ID = 16507 <---COLOCAR ACA EL ID QUE RETORNA LA EJECUCION DEL SP
																		PARA PODER VER LOS DETALLES DE LA TAREA
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TASK_BY_RECEPTION]
(
	@RECEPTION_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @ID AS INT

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- INSERTA LA TAREA TOMANDO INFORMACION DE LA TABLA  [SONDA].[SWIFT_RECEPTION_HEADER]
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_TASKS] (
			TASK_TYPE
			,TASK_DATE
			,SCHEDULE_FOR
			,CREATED_STAMP
			,ASSIGEND_TO
			,ASSIGNED_STAMP
			,RELATED_PROVIDER_CODE
			,RELATED_PROVIDER_NAME
			,TASK_STATUS
			,TASK_COMMENTS
			,TASK_SEQ
			,REFERENCE
			,SAP_REFERENCE
			,RECEPTION_NUMBER
			,[ACTION]
			,SCANNING_STATUS
			,ALLOW_STORAGE_ON_DIFF
			)
		SELECT 'RECEPTION' AS TASK_TYPE
			,(CAST(GETDATE() AS DATE)) AS TASK_DATE
			,(CAST(GETDATE() AS DATE)) AS SCHEDULE_FOR
			,GETDATE() AS CREATED_STAMP
			,SRH.CODE_USER
			,GETDATE() AS ASSIGNED_STAMP
			,SRH.CODE_PROVIDER
			,SVC.NAME_CUSTOMER AS NAME_PROVIDER
			,'ASSIGNED' AS TASK_STATUS
			,'Recepcion por Devolucion' AS TASK_COMMENTS
			,2 AS TASK_SEQ
			,SRH.RECEPTION_HEADER
			,0 AS SAP_REFERENCE
			,SRH.RECEPTION_HEADER AS RECEPTION_NUMBER
			,'PLAY' AS [ACTION]
			,'PENDING' AS SCANNING_STATUS
			,1 AS ALLOW_STORAGE_ON_DIFF
		FROM [SONDA].[SWIFT_RECEPTION_HEADER] AS SRH
		INNER JOIN [SONDA].[SWIFT_VIEW_CUSTOMERS] AS SVC ON (
			SVC.CODE_CUSTOMER = SRH.CODE_PROVIDER
		)
		WHERE SRH.RECEPTION_HEADER = @RECEPTION_HEADER
		
		-- ------------------------------------------------------------------------------------
		-- RECOGE EL ID DE LA TAREA INSERTADA 
		-- ------------------------------------------------------------------------------------
		SET @ID = SCOPE_IDENTITY()

		-- ------------------------------------------------------------------------------------
		-- DEVUELVE EL ID 
		-- ------------------------------------------------------------------------------------
		SELECT @ID AS ID

	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
