/****** Object:  StoredProcedure [SONDA].[SWIFT_LOG_RELOCATE_INVENTORY]    Script Date: 03/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	03-12-2015
-- Description:			INSERTAR LA TABLA SWIFT_LOG_RELOCATE_INVENTORY


/*
-- Ejemplo de Ejecucion:				
				--
				EXEC [SONDA].[SWIFT_LOG_RELOCATE_INVENTORY]
				  GETDATE()
				 , @LAST_UPDATE_BY='User'
				 , @WAREHOUSE_TARGET='userware'
				 , @LOCATION_TARGET='userion'
				 , @WAREHOUSE_SOURCE='usersource'
				 , @LOCATION_SOURCE='userlocationsourse'
				 , @CODE_SKU='useruser'
				 , @QTY=100
				 , @SERIAL ='SERIE1'
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_LOG_RELOCATE]	
       @LAST_UPDATE_BY varchar(50)
      ,@WAREHOUSE_TARGET varchar(50)
      ,@LOCATION_TARGET varchar(50)
      ,@WAREHOUSE_SOURCE varchar(50)
      ,@LOCATION_SOURCE varchar(50)
      ,@CODE_SKU varchar(50)
      ,@QTY int
	  ,@SERIAL varchar(50)
AS
BEGIN TRY
 INSERT INTO [SONDA].[SWIFT_LOG_RELOCATE_INVENTORY]
			  (			   
	   [LAST_UPDATE]
      ,[LAST_UPDATE_BY]
      ,[WAREHOUSE_TARGET]
      ,[LOCATION_TARGET]
      ,[WAREHOUSE_SOURCE]
      ,[LOCATION_SOURCE]
      ,[CODE_SKU]
      ,[QTY]
	  ,[SERIAL]
			  ) 
			  VALUES 
			  (		  
	   GETDATE()
      ,@LAST_UPDATE_BY
      ,@WAREHOUSE_TARGET
      ,@LOCATION_TARGET
      ,@WAREHOUSE_SOURCE
      ,@LOCATION_SOURCE
      ,@CODE_SKU
      ,@QTY
	  ,@SERIAL
			  );

	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
