-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		19-Jan-18 @ Nexus Team Sprint 
-- Description:			    Se llama a SP de inserción retornando un objeto operación como resultado


/*
-- Ejemplo de Ejecucion:
			  SELECT * FROM [wms].[OP_WMS_INV_X_LICENSE] [OWIXL] INNER JOIN [wms].[OP_WMS_LICENSES] [OWL] ON [OWIXL].[LICENSE_ID] = [OWL].[LICENSE_ID] WHERE [OWIXL].[QTY] > 0  AND [OWL].[LICENSE_ID] = 45008
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [OWPCD] INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [OWPCH] ON [OWPCD].[PHYSICAL_COUNT_HEADER_ID] = [OWPCH].[PHYSICAL_COUNT_HEADER_ID]
  
  EXEC [wms].[OP_WMS_SP_INSERT_COUNT_EXECUTION_OPERATION] @LOGIN = 'ACAMACHO'
                                                    ,@TASK_ID = 9
                                                    ,@LOCATION = 'B01-R01-C01-NB'
                                                    ,@LICENSE_ID = 127680
                                                    ,@MATERIAL_ID = 'C00030/LECH-CONDEN'
                                                    ,@QTY_SCANNED = 1.0000
                                                    ,@EXPIRATION_DATE = '2016-12-05'
                                                    ,@BATCH = '281617'
                                                    ,@SERIAL = 'GDR007'

  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER]
  select  * from [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_COUNT_EXECUTION_OPERATION]
    (
     @LOGIN VARCHAR(25)
    ,@TASK_ID INT
    ,@LOCATION VARCHAR(25)
    ,@LICENSE_ID INT
    ,@MATERIAL_ID VARCHAR(25)
    ,@QTY_SCANNED NUMERIC(18, 4)
    ,@EXPIRATION_DATE DATE = NULL
    ,@BATCH VARCHAR(50) = NULL
    ,@SERIAL VARCHAR(50) = NULL
	,@TYPE VARCHAR(50) = 'INSERT' -- INSERT/UPDATE/ADD
	)
AS
BEGIN
    SET NOCOUNT ON;


    BEGIN TRY
        EXEC [wms].[OP_WMS_SP_INSERT_COUNT_EXECUTION] @LOGIN = @LOGIN, -- varchar(25)
            @TASK_ID = @TASK_ID, -- int
            @LOCATION = @LOCATION, -- varchar(25)
            @LICENSE_ID = @LICENSE_ID, -- int
            @MATERIAL_ID = @MATERIAL_ID, -- varchar(25)
            @QTY_SCANNED = @QTY_SCANNED, -- numeric
            @EXPIRATION_DATE = @EXPIRATION_DATE, -- date
            @BATCH = @BATCH, -- varchar(50)
            @SERIAL = @SERIAL,  -- varchar(50)
			@TYPE = @TYPE;
		
    END TRY		
    BEGIN CATCH

        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,CASE WHEN ERROR_MESSAGE() = 'La tarea fue reasignada a otro operador o no se encuentra habilitada para operar'
                 THEN 2002
                 WHEN ERROR_MESSAGE() = 'Tarea fue cancelada' THEN 1202
                 ELSE @@ERROR
            END [Codigo]
           ,CAST('' AS VARCHAR) [DbData];
        RETURN;	 

    END CATCH;

    SELECT
        1 AS [Resultado]
       ,'Proceso Exitoso' [Mensaje]
       ,0 [Codigo]
       ,CAST('1' AS VARCHAR) [DbData];
END;