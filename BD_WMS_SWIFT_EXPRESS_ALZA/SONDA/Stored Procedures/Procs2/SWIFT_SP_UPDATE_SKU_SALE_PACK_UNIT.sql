-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	04-05-2016
-- Description:			Actualiza una unidad de medida

  /*
-- Ejemplo de Ejecucion:
				DECLARE 
					@CODE_PACK_UNIT VARCHAR(25)  = 'Fardos'
					,@CODE_SKU VARCHAR(50) = '100017'
					
				EXEC [SONDA].SWIFT_SP_UPDATE_PACK_UNIT_BY_SKU
					@CODE_PACK_UNIT = @CODE_PACK_UNIT
					,@CODE_SKU = @CODE_SKU
				
				--
				SELECT * FROM [SONDA].SWIFT_SKU_SALE_PACK_UNIT WHERE CODE_PACK_UNIT = @CODE_PACK_UNIT AND CODE_SKU = @CODE_SKU
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_SKU_SALE_PACK_UNIT
(	
	@CODE_PACK_UNIT VARCHAR(25) 
	,@CODE_SKU VARCHAR(50) 
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE [SONDA].SWIFT_SKU_SALE_PACK_UNIT
		SET CODE_PACK_UNIT = @CODE_PACK_UNIT
		WHERE CODE_SKU = @CODE_SKU
			
		--
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

END
