
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2016-11-29
-- Description:	 Se eliminar cualquier operación que se haya realizado sobre una licencia 



-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-10 Nexus@AgeOfEmpires
-- Description:	 Se modifica para que elimine tambien los registros de masterpack de esa licencia. 

-- Modificacion:		henry.rodriguez
-- Fecha:				18-Julio-2019 G-Force@Dublin
-- Descripcion:			Se elimina el inventario reservado para esa licencia si maneja proyecto.

/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ROLLBACK_LICENCE] (
		@LICENCE_ID NUMERIC(18, 0)
	)
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		IF NOT EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_LICENSES] [L]
						INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
						WHERE
							@LICENCE_ID = [L].[LICENSE_ID] )
		BEGIN

			-- ------------------------------------------------------------------------------------
			-- SI MANEJA PROYECTO SE ELIMINA EL INVENTARIO RESERVADO PARA ESA LICENCIA
			-- ------------------------------------------------------------------------------------
			DECLARE	@PROJECT_ID AS UNIQUEIDENTIFIER = NULL;

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_INV_X_LICENSE]
						WHERE
							[LICENSE_ID] = @LICENCE_ID
							AND [PROJECT_ID] IS NOT NULL )
			BEGIN	

				SELECT TOP (1)
					@PROJECT_ID = [PROJECT_ID]
				FROM
					[wms].[OP_WMS_INV_X_LICENSE]
				WHERE
					[LICENSE_ID] = @LICENCE_ID
					AND [PROJECT_ID] IS NOT NULL;

				DELETE
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
				WHERE
					[PROJECT_ID] = @PROJECT_ID
					AND [LICENSE_ID] = @LICENCE_ID;
			END;
			--
			DELETE
				[wms].[OP_WMS_TRANS]
			WHERE
				@LICENCE_ID = [LICENSE_ID];
			DELETE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			WHERE
				@LICENCE_ID = [LICENSE_ID];
			DELETE
				[wms].[OP_WMS_INV_X_LICENSE]
			WHERE
				@LICENCE_ID = [LICENSE_ID];
			DELETE
				[wms].[OP_WMS_LICENSES]
			WHERE
				@LICENCE_ID = [LICENSE_ID];

			DELETE
				[D]
			FROM
				[wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [H] ON [D].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
			WHERE
				[H].[LICENSE_ID] = @LICENCE_ID;

			DELETE
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			WHERE
				[LICENSE_ID] = @LICENCE_ID;			

		END;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('' AS VARCHAR) [DbData];
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		DECLARE	@MESSAGE VARCHAR(2000) = ERROR_MESSAGE();
		ROLLBACK TRANSACTION;
		RAISERROR (@MESSAGE, 16, 1);

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() AS [Mensaje]
			,@@ERROR AS [Codigo]
			,'' AS [DbData];
	END CATCH;






END;