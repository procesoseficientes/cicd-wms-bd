-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		31-08-2016
-- Description:			    Almacena una tarea de reabastecimiento. 

/*
-- DROP PROCEDURE [SONDA].[SWIFT_SP_INSERT_RESTOCK_LP_TASK]
-- Ejemplo de Ejecucion:
        EXEC  [SONDA].[SWIFT_SP_INSERT_RESTOCK_LP_TASK] @MATERIAL_ID ='100003',
        @MATERIAL_DESCRIPTION = 'DU CB AL AA 1SB X 120CS 12SW HLLY',
        @LOCATION_SPOT = 'R1C02N1P02',
        @RESTOCK_USER = 'RUDI@SONDA',
        @LOGIN = 'MBL',
        @QTY = '5000000',
        @LP_TASK_CODE = '123123',
        @SOURCE_WAREHOUSE = 'BODEGA_CENTRAL'
  
          SELECT  TOP(10)  *  FROM [SONDA].[SWIFT_PICKING_DETAIL] order by PICKING_HEADER DESC
          SELECT  TOP(10)  *  FROM [SONDA].[SWIFT_PICKING_HEADER] order by PICKING_HEADER DESC
          SELECT  TOP(10)  *  FROM [SONDA].[SWIFT_TASKS] order by PICKING_NUMBER DESC
 -- WITH  q AS (SELECT TOP(1)  * FROM [SONDA].[SWIFT_TASKS] order by PICKING_NUMBER DESC)DELETE FROM q
 -- WITH  q AS (SELECT TOP(1)  * FROM [SONDA].[SWIFT_PICKING_DETAIL] order by PICKING_HEADER DESC)DELETE FROM q
 -- WITH  q AS (SELECT TOP(1)  * FROM [SONDA].[SWIFT_PICKING_HEADER] order by PICKING_HEADER DESC)DELETE FROM q
        
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_RESTOCK_LP_TASK] (@MATERIAL_ID VARCHAR(25),
	  @MATERIAL_DESCRIPTION VARCHAR(25),
	  @LOCATION_SPOT VARCHAR(25),
	  @RESTOCK_USER VARCHAR(25),
	  @LOGIN VARCHAR(25),
	  @QTY INT,
	  @LP_TASK_CODE VARCHAR(25),
	  @SOURCE_WAREHOUSE VARCHAR(25),
	  @CODE_CLIENT VARCHAR(25) = 'LINEA_PICKING_001'
  )

AS
BEGIN
	  BEGIN TRAN

	  CREATE TABLE #RESULT_HEADER (
		Resultado INT
	   ,Mensaje VARCHAR(250)
	   ,Codigo INT
	   ,DbData VARCHAR(16)
	  )
	

	  DECLARE @HOY AS DATE
		,  @MENSAJE AS VARCHAR(500)
	  SELECT
		@HOY = GETDATE()
	  INSERT INTO #RESULT_HEADER
	  EXEC [SONDA].SWIFT_SP_INSERT_PICKING_HEADER @CLASSIFICATION_PICKING = '3076'
											   ,@CODE_CLIENT = @CODE_CLIENT
											   ,@CODE_USER = NULL
											   ,@REFERENCE = NULL
											   ,@DOC_SAP_RECEPTION = NULL
											   ,@STATUS = 'ASSIGNED'
											   ,@LAST_UPDATE_BY = 'LP_SYSTEM'
											   ,@COMMENTS = 'Tarea reabastecimiento asignada desde LP'
											   ,@SCHEDULE_FOR = @HOY
											   ,@SEQ = 1
											   ,@FF = NULL
											   ,@FF_STATUS = NULL
											   ,@CODE_WAREHOUSE_SOURCE = @SOURCE_WAREHOUSE
											   ,@SOURCE_DOC_TYPE = NULL
											   ,@SOURCE_DOC = NULL
											   ,@TARGET_DOC = NULL
											   ,@CODE_SELLER = NULL
											   ,@CODE_ROUTE = NULL

	
	
	  IF  EXISTS(SELECT TOP 1 1 FROM #RESULT_HEADER WHERE Resultado <> 1)
	  BEGIN
		  
		  SELECT @MENSAJE = 'ERROR DB, Al insertar el encabezado del picking de reabastecimiento: ' + (SELECT TOP 1 Mensaje FROM #RESULT_HEADER WHERE Resultado <> 1)
		  ROLLBACK;
		  RAISERROR (@MENSAJE, -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
			 
	  END
	  DECLARE @I_PICKING_HEADER INT
	  SELECT TOP 1
		@I_PICKING_HEADER = DbData
	  FROM #RESULT_HEADER

  
    
	  INSERT INTO #RESULT_HEADER
	  EXEC [SONDA].SWIFT_SP_INSERT_PICKING_DETAIL @PICKING_HEADER = @I_PICKING_HEADER
												,@CODE_SKU = @MATERIAL_ID
												,@DESCRIPTION_SKU = @MATERIAL_DESCRIPTION
												,@DISPATCH = @QTY
												,@SCANNED = 0
												,@RESULT = 0
												,@COMMENTS = 'Reabastecimiento LP'
												,@LAST_UPDATE_BY = 'LP_SYSTEM'
												,@DIFFERENCE = 0
	  
	  IF  EXISTS(SELECT TOP 1 1 FROM #RESULT_HEADER WHERE Resultado <> 1)
	  BEGIN
	  
		  SELECT @MENSAJE = 'ERROR DB, Al insertar el encabezado del picking de reabastecimiento: ' + (SELECT TOP 1 Mensaje FROM #RESULT_HEADER WHERE Resultado <> 1)
		  ROLLBACK;
		  RAISERROR (@MENSAJE, -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
			
	  END
	  INSERT INTO #RESULT_HEADER
	  EXEC [SONDA].SWIFT_SP_INSERT_TASK_FROM_PICKING @PICKING_HEADER = @I_PICKING_HEADER
	  UPDATE [SONDA].[SWIFT_TASKS] 
		SET ASSIGEND_TO = @RESTOCK_USER
	  WHERE PICKING_NUMBER = @I_PICKING_HEADER

	   IF  EXISTS(SELECT TOP 1 1 FROM #RESULT_HEADER WHERE Resultado <> 1)
	  BEGIN
	  
		  SELECT @MENSAJE = 'ERROR DB, Al insertar la tarea de picking de reabastecimiento ' + (SELECT TOP 1 Mensaje FROM #RESULT_HEADER WHERE Resultado <> 1)
		  ROLLBACK;
		  RAISERROR (@MENSAJE, -- Message text.  
               16, -- Severity.  
               1 -- State.  
               );  
		
	  END
	  
	  COMMIT


END
