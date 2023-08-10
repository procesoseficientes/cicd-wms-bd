-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			Este SP genera tareas de las ordenes de venta que tenga la fecha de entrega este en el rango de días configurado

--Acuatlización: diego.as
--Fecha de Actualización: 12-05-2016
--Motivo: Se modifico para usara la funcion [SONDA].[SWIFT_FN_GET_PARAMETER] para traer el parametro de Dias Draft.
-- 		  Ademas, se agregaron las columnas H.SALES_ORDER_ID, H.IS_VOID a la insercion de la tabla temporal para usarlos
--		  al momento de la insercion de tareas y plan de ruta.



-- TOMAR EN CUENTA PARA EL CAMBIO DE AND H.IS_READY_TO_SEND=1
/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GENERATE_DRAFT_TASKS]  
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GENERATE_DRAFT_TASKS
	
AS  
	BEGIN	
	DECLARE @DATE DATETIME = GETDATE()
	
	-- -----------------------------------------------------------------
	-- Obtiene parametro
	-- -----------------------------------------------------------------	
	DECLARE @DRAFTDAYS INT
	SET @DRAFTDAYS = [SONDA].[SWIFT_FN_GET_PARAMETER] ('SALES_ORDER','DRAFT_TASK_DAYS') 

	-- -----------------------------------------------------------------
	-- Obtiene las tareas
	-- -----------------------------------------------------------------
		SELECT DISTINCT 
			'DRAFT' AS TASK_TYPE
			,U.LOGIN
			,c.GPS
			,1 AS PRIORITY
			,C.CODE_CUSTOMER
			,ISNULL(C.NAME_CUSTOMER,'...') AS NAME_CUSTOMER
			,COALESCE(C.PHONE_CUSTOMER,'No tiene telefono') AS PHONE_CUSTOMER
			,COALESCE(C.ADRESS_CUSTOMER,'No tiene direccion') AS ADRESS_CUSTOMER 
			,H.DELIVERY_DATE
			,H.IS_DRAFT			
			,U.SELLER_ROUTE AS CODE_ROUTE
			,NULL EMAIL_TO_CONFIRM
			,H.SALES_ORDER_ID
			,H.IS_VOID
		INTO #TAREAS
		FROM [SONDA].[SONDA_SALES_ORDER_HEADER] H
		INNER JOIN [SONDA].USERS U ON (H.POS_TERMINAL = U.SELLER_ROUTE)
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] C ON (H.CLIENT_ID = C.CODE_CUSTOMER)
		
		WHERE (H.DELIVERY_DATE - @DRAFTDAYS) <= GETDATE() 
			AND H.IS_DRAFT = 1 
			AND H.IS_VOID = 0
			

	-- -----------------------------------------------------------------
	-- Inserta en la tabla SWIFT_TASKS
	-- -----------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_TASKS]
	(
		TASK_TYPE
		,TASK_DATE
		,SCHEDULE_FOR
		,CREATED_STAMP
		,ASSIGEND_TO
		,ASSIGNED_BY
		,ASSIGNED_STAMP
		,CANCELED_STAMP
		,CANCELED_BY
		,ACCEPTED_STAMP
		,COMPLETED_STAMP
		,RELATED_PROVIDER_CODE
		,RELATED_PROVIDER_NAME
		,EXPECTED_GPS
		,POSTED_GPS
		,TASK_STATUS
		,TASK_COMMENTS
		,TASK_SEQ
		,REFERENCE
		,SAP_REFERENCE
		,COSTUMER_CODE
		,COSTUMER_NAME
		,RECEPTION_NUMBER
		,PICKING_NUMBER
		,COUNT_ID
		,ACTION
		,SCANNING_STATUS
		,ALLOW_STORAGE_ON_DIFF
		,CUSTOMER_PHONE
		,TASK_ADDRESS
		,VISIT_HOUR
		,ROUTE_IS_COMPLETED
		,EMAIL_TO_CONFIRM
    ,IN_PLAN_ROUTE
    ,CREATE_BY
	)
	SELECT 
		T.TASK_TYPE
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,T.LOGIN
		,'Proceso diario'
		,GETDATE()
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,T.GPS
		,NULL
		,'ASSIGNED'
		,'Orden de Venta Draft a punto de caducar'
		,T.PRIORITY
		,NULL
		,NULL
		,T.CODE_CUSTOMER
		,ISNULL(T.NAME_CUSTOMER,'...')
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,T.PRIORITY
		,COALESCE(T.PHONE_CUSTOMER,'No tiene telefono') PHONE_CUSTOMER
		,COALESCE(T.ADRESS_CUSTOMER,'No tiene direccion') ADRESS_CUSTOMER 
		,NULL
		,NULL
		,NULL	
    ,1
    ,'BY_CALENDAR'
	FROM #TAREAS T
	WHERE (T.DELIVERY_DATE - @DRAFTDAYS) <= GETDATE() 
		AND T.IS_DRAFT = 1
		AND T.IS_VOID = 0 

	-- -----------------------------------------------------------------
	-- Inserta en la tabla SONDA_ROUTE_PLAN
	-- -----------------------------------------------------------------
	INSERT INTO [SONDA].[SONDA_ROUTE_PLAN]
	(
		TASK_ID
		,CODE_FREQUENCY
		,SCHEDULE_FOR
		,ASSIGNED_BY
		,DOC_PARENT
		,EXPECTED_GPS
		,TASK_COMMENTS
		,TASK_SEQ
		,TASK_ADDRESS
		,RELATED_CLIENT_PHONE_1
		,EMAIL_TO_CONFIRM
		,RELATED_CLIENT_CODE
		,RELATED_CLIENT_NAME
		,TASK_PRIORITY
		,TASK_STATUS
		,SYNCED
		,NO_PICKEDUP
		,NO_VISIT_REASON
		,IS_OFFLINE
		,DOC_NUM
		,TASK_TYPE
		,TASK_DATE
		,CREATED_STAMP
		,ASSIGEND_TO
		,CODE_ROUTE
		,TARGET_DOC
    ,IN_PLAN_ROUTE
    ,CREATE_BY
	)
	SELECT
		T.TASK_ID
		,'DRAFT' 
		,T.TASK_DATE
		,T.ASSIGNED_BY
		,0
		,T.EXPECTED_GPS
		,ISNULL(T.TASK_COMMENTS,'...')
		,T.TASK_SEQ
		,T.TASK_ADDRESS
		,F.PHONE_CUSTOMER
		,F.EMAIL_TO_CONFIRM
		,T.COSTUMER_CODE
		,ISNULL(T.COSTUMER_NAME,'...')
		,F.PRIORITY
		,T.TASK_STATUS
		,1
		,NULL
		,NULL
		,1
		,NULL
		,T.TASK_TYPE
		,T.TASK_DATE
		,CREATED_STAMP
		,T.ASSIGEND_TO
		,F.CODE_ROUTE
		,F.SALES_ORDER_ID
    ,1
    ,'BY_CALENDAR'
	FROM #TAREAS F
	LEFT JOIN [SONDA].[SWIFT_TASKS] T ON (
		T.ASSIGEND_TO = F.LOGIN
		AND T.COSTUMER_CODE = F.CODE_CUSTOMER
		AND T.TASK_TYPE = F.TASK_TYPE
		AND T.TASK_STATUS = 'ASSIGNED'
		AND T.TASK_DATE = CONVERT(DATE,@DATE)
	)
END
