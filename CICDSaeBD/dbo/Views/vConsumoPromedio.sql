﻿CREATE VIEW dbo.vConsumoPromedio
AS
SELECT        CVE_ART, ALMACEN, ConsumoPromedio, ISNULL(Transito, 0) AS Transito
FROM            (SELECT        CVE_ART, ALMACEN, ISNULL(SUM(CANT * SIGNO * - 1), 0) / 4 AS ConsumoPromedio,
                                                        (SELECT        ISNULL(SUM(DetalleOrden.CANT), 0) AS Transito
                                                          FROM            dbo.COMPO01 AS OrdenesCompra WITH (NOLOCK) LEFT OUTER JOIN
                                                                                    dbo.PAR_COMPO01 AS DetalleOrden WITH (NOLOCK) ON OrdenesCompra.CVE_DOC = DetalleOrden.CVE_DOC
                                                          WHERE        (DetalleOrden.CVE_ART = Inventarios.CVE_ART) AND (Inventarios.ALMACEN = OrdenesCompra.NUM_ALMA) AND (OrdenesCompra.STATUS NOT IN ('C')) AND 
                                                                                    (OrdenesCompra.FECHA_DOC >= '2020-01-01') AND (OrdenesCompra.DOC_SIG IS NULL)
                                                          GROUP BY DetalleOrden.CVE_ART) AS Transito
                          FROM            dbo.MINVE01 AS Inventarios WITH (NOLOCK)
                          WHERE        (CVE_ART = CVE_ART) AND (FECHA_DOCU >= DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 5, 0)) AND (FECHA_DOCU <= DATEADD(MONTH, DATEDIFF(MONTH, - 1, GETDATE()) - 1, - 1)) AND 
                                                    (CVE_CPTO IN (2, 4, 51, 56))
                          GROUP BY CVE_ART, ALMACEN) AS Datos

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
         Begin Table = "Datos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 231
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vConsumoPromedio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vConsumoPromedio';

