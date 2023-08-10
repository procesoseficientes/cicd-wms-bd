/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_UPDATE_RELOCATE_INVENTORY]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	20-11-2015
-- Description:			ACTUALIZA LA REUBICACION DEL  INVENTARIO EN LA TABLA INVENTARIO 
/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_UPDATE_RELOCATE_INVENTORY]
				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_RELOCATE_INVENTORY]
@WAREHOUSE_TARGET varchar(50),
@LOCATION_TARGET varchar(50),
@WAREHOUSE_SOURCE varchar(50),
@LOCATION_SOURCE varchar(50),
@LAST_UPDATE_BY varchar(50),
@ON_HAND int,
@INVENTORY int 
AS
BEGIN TRY
DECLARE @NEW_ONHAND int
SET @NEW_ONHAND=	(
					Select I.ON_HAND - @ON_HAND   
					from [SONDA].SWIFT_INVENTORY I 
					where i.INVENTORY=@INVENTORY)
UPDATE [SONDA].[SWIFT_INVENTORY]
SET	   [WAREHOUSE] =@WAREHOUSE_TARGET
	  ,[LOCATION] = @LOCATION_TARGET
	  ,[LAST_UPDATE]= GETDATE()
	  ,[LAST_UPDATE_BY]= @LAST_UPDATE_BY
	  ,[IS_SCANNED]=0
	  ,[ON_HAND]= @NEW_ONHAND
	  ,[RELOCATED_DATE]=GETDATE()
WHERE  [INVENTORY]=@INVENTORY


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
