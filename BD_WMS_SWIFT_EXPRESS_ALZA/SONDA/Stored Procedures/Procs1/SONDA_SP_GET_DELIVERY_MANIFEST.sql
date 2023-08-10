-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-03-2016
-- Description:			Obtiene los encabezados de los manifiestos en el rango de fecha

-- Modificacion 05-10-2016 @ A-Team Sprint 2
					-- alberto.ruiz
					-- Se eliminaron join porque la tabla ya tiene esos campos
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SONDA_SP_GET_DELIVERY_MANIFEST]
					@START_DATE = '20160101 00:00:00.000'
					,@END_DATE = '20160401 00:00:00.000'
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DELIVERY_MANIFEST
(	
	@START_DATE DATETIME
	,@END_DATE DATETIME
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @COMPLETED_STATUS VARCHAR(25) = 'COMPLETED_STATUS'
	
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
	-- Obtiene la agrupacion de las tareas finalizadas de los detalles
	-- ------------------------------------------------------------------------------------
	SELECT 
		D.CODE_MANIFEST_HEADER AS MANIFEST_HEADER
		,COUNT(T.TASK_STATUS) AS TOTAL_DETAIL
		,SUM(CASE WHEN TS.PARAMETER_ID = @COMPLETED_STATUS THEN 1 ELSE 0 END) AS TOTAL_COMPLETED
    ,MAX(T.DISTANCE_IN_KMS) AS DISTANCE_IN_KMS
	INTO #DETAIL
	FROM [SONDA].[SWIFT_MANIFEST_DETAIL] D
	INNER JOIN [SONDA].[SWIFT_TASKS] T ON (
		D.DELIVERY_TASK = T.TASK_ID
	)
	INNER JOIN #TASK_STATUS TS ON (
		T.TASK_STATUS = TS.TASK_STATUS
	)
	WHERE T.CREATED_STAMP BETWEEN @START_DATE AND @END_DATE
	GROUP BY D.CODE_MANIFEST_HEADER
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los encabezados de los manifiestos en las fechas indicadas
	-- ------------------------------------------------------------------------------------
	SELECT
		H.MANIFEST_HEADER
		,H.CODE_MANIFEST_HEADER
		,H.CODE_DRIVER
		,H.NAME_DRIVER
		,H.CODE_VEHICLE
		,H.PLATE_VEHICLE
		,H.COMMENTS
		,TS.DESCRIPTION_STATUS AS [STATUS]
		,H.CODE_ROUTE
		,H.NAME_ROUTE
		,H.CREATED_DATE
		,H.ACCEPTED_STAMP
		,H.COMPLETED_STAMP
		,ISNULL(CONVERT(INT,((DET.TOTAL_COMPLETED * 100) / DET.TOTAL_DETAIL)),0) AS PERCENTAGE
    ,DET.DISTANCE_IN_KMS
    ,ISNULL(H.MANIFEST_SOURCE, 'SWIFT_EXPRESS') AS MANIFEST_SOURCE
	FROM [SONDA].[SWIFT_MANIFEST_HEADER] H
	LEFT JOIN #DETAIL DET ON (
		H.MANIFEST_HEADER = DET.MANIFEST_HEADER
	)
	INNER JOIN #TASK_STATUS TS ON (
		H.[STATUS] = TS.TASK_STATUS
	)
	WHERE H.CREATED_DATE BETWEEN @START_DATE AND @END_DATE
END
