
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	17-03-2016
-- Description:			Actualiza el detalle del manifiesto de carga y finaliza el 
--						encabezado del mismo.
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_AAA] 
				@TASK_ID =18752
				,@TASK_STATUS='ACEPTED'
				,@LOGIN='OPER1@SONDA'
				,@REJECT_COMMENT='Mercaderia Vencida'
				,@PHOTO=''
					
*/
-- =============================================
CREATE  PROCEDURE [SONDA].[SWIFT_SP_AAA]          
	@TASK_ID INT 
	,@TASK_STATUS VARCHAR(10)
	,@LOGIN VARCHAR(50)
	,@REJECT_COMMENT VARCHAR(250)=''
	,@PHOTO nvarchar(max)=''
AS
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
  	-- Declaran las variables
  	-- ------------------------------------------------------------------------------------
	DECLARE
		@COMPLETED_STATUS VARCHAR(50)
		,@ACCEPTED_STATUS VARCHAR(50)
		,@TASK_TYPE VARCHAR(50)
		,@DELIVERY_TYPE VARCHAR(50)
		,@COMPLETED_MANIFEST INT
		,@MANIFEST_HEADER INT
	

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

  --
  SELECT @ACCEPTED_STATUS = VALUE
  FROM [SONDA].SWIFT_PARAMETER 
  WHERE GROUP_ID = 'TASK' AND PARAMETER_ID = 'ACCEPTED_STATUS'

  -- ------------------------------------------------------------------------------------
  -- Se actualiza la tabla de tarea
  -- ------------------------------------------------------------------------------------
	UPDATE T 
	SET 
		T.TASK_STATUS=@TASK_STATUS
		,T.ASSIGNED_STAMP= GETDATE()
		,T.ASSIGEND_TO=@LOGIN
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
  			-- Actualizar el Header
  			-- ------------------------------------------------------------------------------------
            UPDATE [SONDA].[SWIFT_MANIFEST_DETAIL]
			SET 
				 REJECT_COMMENT=@REJECT_COMMENT
				,IMAGE_1=@PHOTO
				,LAST_UPDATE_BY=@LOGIN
				,LAST_UPDATE=GETDATE()
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
  			FROM [SONDA].[SWIFT_MANIFEST_HEADER] H 
            INNER JOIN [SONDA].[SWIFT_MANIFEST_DETAIL] D ON (D.CODE_MANIFEST_HEADER=H.MANIFEST_HEADER)
  			INNER JOIN [SONDA].[SWIFT_TASKS] T ON (D.DELIVERY_TASK = T.TASK_ID)		
   			WHERE T.TASK_STATUS  != 'COMPLETED'
            AND D.CODE_MANIFEST_HEADER=@MANIFEST_HEADER
			--
			PRINT '@COMPLETED_MANIFEST: ' + CAST(@COMPLETED_MANIFEST AS VARCHAR) 
			-- ------------------------------------------------------------------------------------
  			-- Actualiza el status del manifiesto de entrega
  			-- ------------------------------------------------------------------------------------
			IF(@COMPLETED_MANIFEST = 1)
			BEGIN
				UPDATE [SONDA].[SWIFT_MANIFEST_HEADER]
				SET [STATUS] = @COMPLETED_STATUS
				WHERE [MANIFEST_HEADER]= @MANIFEST_HEADER	
			END 
		END
		
END
