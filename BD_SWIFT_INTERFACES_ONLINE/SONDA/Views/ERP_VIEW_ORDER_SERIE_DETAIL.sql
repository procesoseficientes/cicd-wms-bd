


CREATE VIEW [SONDA].[ERP_VIEW_ORDER_SERIE_DETAIL]
AS
    SELECT  null SysNumber ,
            null MnfSerial ,
            null ItemCode;
--SELECT *FROM OPENQUERY (ERP_SERVER,'SELECT     [Prueba].dbo.OSRN.SysNumber, [Prueba].dbo.OSRN.MnfSerial, [Prueba].dbo.OSRN.ItemCode
--                                                    FROM          [Prueba].dbo.PDN1 INNER JOIN
--                                                                           [Prueba].dbo.OPDN ON [Prueba].dbo.PDN1.DocEntry = [Prueba].dbo.OPDN.DocEntry INNER JOIN
--                                                                           [Prueba].dbo.OITL ON [Prueba].dbo.PDN1.ItemCode = [Prueba].dbo.OITL.ItemCode AND [Prueba].dbo.PDN1.DocEntry = [Prueba].dbo.OITL.DocEntry AND 
--                                                                           [Prueba].dbo.PDN1.LineNum = [Prueba].dbo.OITL.DocLine INNER JOIN
--                                                                           [Prueba].dbo.ITL1 ON [Prueba].dbo.OITL.LogEntry = [Prueba].dbo.ITL1.LogEntry INNER JOIN
--                                                                           [Prueba].dbo.OSRN ON [Prueba].dbo.ITL1.MdAbsEntry = [Prueba].dbo.OSRN.AbsEntry
--                                                    WHERE      ([Prueba].dbo.OITL.DocType = 20) AND ([Prueba].dbo.OITL.ManagedBy = 10000045) ')

