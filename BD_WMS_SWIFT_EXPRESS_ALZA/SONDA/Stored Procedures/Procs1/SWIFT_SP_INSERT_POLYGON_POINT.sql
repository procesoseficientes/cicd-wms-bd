
-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	19-07-2016
-- Description:			inserta un punto de poligono 

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_INSERT_POLYGON_POINT]
					@POLYGON_ID = 10
					,@POSITION = 21
					,@LATITUDE = '14.6318799'
					,@LONGITUDE = '-90.4952697'

          ,@POLYGON_TYPE = 'REGION'
          ,@POLYGON_SUB_TYPE = NULL
			
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_POLYGON_POINT] (@POLYGON_ID INT
, @POSITION INT
, @LATITUDE VARCHAR(250)
, @LONGITUDE VARCHAR(250)

, @POLYGON_TYPE VARCHAR(250)
, @POLYGON_SUB_TYPE VARCHAR(250) = NULL)
AS
BEGIN
  --
  BEGIN TRY
    --
        INSERT INTO [SONDA].[SWIFT_POLYGON_POINT] (POLYGON_ID
        , POSITION
        , LATITUDE
        , LONGITUDE)
          VALUES (@POLYGON_ID, @POSITION, @LATITUDE, @LONGITUDE)

        --
        IF @@error = 0
        BEGIN
          SELECT
            1 AS RESULTADO
           ,'Proceso Exitoso' MENSAJE
           ,0 CODIGO
           ,'0' DbData
        END
        ELSE
        BEGIN
          SELECT
            -1 AS RESULTADO
           ,ERROR_MESSAGE() MENSAJE
           ,@@ERROR CODIGO
           ,'0' DbData
        END

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS RESULTADO
     ,ERROR_MESSAGE() MENSAJE
     ,@@ERROR CODIGO
     ,'0' DbData
  END CATCH
END
