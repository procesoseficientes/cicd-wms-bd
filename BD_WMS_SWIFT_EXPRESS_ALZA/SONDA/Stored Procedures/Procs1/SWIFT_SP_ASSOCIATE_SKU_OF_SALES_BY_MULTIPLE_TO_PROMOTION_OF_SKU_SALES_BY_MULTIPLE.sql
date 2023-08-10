-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/26/2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			Agrega un registro a la tabla SWIFT_PROMO_SKU_SALES_BY_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ASSOCIATE_SKU_OF_SALES_BY_MULTIPLE_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE]
					@PROMO_ID = 9
					, @CODE_SKU = '100011'
					, @PACK_UNIT = 1
					, @MULTIPLE = 10
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ASSOCIATE_SKU_OF_SALES_BY_MULTIPLE_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE](
	@PROMO_ID INT,
	@CODE_SKU VARCHAR(50),
	@PACK_UNIT INT,
	@MULTIPLE INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT;
		--
		INSERT INTO [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
				(
					[PROMO_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[MULTIPLE]
				)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@MULTIPLE  -- MULTIPLE - int
				)
		--
		SET @ID = SCOPE_IDENTITY();
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo,  CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'El SKU ' + @CODE_SKU + ' ya se encuentra asociado a la promoción.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
