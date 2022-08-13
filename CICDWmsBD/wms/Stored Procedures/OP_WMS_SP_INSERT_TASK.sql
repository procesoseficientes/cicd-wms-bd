-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Insertar en nueva tabla de tareas




/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_INSERT_TASK] @CREATE_BY = 'ADMIN'
                                       ,@TASK_TYPE = 'TAREA_CONTE_FISICO'
                                       ,@TASK_ASSIGNED_TO = 'ACAMACHO'
                                       ,@REGIMEN = 'GENERAL'
                                       ,@PRIORITY = 3
                                       ,@COMMENTS = 'PRUEBA'
			SELECT * FROM [wms].[OP_WMS_TASK] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASK] (@CREATE_BY VARCHAR(25)
, @TASK_TYPE VARCHAR(25)
, @TASK_ASSIGNED_TO VARCHAR(25)
, @REGIMEN VARCHAR(15)
, @PRIORITY INT
, @COMMENTS VARCHAR(150))
AS
BEGIN
  SET NOCOUNT ON;
  --
  INSERT INTO [wms].[OP_WMS_TASK] ([CREATE_BY]
  , [TASK_TYPE]
  , [TASK_ASSIGNED_TO]
  , [IS_ACCEPTED]
  , [IS_COMPLETE]
  , [IS_PAUSED]
  , [IS_CANCELED]
  , [REGIMEN]
  , [ASSIGNED_DATE]
  , [LAST_UPDATE]
  , [LAST_UDATE_BY]
  , [PRIORITY]
  , [COMMENTS])
    VALUES (@CREATE_BY, @TASK_TYPE, @TASK_ASSIGNED_TO, 0, 0, 0, 0, @REGIMEN, GETDATE(), GETDATE(), @CREATE_BY, @PRIORITY, @COMMENTS);

  DECLARE @DOC_ID INT = SCOPE_IDENTITY()
  IF @@ERROR <> 0
  BEGIN

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
     ,'0' DbData

  END
  ELSE
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@DOC_ID AS VARCHAR) DbData
  END

END