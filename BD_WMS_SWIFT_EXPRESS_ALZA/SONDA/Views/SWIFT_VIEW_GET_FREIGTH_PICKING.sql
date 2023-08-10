CREATE VIEW [SONDA].[SWIFT_VIEW_GET_FREIGTH_PICKING]
AS
SELECT DISTINCT
			A.PICKING_HEADER, 
			A.CLASSIFICATION_PICKING AS NAME_CLASSIFICATION, 
			C.NAME_CUSTOMER, 
			A.REFERENCE, 
			A.DOC_SAP_RECEPTION, 
			A.STATUS, 
			A.LAST_UPDATE, 
			A.COMMENTS, 
            A.SCHEDULE_FOR, 
            A.SEQ, 
            A.FF_STATUS,
            B.CODE_SKU,
            B.DESCRIPTION_SKU,
            ISNULL(B.RESULT,0) AS ENTREGADO,
            ISNULL((B.SCANNED-ISNULL(B.RESULT,0)),0) AS RESTANTE,
			ISNULL((B.SCANNED - B.DISPATCH),0) AS DIFFERENCE,
			B.SCANNED
FROM        [SONDA].SWIFT_PICKING_HEADER AS A-- , [SONDA].SWIFT_PICKING_DETAIL AS B, [SONDA].SWIFT_CUSTOMERS AS C
			LEFT OUTER JOIN
                      [SONDA].SWIFT_PICKING_DETAIL AS B ON A.PICKING_HEADER = B.PICKING_HEADER
			LEFT OUTER JOIN
                  [SONDA].SWIFT_VIEW_ALL_COSTUMER     AS C ON A.CODE_CLIENT = C.CODE_CUSTOMER
WHERE     (A.FF = '1' AND A.FF_STATUS = 'ASSIGNED')-- AND A.PICKING_HEADER = B.PICKING_HEADER AND A.CODE_CLIENT = C.CODE_CUSTOMER)

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
               Bottom = 294
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 93
               Left = 435
               Bottom = 213
               Right = 669
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
', @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_GET_FREIGTH_PICKING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'SONDA', @level1type = N'VIEW', @level1name = N'SWIFT_VIEW_GET_FREIGTH_PICKING';

