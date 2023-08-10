-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	25-02-2016
/* Description: SP que INSERTA un RECEPTION_DETAIL 
				en base a los parametros:
					 @PICKING_HEADER 
					 @RECEPTION_HEADER
					 @CODE_SKU
					 @QTY
*/

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_CREATE_RECPTION_DETAIL_BY_PICKING]
			@PICKING_HEADER = 1020
			,@RECEPTION_HEADER = 2023
			,@CODE_SKU = '100004'
			,@QTY = 1
		---------------------------------------------------------
		SELECT *
		FROM [SONDA].[SWIFT_RECEPTION_DETAIL]
		WHERE RECEPTION_DETAIL = 3031
		---------------------------------------------------------
		SELECT *
		FROM [SONDA].[SWIFT_PICKING_DETAIL]
		WHERE [PICKING_HEADER] = 1020 AND [CODE_SKU] = '100004'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CREATE_RECPTION_DETAIL_BY_PICKING]
(
	@PICKING_HEADER INT
	,@RECEPTION_HEADER INT
	,@CODE_SKU VARCHAR(50)
	,@QTY INT
)
AS
BEGIN
SET NOCOUNT ON

DECLARE @ID_PICKING_DETAIL INT
		,@DELETE_ROW INT
		,@ID INT
		,@ERROR VARCHAR(1000) = ERROR_MESSAGE()			
	-- ------------------------------------------------------------------------------------
	-- Obtiene parametros generales
	-- ------------------------------------------------------------------------------------
	SELECT 	@ID_PICKING_DETAIL = PD.PICKING_DETAIL 
			,@DELETE_ROW =(CASE WHEN (PD.DISPATCH - @QTY) = 0 THEN 1 ELSE 0 END)
	FROM [SONDA].[SWIFT_PICKING_DETAIL] AS PD
	WHERE [PICKING_HEADER] = @PICKING_HEADER AND [CODE_SKU] = @CODE_SKU

	IF (@ID_PICKING_DETAIL IS NOT NULL) BEGIN
			-- ------------------------------------------------------------------------------------ 
			-- INSERTAR EL DETALLE Y ACTUALIZAR LA FILA EN LA TABLA PICKING DETAIL
			-- ------------------------------------------------------------------------------------
			BEGIN TRY
			INSERT INTO [SONDA].[SWIFT_RECEPTION_DETAIL] (
				RECEPTION_HEADER
				,CODE_SKU
				,DESCRIPTION_SKU
				,EXPECTED
				,SCANNED
				,LAST_UPDATE
				,LAST_UPDATE_BY
				,DIFFERENCE
				)
			SELECT @RECEPTION_HEADER
				,@CODE_SKU
				,PD.DESCRIPTION_SKU
				,@QTY
				,0
				,GETDATE()
				,PD.LAST_UPDATE_BY
				,@QTY
			FROM [SONDA].[SWIFT_PICKING_DETAIL] AS PD
			WHERE [PICKING_HEADER] = @PICKING_HEADER 
					AND [CODE_SKU] = @CODE_SKU
			
			-- ------------------------------------------------------------------------------------
			-- Recoge el ID de la Fila Insertada
			-- ------------------------------------------------------------------------------------
			SET @ID = SCOPE_IDENTITY()

			END TRY
			BEGIN CATCH
				PRINT 'CATCH: ' + @ERROR
				RAISERROR (@ERROR,16,1)
			END CATCH

		IF (@DELETE_ROW = 1) BEGIN
			-- ------------------------------------------------------------------------------------
			-- Elimina la linea en PICKING_DETAIL
			-- ------------------------------------------------------------------------------------
			BEGIN TRY
			DELETE FROM [SONDA].[SWIFT_PICKING_DETAIL] 
			WHERE (PICKING_DETAIL = @ID_PICKING_DETAIL) 
				AND (CODE_SKU = @CODE_SKU) 
				AND (PICKING_HEADER = @PICKING_HEADER)
			END TRY
			BEGIN CATCH
				PRINT 'CATCH: ' + @ERROR
				RAISERROR (@ERROR,16,1)
			END CATCH
		END
		ELSE BEGIN
			-- --------------------------------------------------------------------------------------
			-- Actualiza la linea en PICKING_DETAIL
			-- --------------------------------------------------------------------------------------
			BEGIN TRY
			UPDATE [SONDA].[SWIFT_PICKING_DETAIL] 
			SET [DISPATCH] = [DISPATCH] - @QTY
				,[SCANNED] = [SCANNED] - @QTY
				,[DIFFERENCE] = [DIFFERENCE] - @QTY
			WHERE [PICKING_DETAIL] = @ID_PICKING_DETAIL	
				AND [CODE_SKU] = @CODE_SKU 
				AND [PICKING_HEADER] = @PICKING_HEADER
			END TRY
			BEGIN CATCH
				PRINT 'CATCH: ' + @ERROR
				RAISERROR (@ERROR,16,1)
			END CATCH
		END
		-- ------------------------------------------------------------------------------------
		-- Devuelve el ID
		-- ------------------------------------------------------------------------------------
		SELECT @ID AS ID
	END
	ELSE BEGIN
		SELECT @ID AS ID
	END
END
