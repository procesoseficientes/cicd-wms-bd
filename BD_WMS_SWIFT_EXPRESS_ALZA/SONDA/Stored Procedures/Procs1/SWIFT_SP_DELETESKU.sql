-- =============================================
  -- MODIFICADO: 04-05-2016
		--hector.gonzalez
		-- Se declaro el parametro @CODE_PACK_UNIT, se obtuvo el CODE_PACK_UNIT del sku parametrizado y se mando a ejecutar SWIFT_SP_DELETE_PACK_UNIT_BY_SKU

/*
-- Ejemplo de Ejecucion:
				-- 	
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_DELETESKU
@SKU INT,
@pResult varchar(250) OUTPUT
AS
IF ((SELECT COUNT(A.CODE_SKU) FROM SWIFT_PICKING_DETAIL AS A WHERE A.CODE_SKU = (SELECT CODE_SKU FROM SWIFT_SKU WHERE SKU = @SKU ) )
	+ (SELECT COUNT(B.COUNT_SKU) FROM SWIFT_CYCLE_COUNT_DETAIL AS B WHERE B.COUNT_SKU = (SELECT CODE_SKU FROM SWIFT_SKU WHERE SKU = @SKU )  )
	+ (SELECT COUNT(C.CODE_SKU) FROM SWIFT_RECEPTION_DETAIL AS C WHERE  C.CODE_SKU = (SELECT CODE_SKU FROM SWIFT_SKU WHERE SKU = @SKU))
	--+ (SELECT COUNT(D.SKU) FROM [SONDA].SWIFT_HIST_INVENTORY AS D WHERE D.SKU = @SKU)
	+ (SELECT COUNT(E.SKU) FROM SWIFT_INVENTORY AS E WHERE E.SKU = (SELECT CODE_SKU FROM SWIFT_SKU WHERE SKU = @SKU))
	) = 0
	BEGIN 
  DECLARE @CODE_PACK_UNIT VARCHAR(25)

		DELETE FROM SWIFT_SKU WHERE SKU=@SKU
		SELECT @pResult = ''
-----------------------------------------------------------
      --se obtuvo el CODE_PACK_UNIT del sku parametrizado y se elimina
-----------------------------------------------------------
  SELECT @CODE_PACK_UNIT= ssspu.CODE_PACK_UNIT 
    FROM [SONDA].SWIFT_SKU_SALE_PACK_UNIT ssspu
    INNER JOIN [SONDA].SWIFT_SKU ss ON ssspu.CODE_SKU = ss.CODE_SKU
    WHERE ss.SKU= @SKU

	EXEC	[SONDA].SWIFT_SP_DELETE_SKU_SALE_PACK_UNIT 
			@CODE_PACK_UNIT = @CODE_PACK_UNIT
					,@CODE_SKU = @SKU
----------------------------------------------------------
----------------------------------------------------------
	END
	ELSE
	BEGIN
		SELECT @pResult = 'El dato no se puede eliminar debido a que está siendo utilizado'
	END
