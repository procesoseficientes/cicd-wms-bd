-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		2017-01-13 TeamErgon Sprint 1
-- Description:			      Sp que inserta en tabla OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL

-- Modificacion 2017-01-13 TeamErgon Sprint 1
  -- rudi.garcia
	-- Se agrego el campo de LINE_NUM para que se guarde

-- Modificacion 1/26/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agregan campos por recepcion de wms

-- Modificacion 06-Apr-18 @ Nexus Team Sprint Buho
					-- pablo.aguilar
					-- Se agrega el campo de centro de costo.

-- Modificacion 1-Jun-18 @ GForce Team Sprint Dinosaurio
					-- marvin.solares
					-- Se agregan columnas [UNIT] y [UNIT_DESCRIPTION]

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_INSERT_ERP_RECEPTION_DOCUMENT_DETAIL]
			@ERP_RECEPTION_DOCUMENT_HEADER_ID = 3
      ,@MATERIAL_ID = 'wms/CHOCOLATE'
      ,@QTY = 46      
--
		SELECT * FROM [wms].OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_ERP_RECEPTION_DOCUMENT_DETAIL]
	(
		@ERP_RECEPTION_DOCUMENT_HEADER_ID INT
		,@MATERIAL_ID VARCHAR(50)
		,@QTY NUMERIC(18,6)
		,@LINE_NUM INT
		,@ERP_OBJECT_TYPE INT
		,@CURRENCY VARCHAR(50) = NULL
		,@RATE NUMERIC(18,6) = NULL
		,@TAX_CODE VARCHAR(50) = NULL
		,@VAT_PERCENT NUMERIC(18,6) = NULL
		,@PRICE NUMERIC(18,6) = NULL
		,@DISCOUNT NUMERIC(18,6) = NULL
		,@WAREHOUSE_CODE VARCHAR(50) = NULL
		,@COST_CENTER VARCHAR(25) = NULL
		,@UNIT VARCHAR(100) = NULL
		,@UNIT_DESCRIPTION VARCHAR(100) = NULL
	)
AS
	BEGIN
		BEGIN TRY
			BEGIN TRAN [t1];
    --		
			INSERT	INTO [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
					(
						[ERP_RECEPTION_DOCUMENT_HEADER_ID]
						,[MATERIAL_ID]
						,[QTY]
						,[LINE_NUM]
						,[ERP_OBJECT_TYPE]
						,[CURRENCY]
						,[RATE]
						,[TAX_CODE]
						,[VAT_PERCENT]
						,[PRICE]
						,[DISCOUNT]
						,[WAREHOUSE_CODE]
						,[COST_CENTER]
						,[UNIT]
						,[UNIT_DESCRIPTION]
					)
			VALUES
					(
						@ERP_RECEPTION_DOCUMENT_HEADER_ID
						,@MATERIAL_ID
						,@QTY
						,@LINE_NUM
						,@ERP_OBJECT_TYPE
						,@CURRENCY
						,@RATE
						,@TAX_CODE
						,@VAT_PERCENT
						,@PRICE
						,@DISCOUNT
						,@WAREHOUSE_CODE
						,@COST_CENTER
						,@UNIT
						,@UNIT_DESCRIPTION
					);

			COMMIT TRAN [t1];
    --
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo];
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN [t1];
    --
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo];
		END CATCH;
	END;