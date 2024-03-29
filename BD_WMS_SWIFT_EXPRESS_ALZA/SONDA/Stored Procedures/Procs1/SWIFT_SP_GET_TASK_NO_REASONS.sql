﻿
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	23-05-2016
-- Description:			Obtiene todas las impresoras o la impresora indicada

-- MODIFICADO:				diego.as
-- Fecha de Modificacion:	17-10-2016 @ TEAM-A Sprint 3


/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_GET_TASK_NO_REASONS]
					@START_DATE = '20150101'
					,@END_DATE = '20170101'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TASK_NO_REASONS]
(	
	@START_DATE DATE
	,@END_DATE DATE
)
AS
BEGIN
	SELECT 
		[T].[TASK_ID]
		,[T].[TASK_TYPE]
		,CASE [T].[TASK_TYPE]
			WHEN 'PRESALE' THEN 'Preventa'
			WHEN 'TAKE_INVENTORY' THEN 'Toma de Inventario'
			WHEN 'SALE' THEN 'Venda Directa'
			ELSE [T].[TASK_TYPE]
		END [TASK_TYPE_DESCIPTION]
		,[T].[SCHEDULE_FOR]
		,[T].[ASSIGEND_TO]
		,[U].[NAME_USER]
		,[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,[T].[TASK_STATUS]
		,CASE [T].[TASK_STATUS]
			WHEN 'ASSIGNED' THEN 'Asignada'
			WHEN '' THEN 'Aceptada'
			WHEN '' THEN 'Completada'
			ELSE [T].[TASK_STATUS]
		END [TASK_STATUS_DESCIPTION]
		,[T].[COSTUMER_CODE]
		,[T].[COSTUMER_NAME]
		,[T].[CUSTOMER_PHONE]
		,[T].[TASK_ADDRESS]
		,[T].[COMPLETED_SUCCESSFULLY]
		,CASE 
			WHEN CAST([T].[COMPLETED_SUCCESSFULLY] AS VARCHAR) IS NULL THEN 'Sin Operar'
			WHEN CAST([T].[COMPLETED_SUCCESSFULLY] AS VARCHAR) = '1' THEN 'Realizo Gestión'			
			ELSE 'No Gestión'
		END [COMPLETED_SUCCESSFULLY_DESCRIPTION]
		,CASE 
			WHEN [T].[COMPLETED_SUCCESSFULLY] = 1 THEN 'Realizo Gestión'
			WHEN [T].[COMPLETED_SUCCESSFULLY] = 0 THEN ISNULL([T].[REASON],'No Gestión')
			WHEN [T].[TASK_STATUS] = 'ASSIGNED' THEN 'No Operada'
			WHEN [T].[TASK_STATUS] = 'COMPLETED' AND [T].[COMPLETED_STAMP] IS NOT NULL AND [T].[COMPLETED_SUCCESSFULLY] IS NULL THEN 'Realizo Gestión'
			ELSE 'No Gestión'
		END [REASON]
		,ISNULL([T].[COMPLETED_STAMP],[T].[SCHEDULE_FOR]) [COMPLETED_STAMP]
	FROM [SONDA].[SWIFT_TASKS] [T]
	INNER JOIN [SONDA].[USERS] [U] ON (
		[T].[ASSIGEND_TO] = [U].[LOGIN]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[U].[SELLER_ROUTE] = [R].[CODE_ROUTE]
	)
	WHERE ISNULL([T].[COMPLETED_SUCCESSFULLY],0) != 1
		AND [T].[SCHEDULE_FOR] BETWEEN @START_DATE AND @END_DATE
		--AND [T].[TASK_TYPE] NOT IN ('RECEPTION','PICKING','DRAFT')
		--AND [T].[TASK_TYPE] = 'PRESALE'
END
