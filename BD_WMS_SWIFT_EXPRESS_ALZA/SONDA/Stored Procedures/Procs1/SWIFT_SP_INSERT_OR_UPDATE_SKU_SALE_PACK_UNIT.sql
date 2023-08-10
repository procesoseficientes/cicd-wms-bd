-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	04-05-2016
-- Description:			Si el sku no tiene unidad de medida, Agrega una unidad de medida, de lo contrario la modifica

  /*
-- Ejemplo de Ejecucion:
				DECLARE 
					@CODE_PACK_UNIT VARCHAR(25)  = 'Manual'
					,@CODE_SKU VARCHAR(50) = '100017'
					
				EXEC [SONDA].SWIFT_SP_INSERT_OR_UPDATE_SKU_SALE_PACK_UNIT
					@CODE_PACK_UNIT = @CODE_PACK_UNIT
					,@CODE_SKU = @CODE_SKU
				
				--
				SELECT * FROM [SONDA].SWIFT_SKU_SALE_PACK_UNIT WHERE CODE_PACK_UNIT = @CODE_PACK_UNIT AND CODE_SKU = @CODE_SKU
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_OR_UPDATE_SKU_SALE_PACK_UNIT 
		 @CODE_PACK_UNIT VARCHAR(25) 
	  ,@CODE_SKU VARCHAR(50) 

AS
BEGIN TRY
  -------------------------------------------------
  --verifica si existe el sku ya tiene un pack_unit asignado
  -------------------------------------------------
	 IF (SELECT COUNT(ssspu.CODE_PACK_UNIT) FROM [SONDA].SWIFT_SKU_SALE_PACK_UNIT ssspu
          WHERE ssspu.CODE_SKU = @CODE_SKU)<1
    BEGIN  
    -------------------------------------------------
  --inserta la informacion si no tiene datos el sku
  -------------------------------------------------
   	  INSERT INTO [SONDA].SWIFT_SKU_SALE_PACK_UNIT(
		      CODE_PACK_UNIT
          ,CODE_SKU
	    ) VALUES (
		      @CODE_PACK_UNIT
		      ,@CODE_SKU
	    )
   END
   ELSE 
    BEGIN
    -------------------------------------------------
  --modifica la informacion si ya tiene datos el sku
  -------------------------------------------------
      UPDATE [SONDA].SWIFT_SKU_SALE_PACK_UNIT
  		SET CODE_PACK_UNIT = @CODE_PACK_UNIT
  		WHERE CODE_SKU = @CODE_SKU
    END

	

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
