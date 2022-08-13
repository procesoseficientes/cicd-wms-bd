-- =============================================
-- Autor:				        rudi.garcia
-- Fecha de Creacion: 	2017-01-13 @ TeamErgon Sprint Ergon III
-- Description:			    SP que obtiene el detalle de los picking desde una tarea.

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego el parametro @LOGIN para el filtrado de operadores releacionados al CD del login

-- Modificación:        hector.gonzalez
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint EPONA
-- Description:	        se cambio MAX por SUM en QUANTITY_PENDING y QUANTITY_ASSIGNED y se cambio QTY_DOC  para dejar el QUANTITY ASIGNED

-- Modificación:        hector.gonzalez
-- Fecha de Creacion: 	2017-05-17 Team ERGON - Sprint Sheik
-- Description:	        Se quito join a OP_WMS_NEXT_PICKING_DEMAND_HEADER 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-17 ErgonTeam@Sheik
-- Description:	 Se estandariza los nombres de los campos del resultado.

-- Modificacion 7/17/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se cambia de SUM a MAX en el mostrado de resultados para que no duplique los datos.

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-08-21 Nexus@AgeOfEmpires
-- Description:	 Se cambia MAX a SUM para que muestre el dato correcto. 


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-08-30 Nexus@Command&Conquer
-- Description:	 se modifica inner join a usuarios que está causando duplicidad de datos

-- Modificacion 10/6/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se agrega columna IN_PICKING_LINE

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
-- rodrigo.gomez
-- Se agrega filtro de clase 
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_PICKING]
					@WAVE_PICKING_ID=4883
					,@LOGIN=N'ADMIN'
					,@CLASS = '46' 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_PICKING]
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
CREATE TABLE [#CLASS]
    (
     [CLASS_ID] INT PRIMARY KEY
    );
  --

  -- ------------------------------------------------------------------------------------
  -- Arma la tabla temporal de clases
  -- ------------------------------------------------------------------------------------
IF (
    @CLASS = ''
    OR @CLASS IS NULL
    OR @CLASS = '|'
   )
BEGIN
    INSERT  INTO [#CLASS]
    SELECT
        [CLASS_ID]
    FROM
        [wms].[OP_WMS_CLASS];
END;
ELSE
BEGIN
    INSERT  INTO [#CLASS]
    SELECT
        [C].[VALUE] AS [CLASS_ID]
    FROM
        [wms].[OP_WMS_FN_SPLIT](@CLASS, '|') [C];
END;

  -- ------------------------------------------------------------------------------------
  -- Se obtine los usuarios tipo operador relacionados al login enviado
  -- ------------------------------------------------------------------------------------

INSERT  INTO @TB_USERS
        (
         [LOGIN_ID]
        ,[LOGIN_NAME]
        )
        EXEC [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER] @LOGIN;

INSERT  INTO @TB_USERS
SELECT
    [C].[PARAM_NAME]
   ,[C].[PARAM_NAME]
FROM
    [wms].[OP_WMS_CONFIGURATIONS] [C]
WHERE
    [C].[PARAM_TYPE] = 'SISTEMA'
    AND [C].[PARAM_GROUP] = 'LINEAS_PICKING';



SELECT DISTINCT
    [A].[WAVE_PICKING_ID]
   ,[TASK_ASSIGNEDTO] [ASSIGNED_TO]
   ,[A].[IN_PICKING_LINE]
   ,SUM([A].[QUANTITY_PENDING]) AS [QTY]
   ,SUM([QUANTITY_ASSIGNED]) - SUM([A].[QUANTITY_PENDING]) AS [QTY_DIFFERENCE]
   ,SUM([QUANTITY_ASSIGNED]) AS [QTY_DOC]
   ,MAX([PHT].[NUMERO_ORDEN]) AS [NUMERO_ORDEN_TARGET]
   ,[A].[MATERIAL_ID]
   ,[A].[BARCODE_ID]
   ,[A].[MATERIAL_NAME]
   ,(CASE MIN([A].[IS_COMPLETED])
       WHEN 0 THEN CASE MIN([A].[IS_ACCEPTED])
                     WHEN 0 THEN 'INCOMPLETA'
                     WHEN 1 THEN 'ACEPTADA'
                   END
       ELSE 'COMPLETA'
     END) AS [STATUS]
   ,MAX([A].[CODIGO_POLIZA_TARGET]) [CODIGO_POLIZA_TARGET]
   ,MAX([A].[TASK_COMMENTS]) AS [TASK_COMMENTS]
   ,CASE WHEN (
               MAX([W].[USE_PICKING_LINE]) = 1
               AND (
                    MAX([A].[IS_FROM_ERP]) = 1
                    OR MAX([A].[IS_FROM_SONDA]) = 1
                   )
              ) THEN 1
         ELSE 0
    END AS [USE_PICKING_LINE]
   ,[CL].[CLASS_ID]
   ,[CL].[CLASS_NAME]
FROM
    [wms].[OP_WMS_TASK_LIST] AS [A]
INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [A].[MATERIAL_ID]
INNER JOIN [#CLASS] [C] ON [C].[CLASS_ID] = CAST([M].[MATERIAL_CLASS] AS INT)
INNER JOIN [wms].[OP_WMS_CLASS] [CL] ON [CL].[CLASS_ID] = [C].[CLASS_ID]
LEFT JOIN @TB_USERS [U] ON ([U].[LOGIN_ID] = [A].[TASK_ASSIGNEDTO])
LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHT] ON (
                                                   [PHT].[DOC_ID] = [A].[DOC_ID_TARGET]
                                                   AND [PHT].[WAREHOUSE_REGIMEN] = [A].[REGIMEN]
                                                  )
LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [A].[WAREHOUSE_SOURCE] = [W].[WAREHOUSE_ID]
WHERE
    [A].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
    AND [A].[TASK_TYPE] = 'TAREA_PICKING'
    AND (
         [A].[TASK_ASSIGNEDTO] = ''
         OR [U].[LOGIN_ID] IS NOT NULL
        )
GROUP BY
    [A].[WAVE_PICKING_ID]
   ,[A].[TASK_ASSIGNEDTO]
   ,[A].[MATERIAL_ID]
   ,[A].[BARCODE_ID]
   ,[A].[MATERIAL_NAME]
          --,[A].[CODIGO_POLIZA_TARGET]
   ,[A].[IS_ACCEPTED]
   ,[A].[IN_PICKING_LINE]
   ,[CL].[CLASS_ID]
   ,[CL].[CLASS_NAME];