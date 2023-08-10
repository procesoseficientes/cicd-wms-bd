-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	17-03-2016
-- Description:			Actualiza el detalle del manifiesto de carga y finaliza el 
--						encabezado del mismo.

--Modificaco:			hector.gonzalez
-- Create date:			20-06-2016
-- Description:			Se agrego un update para las task completadas

/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_UPDATE_MANIFEST_DETAIL_BY_TASK] 
				@TASK_ID =18753
				,@TASK_STATUS='COMPLETED'
				,@LOGIN='OPER1@SONDA'
				,@GPS='14.2134,-90.23445'
				,@REJECT_COMMENT=''
				,@PHOTO=''

					
*/
-- =============================================
CREATE  PROCEDURE [SONDA].SWIFT_SP_UPDATE_MANIFEST_DETAIL_BY_TASK          
	@TASK_ID				INT 
	,@TASK_STATUS			VARCHAR(10)
	,@LOGIN					VARCHAR(50)
	,@REJECT_COMMENT		VARCHAR(250)
	,@PHOTO					VARCHAR(MAX)
	,@GPS                   VARCHAR(250)
AS
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
  	-- Declaran las variables
  	-- ------------------------------------------------------------------------------------
	DECLARE
		@COMPLETED_STATUS		VARCHAR(50)
		,@TASK_TYPE				VARCHAR(50)
		,@DELIVERY_TYPE			VARCHAR(50)
		,@COMPLETED_MANIFEST	INT=1
		,@MANIFEST_HEADER		INT
	

  -- ------------------------------------------------------------------------------------
  -- Obtiene los parametros de tarea completada, aceptada y tarea de entrega
  -- ------------------------------------------------------------------------------------
  SELECT @COMPLETED_STATUS = VALUE
  FROM [SONDA].SWIFT_PARAMETER 
  WHERE GROUP_ID = 'TASK' AND PARAMETER_ID = 'COMPLETED_STATUS'

  --
  SELECT @DELIVERY_TYPE = VALUE
  FROM [SONDA].SWIFT_PARAMETER 
  WHERE GROUP_ID = 'TASK' AND PARAMETER_ID = 'DELIVERY_TYPE'

  -- ------------------------------------------------------------------------------------
  -- Se actualiza la tabla de tarea
  -- ------------------------------------------------------------------------------------
	UPDATE T 
	SET 
		T.TASK_STATUS=@TASK_STATUS,
		T.ASSIGEND_TO=@LOGIN    
	FROM [SONDA].SWIFT_TASKS T
	WHERE T.TASK_ID=@TASK_ID

  -- ------------------------------------------------------------------------------------
  -- Acepta Tarea de Entrega
  -- ------------------------------------------------------------------------------------
	IF(@TASK_STATUS=@COMPLETED_STATUS)
	BEGIN
     	    -- ------------------------------------------------------------------------------------
  			-- Obtiene el tipo de tarea en la tarea
  			-- ------------------------------------------------------------------------------------
			
			SELECT @TASK_TYPE= ST.TASK_TYPE
			FROM [SONDA].SWIFT_TASKS ST
			WHERE ST.TASK_ID=@TASK_ID
	
		--
		IF (@TASK_TYPE=@DELIVERY_TYPE)
		BEGIN

        -- ------------------------------------------------------------------------------------
  			-- Actualizar el la tarea
  			-- ------------------------------------------------------------------------------------
        
        UPDATE T
      	SET 
      		T.TASK_STATUS=@TASK_STATUS
      		,T.ASSIGEND_TO=@LOGIN
          ,T.COMPLETED_STAMP = GetDate()
      	FROM [SONDA].SWIFT_TASKS T
      	WHERE T.TASK_ID=@TASK_ID
        
			  -- ------------------------------------------------------------------------------------
  			-- Actualizar el Header
  			-- ------------------------------------------------------------------------------------
            UPDATE [SONDA].[SWIFT_MANIFEST_DETAIL]
			SET 
				 REJECT_COMMENT=@REJECT_COMMENT
				,IMAGE_1=@PHOTO
				,LAST_UPDATE_BY=@LOGIN
				,LAST_UPDATE=GETDATE()
				,GPS_EXPECTED=@GPS
			WHERE DELIVERY_TASK=@TASK_ID

			-- ------------------------------------------------------------------------------------
  			-- Obtiene el #Manifest Header
  			-- ------------------------------------------------------------------------------------
			SELECT @MANIFEST_HEADER = MD.CODE_MANIFEST_HEADER
			FROM [SONDA].[SWIFT_MANIFEST_DETAIL] MD
			WHERE DELIVERY_TASK=@TASK_ID

			-- ------------------------------------------------------------------------------------
  			-- Obtiene la agrupacion de las tareas finalizadas de los detalles
  			-- ------------------------------------------------------------------------------------
            SELECT TOP 1 @COMPLETED_MANIFEST = 0
  			FROM [SONDA].[SWIFT_MANIFEST_DETAIL] D
  			INNER JOIN [SONDA].[SWIFT_TASKS] T ON (D.DELIVERY_TASK = T.TASK_ID)		
   			WHERE  D.CODE_MANIFEST_HEADER=@MANIFEST_HEADER
			AND T.TASK_STATUS  != @COMPLETED_STATUS
			--
			--PRINT '@COMPLETED_MANIFEST: ' + CAST(@COMPLETED_MANIFEST AS VARCHAR) 
			-- ------------------------------------------------------------------------------------
  			-- Actualiza el status del manifiesto de entrega
  			-- ------------------------------------------------------------------------------------
			IF(@COMPLETED_MANIFEST = 1)
			BEGIN
				UPDATE [SONDA].[SWIFT_MANIFEST_HEADER]
				SET [STATUS] = @COMPLETED_STATUS
					,LAST_UPDATE_BY=@LOGIN
					,LAST_UPDATE=GETDATE()
					,COMPLETED_STAMP= GETDATE()					
				WHERE [MANIFEST_HEADER]= @MANIFEST_HEADER	

				UPDATE [SONDA].SWIFT_TASKS
				SET COMPLETED_SUCCESSFULLY=1
					,COMPLETED_STAMP= GETDATE()					
				WHERE TASK_ID= @TASK_ID	

			END 
		END		
END
