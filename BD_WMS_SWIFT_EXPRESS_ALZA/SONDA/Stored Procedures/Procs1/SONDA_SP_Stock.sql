-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-12-2015
-- Description:			Prepara los SKU para ser transferidos a la HH con Sonda

--Acuatlización: diego.as
--Fecha de Actualización: 19-02-2016
--Motivo: se agregó el campo CODE_FAMILY_SKU para referenciar a la familia del SKU del lado de la HH

--Acuatlización: diego.as
--Fecha de Actualización: 07-04-2016
--Motivo: Se modifico para que mande 0 en el campo del precio del SKU

-- Modificacion 17-Nov-16 @ A-Team Sprint 5
					-- alberto.ruiz
					-- Se agrego campo de cantidad inicial al insert

-- Modificacion 10/1/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agrega campo TAX_CODE para controlar si el producto maneja impuesto o no

-- Modificacion 10/1/2017 @ G-FORCE-Team Sprint Delfin
					-- diego.as
					-- Se agrega campo [CODE_PACK_UNIT_STOCK] para indicar la unidad de medida STOCK
					
-- Modificacion 10/1/2017 @ G-FORCE-Team Sprint Delfin
					-- christian.hernandez
					-- Se agrega validacion I.ON_HAND > 0 para filtrar informacion y asi permitir insertar los stocks
/*
-- Ejemplo de Ejecucion:
				DECLARE @pRESULT VARCHAR(MAX)
				--
				exec [SONDA].[SONDA_SP_Stock] @Warehouse = 'CAN', @pRESULT = @pRESULT OUTPUT
				--
				SELECT @pRESULT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_Stock]
	(
		@Warehouse NVARCHAR(15)
		,@pRESULT VARCHAR(MAX) = '' OUTPUT
	)
AS
	BEGIN 
		SET NOCOUNT ON;
		SET ANSI_WARNINGS OFF;
--
		DECLARE	@ListaPrecios VARCHAR(25);--5 pra ways 
		DECLARE	@tmpResult VARCHAR(MAX) = '';
--
		SELECT
			@ListaPrecios = [SONDA].[SWIFT_FN_GET_PRICE_LIST](DEFAULT);
	--SELECT
		--@ListaPrecios = 1;
--
		DELETE FROM
			[SONDA].[SONDA_POS_SKUS]
		WHERE
			[ROUTE_ID] = @Warehouse
		OPTION
			(MAXDOP 1,OPTIMIZE FOR (@Warehouse UNKNOWN));
--
		IF (@@ERROR = 0)
		BEGIN
			INSERT	INTO [SONDA].[SONDA_POS_SKUS]
					(
						[SKU]
						,[SKU_NAME]
						,[SKU_PRICE]
						,[REQUERIES_SERIE]
						,[IS_KIT]
						,[ON_HAND]
						,[ROUTE_ID]
						,[IS_PARENT]
						,[PARENT_SKU]
						,[EXPOSURE]
						,[PRIORITY]
						,[QTY_RELATED]
						,[CODE_FAMILY_SKU]
						,[SALES_PACK_UNIT]
						,[INITIAL_QTY]
						,[TAX_CODE]
						,[CODE_PACK_UNIT_STOCK]
					)
			SELECT
				[i].[SKU] AS [CodigoHijo]
				,MAX([i].[SKU_DESCRIPTION]) [NombreHijo]
			--,i.SKU_DESCRIPTION NombreHijo				 		
				,0 AS [PrecioCombo]--includes sales tax --Para obtener el precio del sku reemplazar el 0 por p.COST
				,[s].[HANDLE_SERIAL_NUMBER] AS [RequiereSerie]
				,0 AS [IS_KIT]
				,SUM([i].[ON_HAND]) AS [OnHand]
				,@Warehouse AS [ROUTE_ID]
				,0 AS [IS_PARENT]
				,[i].[SKU] AS [PARENT_SKU]
				,1 AS [EXPOSURE]
				,0 AS [PRIORITY]
				,0 AS [QTY_RELATED]
				,[s].[CODE_FAMILY_SKU] AS [CODE_FAMILY_SKU]
				,[s].[CODE_PACK_UNIT] AS [SALES_PACK_UNIT]
				,SUM([i].[ON_HAND])
				,MAX([s].[VAT_CODE]) AS [TAX_CODE]
				,[s].[CODE_PACK_UNIT]
			FROM
				[SONDA].[SWIFT_INVENTORY] [i]
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [s]
			ON	([s].[CODE_SKU] = [i].[SKU])
			INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_SKU] [p]
			ON	([p].[CODE_SKU] = [i].[SKU])
			WHERE
				[i].[WAREHOUSE] = @Warehouse
				AND [p].[CODE_PRICE_LIST] = @ListaPrecios
				AND I.ON_HAND > 0
			GROUP BY
				[i].[SKU]
				,[s].[HANDLE_SERIAL_NUMBER]
				,[p].[COST]
				,[s].[CODE_FAMILY_SKU]
				,[s].[CODE_PACK_UNIT]
				,[i].[CODE_PACK_UNIT_STOCK]
			OPTION
				(MAXDOP 1,OPTIMIZE FOR (@Warehouse UNKNOWN, @ListaPrecios UNKNOWN))
	--
			SELECT
				@tmpResult = 'OK';
		END; 
		ELSE
		BEGIN
			SELECT
				@tmpResult = 'ERROR, No pudo actualizar la ruta: ' + @Warehouse;
		END;

		SELECT
			@pRESULT = @tmpResult;
	END;
