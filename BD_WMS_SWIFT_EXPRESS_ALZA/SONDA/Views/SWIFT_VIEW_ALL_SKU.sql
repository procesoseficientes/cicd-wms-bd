
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-22-2016
-- Description:			

-- Modificado 01-22-2016
-- anynimous
-- sin motivo

-- Modificacion 25-02-2016
-- rudi.garcia
-- Se modifico el campo lista de precios que tenia "1" quemado por el que tiene la tabla de parametros

-- Modificacion 16-04-2016
          -- alberto.ruiz
          -- Se quito el que solo mostrara los valores de la lista por defecto

-- MODIFICADO: 04-05-2016
		--hector.gonzalez
		-- Se agrego la columna CODE_PACK_UNIT

-- Modificacion 27-05-2016
					-- alberto.ruiz
					-- Se agregaron las columnas VOLUME_CODE_UNIT y VOLUME_NAME_UNIT

-- Modificacion 04-Nov-16 @ A-Team Sprint 4
					-- alberto.ruiz
					-- Se agrego el campo HANDLE_DIMENSION

-- Modificacion 14-Mar-17 @ A-Team Sprint Ebonne
					-- alberto.ruiz
					-- Se agregaron los campos de [OWNER] y [OWNER_ID]

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agregan columnas ART_CODE, VAT_CODE
/*				
-- Ejemplo de Ejecucion:
				-- 

				SELECT * FROM [SONDA].[SWIFT_VIEW_ALL_SKU]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_ALL_SKU]
AS
SELECT
	[SKU]
	,[ERP].[CODE_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [CODE_SKU]
	,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([DESCRIPTION_SKU]) COLLATE SQL_Latin1_General_CP1_CI_AS AS [DESCRIPTION_SKU]
	,[VALUE_TEXT_CLASSIFICATION] COLLATE SQL_Latin1_General_CP1_CI_AS AS [VALUE_TEXT_CLASSIFICATION]
	,[BARCODE_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [BARCODE_SKU]
	,[CODE_PROVIDER] COLLATE SQL_Latin1_General_CP1_CI_AS AS [CODE_PROVIDER]
	,NULL AS 'LIST_PRICE'
	,NULL AS 'COST'
	,[MEASURE] COLLATE SQL_Latin1_General_CP1_CI_AS AS [MEASURE] --CASE S.HANDLE_BATCH WHEN '' THEN '0' ELSE S.HANDLE_BATCH END AS MEASURE,
	,[ERP].[LAST_UPDATE] AS [LAST_UPDATE]
	,[ERP].[LAST_UPDATE_BY] COLLATE SQL_Latin1_General_CP1_CI_AS AS [LAST_UPDATE_BY]
	,[HANDLE_SERIAL_NUMBER] COLLATE SQL_Latin1_General_CP1_CI_AS AS [HANDLE_SERIAL_NUMBER]
	,[HANDLE_BATCH] COLLATE SQL_Latin1_General_CP1_CI_AS AS [HANDLE_BATCH]
	,
  --0 AS ON_HAND,
	[FROM_ERP] [FROM_ERP]
	,[CODE_FAMILY_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [CODE_FAMILY_SKU]
	,ISNULL([PU].[CODE_PACK_UNIT],
			'No tiene unidad Asociada') AS [CODE_PACK_UNIT]
	,ISNULL([ERPSPU].[DESCRIPTION_PACK_UNIT],
			'No tiene unidad Asociada') AS [DESCRIPTION_PACK_UNIT]
	,[ERP].[USE_LINE_PICKING]
	,[ERP].[VOLUME_SKU]
	,[ERP].[WEIGHT_SKU]
	,[ERP].[VOLUME_CODE_UNIT]
	,[ERP].[VOLUME_NAME_UNIT]
	,0 [HANDLE_DIMENSION]
	,[ERP].[OWNER]
	,[ERP].[OWNER_ID]
	,ERP.ART_CODE
	,ERP.VAT_CODE
FROM
	[SWIFT_INTERFACES].[SONDA].[ERP_VIEW_SKU] [ERP]
LEFT JOIN [SONDA].[SWIFT_SKU_SALE_PACK_UNIT] [PU] ON ([ERP].[CODE_SKU] = [PU].[CODE_SKU])
LEFT JOIN [SONDA].[SONDA_PACK_UNIT] [ERPSPU] ON [PU].[CODE_PACK_UNIT] = [ERPSPU].[CODE_PACK_UNIT]
WHERE
	[ERP].[CODE_SKU] != 'ANULADO'
UNION ALL
SELECT
	[A].[SKU]
	,[A].[CODE_SKU]
	,[A].[DESCRIPTION_SKU]
	,[A].[CLASSIFICATION_SKU] AS [VALUE_TEXT_CLASSIFICATION]
	,[A].[BARCODE_SKU]
	,[A].[CODE_PROVIDER]
	,[sp].[VALUE] AS 'LIST_PRICE'
	,[A].[COST] AS 'COST'
	,[A].[MEASURE]
	,[A].[LAST_UPDATE]
	,[A].[LAST_UPDATE_BY]
	,[A].[HANDLE_SERIAL_NUMBER]
	,[A].[HANDLE_BATCH]
	,
  --ISNULL(B.ON_HAND,0) AS ON_HAND,
	0 [FROM_ERP]
	,[A].[CODE_FAMILY_SKU]
	,ISNULL([SPU].[CODE_PACK_UNIT],
			'No tiene unidad Asociada') AS [CODE_PACK_UNIT]
	,ISNULL([SOPU].[DESCRIPTION_PACK_UNIT],
			'No tiene unidad Asociada') AS [DESCRIPTION_PACK_UNIT]
	,0 [USE_LINE_PICKING]
	,0 [VOLUME_SKU]
	,0 [WEIGHT_SKU]
	,'Sin Medida' [VOLUME_CODE_UNIT]
	,'Sin Medida' [VOLUME_NAME_UNIT]
	,ISNULL([A].[HANDLE_DIMENSION], 0) [HANDLE_DIMENSION]
	,NULL [OWNER]
	,NULL [OWNER_ID]
	,NULL ART_CODE
	,NULL VAT_CODE
FROM
	[SONDA].[SWIFT_SKU] AS [A]
INNER JOIN [SONDA].[SWIFT_PARAMETER] [sp] ON (
											[sp].[GROUP_ID] = 'ERP_HARDCODE_VALUES'
											AND [sp].[PARAMETER_ID] = 'PRICE_LIST'
											)
LEFT JOIN [SONDA].[SWIFT_SKU_SALE_PACK_UNIT] [SPU] ON ([A].[CODE_SKU] = [SPU].[CODE_SKU])
LEFT JOIN [SONDA].[SONDA_PACK_UNIT] [SOPU] ON [SPU].[CODE_PACK_UNIT] = [SOPU].[CODE_PACK_UNIT];

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SWIFT_SKU (SONDA)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_ALL_SKU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_ALL_SKU';

