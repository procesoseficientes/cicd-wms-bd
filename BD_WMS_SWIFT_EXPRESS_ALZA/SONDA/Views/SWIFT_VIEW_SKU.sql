-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-22-2016
-- Description:			

-- MODIFICADO: 04-05-2016
		--hector.gonzalez
		-- Se agrego la columna CODE_PACK_UNIT

-- Modificacion 04-Nov-16 @ A-Team Sprint 4
					-- alberto.ruiz
					-- Se agrego el campo HANDLE_DIMENSION
/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_VIEW_SKU]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_SKU]
AS
	SELECT
		-1 [SKU]
		,[ERP].[CODE_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [CODE_SKU]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([DESCRIPTION_SKU]) COLLATE SQL_Latin1_General_CP1_CI_AS AS [DESCRIPTION_SKU]
		,[ERP].[BARCODE_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [BARCODE_SKU]
		,[ERP].[UNIT_MEASURE_SKU] AS [UNIT_MEASURE_SKU]
		,[ERP].[WEIGHT_SKU] AS [WEIGHT_SKU]
		,[ERP].[VOLUME_SKU] AS [VOLUME_SKU]
		,[ERP].[LONG_SKU] AS [LONG_SKU]
		,[ERP].[WIDTH_SKU] AS [WIDTH_SKU]
		,[ERP].[HIGH_SKU] AS [HIGH_SKU]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([NAME_PROVIDER]) COLLATE SQL_Latin1_General_CP1_CI_AS AS [NAME_PROVIDER]
		,[ERP].[COST] AS 'COST'
		,[ERP].[LIST_PRICE] AS 'LIST_PRICE'
		,[ERP].[MEASURE]  COLLATE SQL_Latin1_General_CP1_CI_AS AS [MEASURE]
		,[ERP].[NAME_CLASSIFICATION]  COLLATE SQL_Latin1_General_CP1_CI_AS AS [NAME_CLASSIFICATION]
		,[ERP].[VALUE_TEXT_CLASSIFICATION] COLLATE SQL_Latin1_General_CP1_CI_AS AS [VALUE_TEXT_CLASSIFICATION]
		,[ERP].[HANDLE_SERIAL_NUMBER] COLLATE SQL_Latin1_General_CP1_CI_AS AS [HANDLE_SERIAL_NUMBER]
		,[ERP].[HANDLE_BATCH] COLLATE SQL_Latin1_General_CP1_CI_AS AS [HANDLE_BATCH]
		,[ERP].[FROM_ERP] [FROM_ERP]
		,[ERP].[CODE_FAMILY_SKU] COLLATE SQL_Latin1_General_CP1_CI_AS AS [CODE_FAMILY_SKU]
		,ISNULL([PU].[CODE_PACK_UNIT] ,'No tiene unidad Asociada') AS [CODE_PACK_UNIT]
		,ISNULL([ERPSPU].[DESCRIPTION_PACK_UNIT] ,'No tiene unidad Asociada') AS [DESCRIPTION_PACK_UNIT]
		,0 [HANDLE_DIMENSION]
	FROM [SWIFT_INTERFACES].[SONDA].[ERP_VIEW_SKU] [ERP]
	INNER JOIN [SONDA].[SWIFT_PARAMETER] [sp]
	ON	[LIST_NUM] = [sp].[VALUE]
		AND [sp].[GROUP_ID] = 'ERP_HARDCODE_VALUES'
		AND [sp].[PARAMETER_ID] = 'PRICE_LIST'
	LEFT JOIN [SONDA].[SWIFT_SKU_SALE_PACK_UNIT] [PU]
	ON	([ERP].[CODE_SKU] = [PU].[CODE_SKU])
	LEFT JOIN [SONDA].[SONDA_PACK_UNIT] [ERPSPU]
	ON	[PU].[CODE_PACK_UNIT] = [ERPSPU].[CODE_PACK_UNIT]
	WHERE
		[ERP].[CODE_SKU] != 'ANULADO'
	UNION ALL
	SELECT
		[A].[SKU]
		,[A].[CODE_SKU]
		,[A].[DESCRIPTION_SKU]
		,[A].[BARCODE_SKU]
		,[A].[UNIT_MEASURE_SKU]
		,[A].[WEIGHT_SKU]
		,[A].[VOLUME_SKU]
		,[A].[LONG_SKU]
		,[A].[WIDTH_SKU]
		,[A].[HIGH_SKU]
		,[B].[NAME_PROVIDER] COLLATE SQL_Latin1_General_CP1_CI_AS AS [NAME_PROVIDER]
		,[A].[COST] AS [COST]
		,[A].[COST] AS [LIST_PRICE]
		,[C].[DESCRIPTION] AS [MEASURE]
		,[SONDA].[SWIFT_CLASSIFICATION].[NAME_CLASSIFICATION]
		,[SONDA].[SWIFT_CLASSIFICATION].[VALUE_TEXT_CLASSIFICATION]
		,[A].[HANDLE_SERIAL_NUMBER]
		,[A].[HANDLE_BATCH]
		,0 [FROM_ERP]
		,[FU].[DESCRIPTION_FAMILY_SKU] AS [CODE_FAMILY_SKU]
		,ISNULL([SPU].[CODE_PACK_UNIT] ,'No tiene unidad Asociada') AS [CODE_PACK_UNIT]
		,ISNULL([SOPU].[DESCRIPTION_PACK_UNIT] ,'No tiene unidad Asociada') AS [DESCRIPTION_PACK_UNIT]
		,ISNULL([A].[HANDLE_DIMENSION], 0) [HANDLE_DIMENSION]
	FROM [SONDA].[SWIFT_SKU] AS [A]
	INNER JOIN [SONDA].[SWIFT_FAMILY_SKU] AS [FU]
	ON	[FU].[CODE_FAMILY_SKU] = [A].[CODE_FAMILY_SKU]
	LEFT OUTER JOIN [SONDA].[SWIFT_CLASSIFICATION]
	ON	[A].[CLASSIFICATION_SKU] = [SONDA].[SWIFT_CLASSIFICATION].[CLASSIFICATION]
	LEFT OUTER JOIN [SONDA].[SWIFT_VIEW_ALL_PROVIDERS] AS [B]
	ON	[A].[CODE_PROVIDER] COLLATE SQL_Latin1_General_CP1_CI_AS = [B].[PROVIDER]
	LEFT OUTER JOIN [SONDA].[SWIFT_MEASURE_UNIT] AS [C]
	ON	[A].[MEASURE] = [C].[CODE]
	LEFT JOIN [SONDA].[SWIFT_SKU_SALE_PACK_UNIT] [SPU]
	ON	([A].[CODE_SKU] = [SPU].[CODE_SKU])
	LEFT JOIN [SONDA].[SONDA_PACK_UNIT] [SOPU]
	ON	[SPU].[CODE_PACK_UNIT] = [SOPU].[CODE_PACK_UNIT];

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
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "SWIFT_CLASSIFICATION (SONDA)"
            Begin Extent = 
               Top = 187
               Left = 476
               Bottom = 307
               Right = 716
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 29
               Left = 472
               Bottom = 149
               Right = 702
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
', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_SKU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_SKU';

