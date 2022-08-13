-- =============================================
-- Autor:	              rudi.garcia
-- Fecha de Creacion: 	2017-09-01 @Team REBORN - Sprint Collin
-- Description:	        Se crea el sp para insertar el estado del material.

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_ADD_STATUS_OF_MATERIAL_BY_LICENSE] @STATUS_CODE ='ESTADO_DEFAULT' 
															,@STATUS_NAME = 'PRUEBA'
                                                            ,@BLOCKS_INVENTORY = 0
                                                            ,@ALLOW_REALLOC = 0
                                                            ,@TARGET_LOCATION = '12313'
                                                            ,@DESCRIPTION = 'DESC PRUEBAS'
                                                            ,@COLOR = ''

			SELECT *
      FROM [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_STATUS_OF_MATERIAL_BY_LICENSE] (@STATUS_CODE VARCHAR(50), @STATUS_NAME VARCHAR(100)
, @BLOCKS_INVENTORY INT
, @ALLOW_REALLOC INT
, @TARGET_LOCATION VARCHAR(25)
, @DESCRIPTION VARCHAR(200)
, @COLOR VARCHAR(20)
, @LICENSE_ID NUMERIC
)
AS

  DECLARE @ID INT;

  BEGIN TRY
    INSERT [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] ([STATUS_CODE]
    , [STATUS_NAME]
    , [BLOCKS_INVENTORY]
    , [ALLOW_REALLOC]
    , [TARGET_LOCATION]
    , [DESCRIPTION]
    , [COLOR]
    , [LICENSE_ID]
    )
      VALUES (@STATUS_CODE, @STATUS_NAME, @BLOCKS_INVENTORY, @ALLOW_REALLOC, @TARGET_LOCATION, @DESCRIPTION, @COLOR, @LICENSE_ID);


    SET @ID = SCOPE_IDENTITY()

    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo]
     ,CAST(@ID AS VARCHAR(50)) [DbData];

  END TRY
  BEGIN CATCH

    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo]
	 , ''[DbData];

  END CATCH