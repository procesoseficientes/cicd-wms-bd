﻿-- =============================================
-- Author:         diego.as
-- Create date:    01-03-2016
-- Description:    Obtiene  el PICKING_HEADER de la TASK que se le envia como parametro
/*
Ejemplo de Ejecucion:
	--- EJEMPLO CON DATOS EXISTENTES---------------------------

	DECLARE @TASK_NUMBER INT
		
		SET @TASK_NUMBER = 14169


	EXEC [SONDA].[SWIFT_SP_GET_PICKING_HEADER]
	@TASK_ID = @TASK_NUMBER

	
	----- EJEMPLO CON DATOS INEXISTENTES-------------------------
	DECLARE @TASK_NUMBER INT
		
		SET @TASK_NUMBER = 14169


	EXEC [SONDA].[SWIFT_SP_GET_PICKING_HEADER]
	@TASK_ID = @TASK_NUMBER

	 				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PICKING_HEADER]
(
	@TASK_ID INT

)
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @PICKING_HEADER INT
				
		SELECT @PICKING_HEADER = PICKING_NUMBER FROM [SONDA].[SWIFT_TASKS] 
		WHERE  TASK_ID = @TASK_ID
		
		IF @PICKING_HEADER IS NOT NULL BEGIN
			SELECT @PICKING_HEADER AS PICKING_HEADER
		END
		ELSE BEGIN
			SET @PICKING_HEADER = NULL
			SELECT @PICKING_HEADER AS PICKING_HEADER
		END
		

END