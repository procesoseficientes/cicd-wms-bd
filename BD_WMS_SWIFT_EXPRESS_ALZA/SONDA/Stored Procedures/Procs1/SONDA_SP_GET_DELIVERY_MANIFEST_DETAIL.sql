-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-03-2016
-- Description:			Obtiene los encabezados de los manifiestos en el rango de fecha

-- Modificacion 05-Oct-16
					-- alberto.ruiz
					-- Se agregao el campo [STATUS]

--Modificaco:		rudi.garcia
-- Create date:    10-10-2016 @ A-TEAM Sprint 2
-- Description:    Se agregaron los siguientes campos: ASSIGNED_STAMP, ACCEPTED_STAMP, COMPLETED_STAMP, TASK_SEQ    

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SONDA_SP_GET_DELIVERY_MANIFEST_DETAIL]
					@MANIFEST_HEADER = 65
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DELIVERY_MANIFEST_DETAIL
(	
	@MANIFEST_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los estados de las variablas
	-- ------------------------------------------------------------------------------------
	SELECT 
		PARAMETER_ID
		,P.VALUE AS TASK_STATUS
		,(CASE P.PARAMETER_ID
			WHEN 'ASSIGNED_STATUS' THEN 'ASIGNADO'
			WHEN 'ACCEPTED_STATUS' THEN 'ACEPTADO'			
			WHEN 'COMPLETED_STATUS' THEN 'COMPLETADO'
			WHEN 'PENDING_STATUS' THEN 'PENDIENTE'
			ELSE P.PARAMETER_ID
		END) AS [DESCRIPTION_STATUS]
	INTO #TASK_STATUS
	FROM [SONDA].SWIFT_PARAMETER P
	WHERE GROUP_ID = 'TASK'
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los detalles del encabezado del manifiesto
	-- ------------------------------------------------------------------------------------
	SELECT 
		D.MANIFEST_DETAIL
		,D.CODE_MANIFEST_HEADER
		,D.CODE_PICKING
		,D.LAST_UPDATE
		,D.LAST_UPDATE_BY
		,D.CODE_CUSTOMER
		,T.COSTUMER_NAME AS CUSTOMER_NAME
		,D.REFERENCE
		,D.DOC_SAP_RECEPTION
		,D.DOC_SAP_PICKING
		,D.TYPE
		,D.DELIVERY_TASK
		,D.REJECT_COMMENT
		,D.IMAGE_1
		,TS.DESCRIPTION_STATUS AS [STATUS]
		,T.EXPECTED_GPS
		,ISNULL(SUBSTRING(T.EXPECTED_GPS, 1, CHARINDEX(',', T.EXPECTED_GPS) - 1),0) AS [EXPECTED_GPS_LATITUDE]
		,ISNULL(SUBSTRING(T.EXPECTED_GPS, CHARINDEX(',', T.EXPECTED_GPS) + 1, LEN(T.EXPECTED_GPS)),0) AS [EXPECTED_GPS_LONGITUDE]
		,T.POSTED_GPS
		,ISNULL(SUBSTRING(T.POSTED_GPS, 1, CHARINDEX(',', T.POSTED_GPS) - 1),0) AS [POSTED_GPS_LATITUDE]
		,ISNULL(SUBSTRING(T.POSTED_GPS, CHARINDEX(',', T.POSTED_GPS) + 1, LEN(T.POSTED_GPS)),0) AS [POSTED_GPS_LONGITUDE]
		,DBO.SONDA_FN_CALCULATE_DISTANCE(T.EXPECTED_GPS,T.POSTED_GPS) [GPS_DISTANCE]
		,TS.DESCRIPTION_STATUS
		,[D].[STATUS]    
    ,T.ASSIGNED_STAMP
    ,T.ACCEPTED_STAMP
    ,T.COMPLETED_STAMP
    ,T.TASK_SEQ    
	FROM [SONDA].[SWIFT_MANIFEST_DETAIL] D
	INNER JOIN [SONDA].[SWIFT_TASKS] T ON (
		D.DELIVERY_TASK = T.TASK_ID
	)
	INNER JOIN #TASK_STATUS TS ON (
		T.TASK_STATUS = TS.TASK_STATUS
	)  
	WHERE D.CODE_MANIFEST_HEADER = @MANIFEST_HEADER
  ORDER BY T.TASK_SEQ
END
