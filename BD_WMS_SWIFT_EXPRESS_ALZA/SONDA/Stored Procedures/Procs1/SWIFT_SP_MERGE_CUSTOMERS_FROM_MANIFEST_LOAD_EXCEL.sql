-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2016-10-21 @TEAM-A sprint 3
-- Description:			    SP que importa clientes

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].SWIFT_SP_MERGE_CUSTOMERS_FROM_MANIFEST_LOAD_EXCEL
  @CODE_CUSTOMER = 'D001'
, @NAME_CUSTOMER = 'Rutapruba'
, @GPS = '14.638729, -90.575591'
, @LOGIN = 'gerente@SONDA'
, @ADRESS_CUSTOMER = '2AV 8-25 Z3 B. SN. FCO.'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_MERGE_CUSTOMERS_FROM_MANIFEST_LOAD_EXCEL @CODE_CUSTOMER VARCHAR(50)
, @NAME_CUSTOMER VARCHAR(50)
, @GPS VARCHAR(MAX)
, @LOGIN VARCHAR(50)
, @ADRESS_CUSTOMER VARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    MERGE [SONDA].SWIFT_CUSTOMERS TRG
    USING (SELECT
        @CODE_CUSTOMER AS CODE_CUSTOMER
       ,@NAME_CUSTOMER AS NAME_CUSTOMER
       ,@GPS AS GPS
       ,@ADRESS_CUSTOMER AS ADRESS_CUSTOMER) AS SRC
    ON TRG.CODE_CUSTOMER = @CODE_CUSTOMER
    WHEN MATCHED
      THEN UPDATE
        SET TRG.[CODE_CUSTOMER] = SRC.[CODE_CUSTOMER]
           ,TRG.[NAME_CUSTOMER] = SRC.[NAME_CUSTOMER]
           ,TRG.[GPS] = ISNULL(@GPS, '0,0')
           ,TRG.LATITUDE = RTRIM(LTRIM(SUBSTRING(@GPS, 1, CHARINDEX(',', @GPS) - 1)))
           ,TRG.LONGITUDE = RTRIM(LTRIM(SUBSTRING(@GPS, CHARINDEX(',', @GPS) + 1, LEN(@GPS))))
           ,LAST_UPDATE = GETDATE()
           ,LAST_UPDATE_BY = @LOGIN
           ,ADRESS_CUSTOMER = @ADRESS_CUSTOMER
    WHEN NOT MATCHED
      THEN INSERT ([CODE_CUSTOMER]
        , [NAME_CUSTOMER]
        , [GPS]
        , LATITUDE
        , LONGITUDE
        , LAST_UPDATE
        , LAST_UPDATE_BY
        , ADRESS_CUSTOMER)
          VALUES (SRC.[CODE_CUSTOMER], 
                  SRC.[NAME_CUSTOMER],  
                  ISNULL(@GPS, '0,0'), 
                  RTRIM(LTRIM(SUBSTRING(@GPS, 1, CHARINDEX(',', @GPS) - 1))), 
                  RTRIM(LTRIM(SUBSTRING(@GPS, CHARINDEX(',', @GPS) + 1, LEN(@GPS)))), 
                  GETDATE(), 
                  @LOGIN, 
                  @ADRESS_CUSTOMER);

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH

END
