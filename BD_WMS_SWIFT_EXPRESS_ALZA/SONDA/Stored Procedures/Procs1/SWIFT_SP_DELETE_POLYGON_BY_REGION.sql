-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    19-06-2016
-- Description:    Elimina el poligono y los puntos del poligono a eliminar

-- Modificacion 29-08-2016 @ Sprint θ
-- alberto.ruiz
-- Se agrego llamado para borrar la ruta	

-- Modificacion 05-08-2016
-- alberto.ruiz
-- Se agrego parametro @IS_MULTIPOLYGON

-- Modificacion 16-Jan-17 @ A-Team Sprint Adeben
-- alberto.ruiz
-- Se ajusto para que elimine la cantidad de frecuencias que tiene asignadas el poligono

-- Modificacion 17-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se saca del if @IS_MULTIPOLYGON = 0 el delete de [SWIFT_FREQUENCY_X_CUSTOMER] y [SWIFT_FREQUENCY]

-- Modificacion 05-10-2017 @ Reborn Team Sprint Drache
-- alberto.ruiz
-- Tambien se agrego que elimina los clientes asociados a los poligonos tipo "region" o "sector"

/*	
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_DELETE_POLYGON_BY_REGION]
			@POLYGON_ID = 4154
		--
		SELECT * FROM [SONDA].[SWIFT_POLYGON] WHERE POLYGON_NAME = 'pacopaco'
		--
		SELECT * FROM [SONDA].SWIFT_ROUTES WHERE NAME_ROUTE = 'pacopaco'
*/
-- =========================================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_POLYGON_BY_REGION (@POLYGON_ID INT
, @IS_MULTIPOLYGON INT = 0
--,@TYPE_TASK VARCHAR(1000)
)
AS
BEGIN
  SET NOCOUNT ON;
  
  DECLARE @POLYGON_TYPE VARCHAR(250)

  SELECT    
    @POLYGON_TYPE = [P].[POLYGON_TYPE]
  FROM [SONDA].[SWIFT_POLYGON] [P]
  WHERE [P].[POLYGON_ID] = @POLYGON_ID
  --
  --BEGIN TRAN T1
  BEGIN TRY
    IF (SELECT
          COUNT([P].[POLYGON_ID])
        FROM [SONDA].[SWIFT_POLYGON] AS [P]
        WHERE [P].[POLYGON_ID_PARENT] = @POLYGON_ID)
      = 0
    BEGIN

      -- ------------------------------------------------------------------------------------
      -- Elimina los clientes cuando este es un poligono de region o sector
      -- ------------------------------------------------------------------------------------
      
      IF @POLYGON_TYPE = 'REGION' BEGIN
        
        DELETE [CGAP] 
        FROM [SONDA].[SWIFT_CUSTOMER_GPS_ASSOCIATE_TO_POLYGON] [CGAP] 
        INNER JOIN  [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP] ON (
          [CAP].[CODE_CUSTOMER] = [CGAP].[CODE_CUSTOMER]
        )
        WHERE [CAP].[POLYGON_ID] = @POLYGON_ID
        

        DELETE [CAP] 
        FROM [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP]
        WHERE [CAP].[POLYGON_ID] = @POLYGON_ID

       
      END
      ELSE IF (@POLYGON_TYPE = 'SECTOR') BEGIN
        DELETE [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] WHERE [POLYGON_ID] = @POLYGON_ID    
      END


      -- ------------------------------------------------------------------------------------
      -- Elimina los puntos del poligono
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_POLYGON_POINT]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina los clientes de la frecuencia cuando este es multipoligono
      -- ------------------------------------------------------------------------------------
      SELECT
        [POLYGON_ID]
       ,[TASK_TYPE] INTO [#TASK_BY_POLYGON]
      FROM [SONDA].[SWIFT_TASK_BY_POLYGON]
      WHERE [POLYGON_ID] = @POLYGON_ID
      --
      DELETE [FC]
        FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] [PC]
        INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [FC]
          ON (
          [FC].[CODE_CUSTOMER] = [PC].[CODE_CUSTOMER]
          )
        INNER JOIN [SONDA].[SWIFT_FREQUENCY] [F]
          ON (
          [F].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
          )
        INNER JOIN [#TASK_BY_POLYGON] [T]
          ON (
          [T].[POLYGON_ID] = [PC].[POLYGON_ID]
          AND [T].[TASK_TYPE] = [F].[TYPE_TASK]
          )
      WHERE [PC].[POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina la relacion entre poligono y ruta
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Valida si es multipoligono
      -- ------------------------------------------------------------------------------------
      IF @IS_MULTIPOLYGON = 0
      BEGIN
        -- ------------------------------------------------------------------------------------
        -- cuando no es multipoligono se
        -- ------------------------------------------------------------------------------------
        -- ELimina la ruta
        -- ------------------------------------------------------------------------------------
        DECLARE @CODE_ROUTE VARCHAR(50) = CONVERT(VARCHAR, @POLYGON_ID)
        --
        DELETE FROM [SONDA].[SWIFT_ROUTES]
        WHERE [CODE_ROUTE] = @CODE_ROUTE
      END

      -- ------------------------------------------------------------------------------------
      -- Eliminamos los clientes de la frecuencia
      -- ------------------------------------------------------------------------------------
      DELETE [FC]
        FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
        INNER JOIN [SONDA].[SWIFT_FREQUENCY] [F]
          ON (
          [F].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
          )
      WHERE [F].[POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina las frecuencias asociadas al poligono
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_FREQUENCY_BY_POLYGON]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Eliminamos las frecuencia
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_FREQUENCY]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina los clientes asociados al poligono
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina las tareas asociadas al poligono
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_TASK_BY_POLYGON]
      WHERE [POLYGON_ID] = @POLYGON_ID

      -- ------------------------------------------------------------------------------------
      -- Elimina el poligono
      -- ------------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_POLYGON]
      WHERE [POLYGON_ID] = @POLYGON_ID;      

      SELECT
        1 AS [RESULTADO]
       ,'Proceso Exitoso' [MENSAJE]
       ,0 [CODIGO]
    --
    --COMMIT TRAN T1;
    END
    ELSE
    BEGIN
      SELECT
        -1 AS [RESULTADO]
       ,'El poligono no se puede eliminar debido a que este tiene poligonos asociados' [MENSAJE]
       ,@@error [CODIGO]
    --
    --ROLLBACK TRAN T1;
    END
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [RESULTADO]
     ,ERROR_MESSAGE() [MENSAJE]
     ,@@error [CODIGO]
  --ROLLBACK TRAN T1;
  END CATCH;
END;
