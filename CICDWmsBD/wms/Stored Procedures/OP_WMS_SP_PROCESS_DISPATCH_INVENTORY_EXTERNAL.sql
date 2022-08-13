-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	26-01-2017
-- Description:			SP que genera la actualizacion de inventario en egreso externo

/*
-- Ejemplo de Ejecucion:
				-- 
				exec [wms].[OP_WMS_SP_PROCESS_DISPATCH_INVENTORY_EXTERNAL]
			
				

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_PROCESS_DISPATCH_INVENTORY_EXTERNAL(
  @DOCUMENT_DATE DATE 
  )
AS
BEGIN
	SET NOCOUNT ON;
	--

DECLARE @SKU VARCHAR(50)
DECLARE @QTY NUMERIC(18,2)
DECLARE @RESULTADO VARCHAR(250)=''
DECLARE @SP NVARCHAR(1000) = ''
DECLARE @MESSAGE VARCHAR(2000) = ''
DECLARE @START_RUN DATETIME
DECLARE @END_RUN DATETIME
DECLARE @CN INT=0
DECLARE @LOGIN VARCHAR(25)

   
	-- ------------------------------------------------------------------------------------
	-- Obtiene la estructura a ejecutar
	-- ------------------------------------------------------------------------------------
	SELECT 
		 EXT.MATERIAL_ID
		,EXT.QTY_REQUESTED
    ,[EXT].[LOGIN_ID]    
	INTO #INVEXT
	FROM [wms].[OP_WMS_DISPATCH_FROM_EXTERNAL] EXT
	WHERE EXT.READY_TO_GO=1

	DECLARE @TOTAL INT
	 SELECT @TOTAL= COUNT(*) FROM #INVEXT
	-- PRINT 'REGISTROS: '+ CAST(@TOTAL AS VARCHAR)
	-- ------------------------------------------------------------------------------------
	-- Recorre cada registro y lo manda a ejecutar
	-- ------------------------------------------------------------------------------------

  DECLARE @WAVE_PICKING_ID DECIMAL = 0
    , @CLIENT_OWNER VARCHAR(25)
    --INICIA CICLO DE ACTUALIZAR EL RESULTADO
    
    SELECT
      @WAVE_PICKING_ID = MAX([T].[WAVE_PICKING_ID]) + 1
    FROM [wms].[OP_WMS_TASK_LIST] [T]
    WHERE [T].[TASK_TYPE] = 'TAREA_PICKING'
  
  -----------------------------------------
  --Obtenemos datos del material
  -----------------------------------------
  SELECT TOP 1 
    @CLIENT_OWNER = [M].[CLIENT_OWNER]     
  FROM [wms].[OP_WMS_MATERIALS] [M] 
  WHERE [M].[MATERIAL_ID] = (SELECT TOP 1 E.[MATERIAL_ID] FROM #INVEXT E) 

  DECLARE @DOC_ID NUMERIC --= 'EXT-' + convert(VARCHAR(21),GETDATE())
   INSERT INTO [wms].[OP_WMS_POLIZA_HEADER] (          
          [CODIGO_POLIZA]
          ,[FECHA_LLEGADA]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
          ,[STATUS]
          ,[CLIENT_CODE]
          ,[WAREHOUSE_REGIMEN]
          ,[FECHA_DOCUMENTO]
          ,[TIPO]          
          ,[POLIZA_ASSIGNEDTO]
          ,[TRANSLATION]
          ,[ACUERDO_COMERCIAL]
          ,[IS_EXTERNAL_INVENTORY]
    )
    VALUES(      
      ''
      ,@DOCUMENT_DATE
      ,(SELECT TOP 1 E.[LOGIN_ID] FROM #INVEXT E) 
      ,GETDATE()
      ,'CREATED'
      ,@CLIENT_OWNER
      ,'GENERAL'
      ,@DOCUMENT_DATE
      ,'EGRESO'      
      ,''
      ,'NO'
      ,''
      ,1
    )
    SELECT @DOC_ID =  SCOPE_IDENTITY()

    UPDATE [wms].[OP_WMS_POLIZA_HEADER] SET
       [NUMERO_ORDEN] = CONVERT(VARCHAR(25), @DOC_ID)
       ,[CODIGO_POLIZA] = CONVERT(VARCHAR(15), @DOC_ID)
    WHERE [DOC_ID] = @DOC_ID

  DECLARE @CODIGO_POLIZA VARCHAR(15) = CONVERT(VARCHAR(15), @DOC_ID)
	
  WHILE EXISTS(SELECT TOP 1 1 FROM #INVEXT)
	BEGIN
	SET @CN=@CN+1
		-- ------------------------------------------------------------------------------------
		-- Obtiene el registro a ejecutar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@SKU = IE.MATERIAL_ID
			,@QTY = IE.QTY_REQUESTED
      ,@LOGIN = [IE].[LOGIN_ID]
		FROM #INVEXT IE

		--
		--PRINT '----> @SP: ' + @SP
		--PRINT '----> @START_RUN: ' + CONVERT(VARCHAR,@START_RUN,121)
		
		-- ------------------------------------------------------------------------------------
		-- Intenta ejecutar proceso 
		-- ------------------------------------------------------------------------------------
		BEGIN TRY
		 --DECLARE @RESULTADO VARCHAR(250)  @RESULTADO=

		-- PRINT ''+CAST(@CN AS VARCHAR)+'. CODIGO: ' + @SKU
      EXEC [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE_EXT] 
			   @QTY= @QTY
			,@MATERIAL_ID= @SKU 
      ,@LOGIN_ID=@LOGIN
      ,@WAVE_PICKING_ID = @WAVE_PICKING_ID
        ,@CODIGO_POLIZA = @CODIGO_POLIZA


--			SET @SP=N'
--			EXEC [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE_EXT] 
--			   @QTY=' + CAST(@QTY AS varchar)
--			+',@MATERIAL_ID=' + ''''+CAST(@SKU AS VARCHAR) +''''
--      +',@LOGIN_ID=' + ''''+CAST(@LOGIN AS VARCHAR) +''''
--
--			-- EJECUTA EL SP
--			EXEC SP_EXECUTESQL @SP
--			--
--			PRINT @SP
		
			
		END TRY
		BEGIN CATCH
			SET @MESSAGE = ERROR_MESSAGE()
		END CATCH

		-- ------------------------------------------------------------------------------------
		-- Almacena log
		-- ------------------------------------------------------------------------------------
		SET @END_RUN = GETDATE()

		-- ------------------------------------------------------------------------------------
		-- Elimina el proceso que acaba de correr
		-- ------------------------------------------------------------------------------------
		DELETE FROM #INVEXT  WHERE MATERIAL_ID = @SKU
		--ACTUALIZA EL DISPATCH
		UPDATE [wms].[OP_WMS_DISPATCH_FROM_EXTERNAL]
		SET PROCESS_RESULT='PROCESADO'
		,QTY_ONHAND=QTY_ONHAND-@QTY
		,QTY_REQUESTED=0
		WHERE MATERIAL_ID=@SKU


	END

	SELECT 'EXITO' AS 'RESULTADO'
END