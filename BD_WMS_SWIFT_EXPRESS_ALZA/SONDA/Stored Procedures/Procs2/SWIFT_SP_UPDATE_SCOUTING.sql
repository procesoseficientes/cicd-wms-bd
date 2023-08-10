-- =============================================
-- Autor:        PEDRO LOUKOTA
-- Fecha de Creacion:   24-11-2015
-- Description:      ACTUALIZA EL ESTADO DEL SCOUTING

-- Modificacion: 06-07-2016
    -- Autor: diego.as
    -- Descripcion: Se ordeno el codigo y se corrigio el ejemplo de ejecucion 

-- Modificacion: 14-07-2016
    -- Autor: rudi.garcia
    -- Descripcion: Se agrego la validacion si el scouting tiene una etiqueta asociada. 

-- Modificacion: 25-07-2017
    -- Autor: rudi.garcia
    -- Descripcion: Se cambio la tabla "[SWIFT_TAG_X_CUSTOMER_NEW]" por la vista "[SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW]" para la validación de etiquetas, esto para que busque tambien los de SondaPos

/*
-- Ejemplo de Ejecucion:        
    --
    exec [SONDA].[SWIFT_SP_UPDATE_SCOUTING]
      @STATUS = 'ACCEPTED'        
      ,@USER = 'GERENTE@SONDA'        
      ,@COMMENTS = 'PRUEBA SP PARA ACTUALIZAR STATUS DEL CLIENTE DE SCOUTING'      
      ,@CUSTOMER = 'BO-3145'
    --        
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_SCOUTING
  @STATUS VARCHAR(20),
  @USER VARCHAR(50),
  @COMMENTS VARCHAR(250),
  @CUSTOMER VARCHAR(250)
AS
BEGIN TRY
  SET NOCOUNT ON;
  DECLARE @HAS_TAG INT = 0

  SELECT TOP 1 @HAS_TAG = 1
  FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW] CN
  WHERE CN.CUSTOMER = @CUSTOMER

  IF @HAS_TAG = 0 BEGIN
    SELECT  -1 as Resultado , 'El Cliente seleccionado no tiene Etiquetas asignadas, por favor agregue por lo menos una etiqueta.' Mensaje ,  @@ERROR Codigo
  END
  ELSE BEGIN 
      --
    UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
    SET 
      [LAST_UPDATE] = GETDATE()
      ,[LAST_UPDATE_BY] = @USER
      ,[STATUS] = @STATUS
      ,[COMMENTS] = @COMMENTS
    WHERE [CODE_CUSTOMER] = @CUSTOMER
    --
    IF @@error = 0 BEGIN
      SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
    END    
    ELSE BEGIN    
      SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
    END
  END  
  --
END TRY
BEGIN CATCH     
   SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
