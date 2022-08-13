-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/9/2018 @ REBORN-Team Sprint Ramsey 
-- Description:			Modifica la ubicacion de la etiqueta de picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_REALLOCATE_PICKING_LABEL]
					@LABEL_ID = 3
					,@TARGET_LOCATION = 'B01-P01-F01-NU'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_REALLOCATE_PICKING_LABEL](
	@LABEL_ID INT
	,@TARGET_LOCATION VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Realiza las validaciones necesarias para reubicar las etiquetas de picking
		-- ------------------------------------------------------------------------------------
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_PICKING_LABELS] WHERE [LABEL_ID] = @LABEL_ID AND [LABEL_STATUS] <> 'DELIVERED')
		BEGIN
		    RAISERROR(N'La etiqueta proporcionada no existe o es incorrecta, por favor, verifique y vuelva a intentar.',16,1)
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_SHELF_SPOTS] WHERE [LOCATION_SPOT] = @TARGET_LOCATION)
		BEGIN
		    RAISERROR(N'La ubicación proporcionada no existe o es incorrecta, por favor, verifique y vuelva a intentar.',16,1)
		END

		IF EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_PICKING_LABELS] WHERE [LABEL_ID] = @LABEL_ID AND [TARGET_LOCATION] = @TARGET_LOCATION)
		BEGIN
		    RAISERROR(N'La ubicación proporcionada es la misma que la de origen.',16,1)
		END

		-- ------------------------------------------------------------------------------------
		-- Realiza la reubicacion
		-- ------------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_PICKING_LABELS]
        SET
            [SOURCE_LOCATION] = [TARGET_LOCATION]
           ,[TARGET_LOCATION] = @TARGET_LOCATION
        WHERE
            [LABEL_ID] = @LABEL_ID;
		
		-- ------------------------------------------------------------------------------------
		-- Devuelve el objeto operacion con estado exitoso
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado , 
			'Proceso Exitoso' Mensaje ,  
			0 Codigo, 
			'' DbData

	END TRY
	BEGIN CATCH
		SELECT 
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@@error AS [Codigo]
			,'' AS [DbData]
	END CATCH;
END