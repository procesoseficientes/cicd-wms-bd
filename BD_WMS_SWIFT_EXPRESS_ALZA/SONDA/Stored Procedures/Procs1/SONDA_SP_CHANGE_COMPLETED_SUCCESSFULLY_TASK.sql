
/*======================================================
	Autor:				diego.as
	Fecha de Creacion:	15-10-2016 @ TEAM-A Sprint 3
	Descripcion:		Sp que actualiza el estado de COMPLETED_SUCCESSFULLY a 1 si realizo gestion alguna
						de lo contrario coloca 0 y la Razon por la que no genero gestion.

-- Modificacion 11/24/2017 @ Reborn-Team Sprint Nach
					-- diego.as
					-- Se agregan las columnas de Aceptado y Completado asi como el Status de la tarea

          -- Autor:	        hector.gonzalez
          -- Fecha de Creacion: 	2017-12-11 @REBORN-Team - Sprint Pannen
          -- Description:	   Se agrega Secuencia de tarea


Ejemplo de Ejecucion:
	EXEC [SONDA].[SONDA_SP_CHANGE_COMPLETED_SUCCESSFULLY_TASK]
		@TASK_ID = 40125
		,@CUSTOMER_CODE = 'BO-2090'
		,@COMPLETED_SUCCESSFULLY = 0
		,@REASON = 'Cliente No Estaba'
		,@ACCEPTED_STAMP  = '2016-10-19 12:28:23.000'
		,@COMPLETED_STAMP  = '2016-10-19 12:28:23.000'
		,@TASK_STATUS = 'COMPLETED'
		,@POSTED_GPS = ''
    ,@TASK_SEQ = 2
		--
		SELECT * FROM [SONDA].[SWIFT_TASKS] WHERE TASK_ID = 40125
======================================================*/
CREATE PROCEDURE [SONDA].SONDA_SP_CHANGE_COMPLETED_SUCCESSFULLY_TASK (@TASK_ID INT
, @CUSTOMER_CODE VARCHAR(50)
, @COMPLETED_SUCCESSFULLY INT = NULL
, @REASON VARCHAR(50) = NULL
, @ACCEPTED_STAMP DATETIME = NULL
, @COMPLETED_STAMP DATETIME = NULL
, @TASK_STATUS VARCHAR(250) = NULL
, @POSTED_GPS VARCHAR(250) = NULL
, @TASK_SEQ INT = NULL)
AS
BEGIN
  --
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_TASKS]
    SET COMPLETED_SUCCESSFULLY = @COMPLETED_SUCCESSFULLY
       ,REASON = @REASON
       ,[ACCEPTED_STAMP] = @ACCEPTED_STAMP
       ,[COMPLETED_STAMP] = @COMPLETED_STAMP
       ,[TASK_STATUS] = @TASK_STATUS
       ,[POSTED_GPS] = @POSTED_GPS
       ,[TASK_SEQ] = @TASK_SEQ   
    WHERE TASK_ID = @TASK_ID
    AND COSTUMER_CODE = @CUSTOMER_CODE
  --
  END TRY
  BEGIN CATCH
    DECLARE @ERROR VARCHAR(MAX)
    SET @ERROR = ERROR_MESSAGE()
    RAISERROR (@ERROR, 16, 1)
  END CATCH
--
END
