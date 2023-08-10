/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_RELOCATE_SKU_FROM_INVENTORY]    Script Date: 20/12/2015 9:09:38 AM ******/
-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	02-12-2015
-- Description:			Se agrega el campo de si es bodega externa al View de las bodegas

 --Modificacion 15-01-2016
		-- Autor: ppablo.loukota
		-- Descripción: Se agregan los campos nuevos de bodega

-- Modificacion 12/28/2016 @ A-Team Sprint Balder
					-- rodrigo.gomez
					-- Se agregaron los campos DISTRIBUTION_CENTER_ID y NAME_DISTRIBUTION_CENTER

  -- Modificacion 01-10-2017 @ A-Team Sprint Balder
					-- diego.as
					-- Se agrega campo CODE_WAREHOUSE_3PL
/*
-- Ejemplo de Ejecucion:				
				--
				SELECT * FROM [SONDA].[SWIFT_VIEW_WAREHOUSES]
				--				
*/
-- =============================================
CREATE VIEW [SONDA].SWIFT_VIEW_WAREHOUSES
AS
	SELECT     
		a.WAREHOUSE, 
		a.CODE_WAREHOUSE, 
		a.DESCRIPTION_WAREHOUSE, 
		b.NAME_CLASSIFICATION AS WEATHER_WAREHOUSE, 
		a.STATUS_WAREHOUSE, 
		a.IS_EXTERNAL,
		a.[ERP_WAREHOUSE],
		a.[ADDRESS_WAREHOUSE],
		a.[BARCODE_WAREHOUSE], 
		a.[SHORT_DESCRIPTION_WAREHOUSE],
		a.[TYPE_WAREHOUSE],
		a.[GPS_WAREHOUSE],
		[SWDC].[DISTRIBUTION_CENTER_ID],
		(CASE WHEN [SDC].[NAME_DISTRIBUTION_CENTER] IS NULL 
    THEN 'No posee CD asociado.'
    ELSE [SDC].[NAME_DISTRIBUTION_CENTER]
    END) AS [NAME_DISTRIBUTION_CENTER],
    a.[CODE_WAREHOUSE_3PL]
	FROM [SONDA].SWIFT_WAREHOUSES AS a LEFT OUTER JOIN
		 [SONDA].SWIFT_CLASSIFICATION AS b ON a.WEATHER_WAREHOUSE = b.CLASSIFICATION LEFT OUTER JOIN
		 [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER] [SWDC] ON a.[CODE_WAREHOUSE] = [SWDC].[CODE_WAREHOUSE] LEFT OUTER JOIN
		 [SONDA].[SWIFT_DISTRIBUTION_CENTER] [SDC] ON [SDC].[DISTRIBUTION_CENTER_ID] = [SWDC].[DISTRIBUTION_CENTER_ID]

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
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 167
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 303
               Bottom = 126
               Right = 543
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
', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_WAREHOUSES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_WAREHOUSES';

