-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-05-04 @ Team ERGON - Sprint@Ganandorf
-- Description:	 Se agrega procedimiento que obtiene el detalle de una reubicación para el administrador de tareas 

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agrega filtro de clase 

-- Modificacion 04/11/2018 @ G-Force Sprint Buho
	-- diego.as
	-- Se corrige multiplexion de cantidad en la consulta del administrador de tareas

/*
-- Ejemplo de Ejecucion:
		exec 	[wms].OP_WMS_SP_GET_TASK_DETAIL_FOR_REALLOC @WAVE_PICKING_ID = 4487, @LOGIN  = 'ADMIN'
*/
-- =============================================
CREATE  PROCEDURE [wms].OP_WMS_SP_GET_TASK_DETAIL_FOR_REALLOC
(
     @WAVE_PICKING_ID INT
    ,@LOGIN VARCHAR(25)
	,@CLASS VARCHAR(MAX) = NULL	
)
AS
	DECLARE @TB_USERS TABLE
		(
		 [LOGIN_ID] VARCHAR(25)
		,[LOGIN_NAME] VARCHAR(50)
		);
	--
	CREATE TABLE #CLASS(
		CLASS_ID INT PRIMARY KEY
	)
	--

	-- ------------------------------------------------------------------------------------
	-- Arma la tabla temporal de clases
	-- ------------------------------------------------------------------------------------
	IF(@CLASS = '' OR @CLASS IS NULL OR @CLASS = '|')
	BEGIN
		INSERT INTO [#CLASS]
	    SELECT [CLASS_ID]
		FROM [wms].[OP_WMS_CLASS]
	END
	ELSE	
	BEGIN
		INSERT INTO [#CLASS]
		SELECT
			[C].[VALUE] AS [CLASS_ID]
		FROM
			[wms].[OP_WMS_FN_SPLIT](@CLASS, '|') [C];
	END

	-- --------------------
	-- Se obtine los usuarios tipo operador relacionados al login enviado
	-- --------------------

	INSERT  INTO @TB_USERS
			(
			 [LOGIN_ID]
			,[LOGIN_NAME]
			)
    EXEC [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER] @LOGIN;

	SELECT DISTINCT
		[A].[WAVE_PICKING_ID]
	   ,[A].[TASK_ASSIGNEDTO] [ASSIGNED_TO]
	   ,SUM([A].[QUANTITY_PENDING]) AS QTY
	   ,SUM([A].[QUANTITY_ASSIGNED]) AS QTY_DOC
	   ,[A].[MATERIAL_ID]
	   ,[A].[BARCODE_ID]
	   ,[A].[MATERIAL_NAME]
	   ,(CASE MIN(A.IS_COMPLETED)
		   WHEN 0 THEN CASE MIN(A.[IS_ACCEPTED])
						 WHEN 0 THEN 'INCOMPLETA'
						 WHEN 1 THEN 'ACEPTADA'
					   END
		   ELSE 'COMPLETA'
		 END) AS STATUS
	   ,MAX([A].[TASK_COMMENTS]) AS [TASK_COMMENTS]
	   ,[A].[TASK_SUBTYPE]
	   ,[CL].[CLASS_ID]
	   ,[CL].[CLASS_NAME]
	FROM
		[wms].OP_WMS_TASK_LIST AS A
	LEFT JOIN @TB_USERS [U] ON ([U].[LOGIN_ID] = [A].[TASK_ASSIGNEDTO])
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [A].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_CLASS] [CL] ON [CL].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
	INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = [CL].[CLASS_ID]
	WHERE
		[A].[TASK_TYPE] = 'TAREA_REUBICACION'
		AND [A].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	GROUP BY
		[A].[WAVE_PICKING_ID]
	   ,[A].[TASK_ASSIGNEDTO]
	   ,[A].[MATERIAL_ID]
	   ,[A].[BARCODE_ID]
	   ,[A].[MATERIAL_NAME]
	   ,[A].[IS_ACCEPTED]
	   ,[A].[TASK_SUBTYPE]
	   ,[CL].[CLASS_ID]
	   ,[CL].[CLASS_NAME];