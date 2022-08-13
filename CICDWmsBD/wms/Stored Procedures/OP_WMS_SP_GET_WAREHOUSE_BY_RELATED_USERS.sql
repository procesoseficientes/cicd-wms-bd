-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-17 @ Team ERGON - Sprint ERGON 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_RELATED_USERS] @LOGIN='ADMIN' ,@OPERATORS='ACAMACHO|BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_RELATED_USERS] (@LOGIN VARCHAR(50)
, @OPERATORS VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --
  -- ------------------------------------------------------------------------------------
  -- Declaramos Variables
  -- ------------------------------------------------------------------------------------

  DECLARE @ID_OPERADOR INT
         ,@OPERADOR VARCHAR(50)


  -- ------------------------------------------------------------------------------------
  -- Se Obtienen Los OPERADORES
  -- ------------------------------------------------------------------------------------

  SELECT
    * INTO #OPERATORS
  FROM [wms].[OP_WMS_FN_SPLIT](@OPERATORS, '|') [OP]

  -- ------------------------------------------------------------------------------------
  -- Se Obtienen las BODEGAS del LOGIN
  -- ------------------------------------------------------------------------------------
  SELECT
    [W].[WAREHOUSE_ID]
   ,[W].[NAME]
   ,[W].[COMMENTS] INTO #WAREHOUSES_LOGIN
  FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
  INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
    ON [WU].[WAREHOUSE_ID] = [W].[WAREHOUSE_ID]
  WHERE [WU].[LOGIN_ID] = @LOGIN
  -- ------------------------------------------------------------------------------------
  -- Ciclo para obtener las BODEGAS COMUNES entre OPERADORES y LOGIN
  -- ------------------------------------------------------------------------------------
  PRINT '--> Inicia el ciclo'
  --
  WHILE EXISTS (SELECT TOP 1
        1
      FROM [#OPERATORS] [O]
      ORDER BY [O].[ID])
  BEGIN

    SELECT TOP 1
      @ID_OPERADOR = [O].[ID]
     ,@OPERADOR = [O].[VALUE]
    FROM [#OPERATORS] [O]
    ORDER BY [O].[ID]
    --
    PRINT '-----> @OPERADOR: ' + @OPERADOR

    -- ------------------------------------------------------------------------------------
    -- Se obtienen las BODEGAS IGUALES al OPERADOR EN CICLO
    -- ------------------------------------------------------------------------------------
    SELECT
      [WU].[WAREHOUSE_ID] INTO #WAREHOUSES_OPERADOR
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
    WHERE [WU].[LOGIN_ID] = @OPERADOR

    DELETE W
      FROM [#WAREHOUSES_LOGIN] [W]
      LEFT JOIN [#WAREHOUSES_OPERADOR] [WO]
        ON [W].[WAREHOUSE_ID] = [WO].[WAREHOUSE_ID]
    WHERE [WO].[WAREHOUSE_ID] IS NULL

    DROP TABLE #WAREHOUSES_OPERADOR

    DELETE FROM [#OPERATORS]
    WHERE [ID] = @ID_OPERADOR
  END

  SELECT
  
  [W].[WAREHOUSE_ID]
 ,[W].[NAME]
 ,[W].[COMMENTS]
  FROM [#WAREHOUSES_LOGIN] [W]



END