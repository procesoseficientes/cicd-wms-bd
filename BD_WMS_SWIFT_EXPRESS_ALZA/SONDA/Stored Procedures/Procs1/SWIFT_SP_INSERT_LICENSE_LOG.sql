-- =============================================
-- Autor:				Christian Hernandez
-- Fecha de Creacion: 	08/06/2018 @ GForce-TEAM Sprint Hormiga
-- Description:			SP que inserta el log de las actuazliaciones de direcciones de paquetes en licencias

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_LICENSE_LOG]
				@LOGIN = '<ArrayOfLogs>
							<Logs>
							<LOG_ID>0</LOG_ID>
							<LOG_DATETIME>0001-01-01T00:00:00</LOG_DATETIME>
							<SOURCE_ERROR>InsertarLogDeLicencia | SWIFT_INSERT_LICENSE_LOG</SOURCE_ERROR>
							<MESSAGE_ERROR>Modificacion de CommunicationAddress con valor antiguo 127.0.0.1 y valor actual 127.0.0.12</MESSAGE_ERROR>
							</Logs>
						  </ArrayOfLogs>'
				, @XML = 'gerente@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_LICENSE_LOG](
	  @LOGIN VARCHAR(250)
	, @XML XML
)
AS
 
BEGIN 
  BEGIN TRY
	SET NOCOUNT ON;
-----------------------------------------------------------------------------
--Se obtienen los valores del XML desde la tabla y se insertan a una temporal  
-----------------------------------------------------------------------------
	DECLARE @TABLE_LOG TABLE (
		[LOG_DATETIME] DATETIME
		,[CODE_ROUTE] VARCHAR(250)
		,[LOGIN] VARCHAR(250)
		,[SOURCE_ERROR] VARCHAR(250)
		,[DOC_RESOLUTION] VARCHAR(250)
		,[DOC_SERIE] VARCHAR(250)
		,[DOC_NUM] INT
		,[MESSAGE_ERROR] VARCHAR(max)
		,[SEVERITY_CODE] VARCHAR(max)
		,[TYPE] VARCHAR(250)
	)

	INSERT INTO @TABLE_LOG ([SOURCE_ERROR], [MESSAGE_ERROR])
		SELECT
		x.Rec.query('./SOURCE_ERROR').value('.', 'varchar(max)')
		,x.Rec.query('./MESSAGE_ERROR').value('.', 'varchar(max)')
		FROM @XML.nodes('ArrayOfLogs/Logs') AS x (Rec)

-------------------------------------------------------------------------------
--De los datos que obtuvimos insertamos directamente a la tabla de logs.
-------------------------------------------------------------------------------

   UPDATE @TABLE_LOG SET LOG_DATETIME = GETDATE(), CODE_ROUTE ='Sin Ruta', [LOGIN] = @LOGIN, DOC_RESOLUTION = 'Sin Resolucion', DOC_SERIE = 'Sin Serie', DOC_NUM = 0, SEVERITY_CODE =2, [TYPE] = 'INFO'


   INSERT INTO [SONDA].[SONDA_SERVER_ERROR_LOG]  ([LOG_DATETIME], [CODE_ROUTE], [LOGIN], [SOURCE_ERROR], [DOC_RESOLUTION], [DOC_SERIE], [DOC_NUM], [MESSAGE_ERROR], [SEVERITY_CODE], [TYPE])
   select * from @TABLE_LOG

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo

	END TRY 
	BEGIN CATCH

	SELECT
      -1 AS Resultado
     ,'Error en insercion' Mensaje
     ,0 Codigo

	END CATCH

   END
