



-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	11-05-2016
-- Description:			Obtiene los centros de costo por bodega

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_COST_CENTER_BY_WAREHOUSE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_COST_CENTER_BY_WAREHOUSE]
AS
    SELECT  NULL Descr ,
            NULL WhsCode;
--select * from openquery (ERP_SERVER,'SELECT  T1.Descr, T0.WhsCode
--										  FROM [prueba].[dbo].OWHS T0
--										  INNER JOIN [prueba].[dbo].UFD1 T1 ON (T0.U_CBAlmacen = T1.IndexID)
--										  WHERE  T1.TableID = ''OWHS'' ')

--SELECT  [Descr], [WhsCode] FROM OPENQUERY (ERP_SERVER,'SELECT  T0.WhsCode Descr,T0.U_CBAlmacen WhsCode
--										  FROM [PRUEBA].[dbo].OWHS T0')

