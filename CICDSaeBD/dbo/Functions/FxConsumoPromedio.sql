-- =============================================
-- Author:		<Author,		Diego Espinoza M.>
-- Create date: <Create Date,	Marzo 4 del 2020>
-- Description:	<Description,	Funcion para Obtener el Consumo Promedio de los ultimos 4 meses completos desde movimientos de Inventario SAE.
--								incluye conceptos: ventas, devolucion de Ventas. Cancelacion de Ventas, Cancelacion de Devolucion.
--								Para Reporte de Sugerido de Compra en Swift. Req. by DEM, Mobility>
--Test:			SELECT * FROM SAE70EMPRESA01.dbo.FxConsumoPromedio()
-- =============================================
CREATE FUNCTION [dbo].[FxConsumoPromedio]
(	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT CVE_ART, ALMACEN, ConsumoPromedio, Transito = ISNULL(Transito, 0) FROM 
	(
	SELECT CVE_ART, ALMACEN, ConsumoPromedio = ( ISNULL(SUM(CANT * SIGNO*-1), 0) / 4 ), 
	       Transito = (
						SELECT Transito = ISNULL(SUM(CANT), 0)
						FROM dbo.COMPO01 OrdenesCompra WITH (NOLOCK)
							LEFT JOIN dbo.PAR_COMPO01 DetalleOrden WITH (NOLOCK)
								ON OrdenesCompra.CVE_DOC = DetalleOrden.CVE_DOC
						WHERE CVE_ART = Inventarios.CVE_ART
							AND ALMACEN = OrdenesCompra.NUM_ALMA
							AND STATUS NOT IN ('C')
							AND FECHA_DOC >= '2020-01-01'
							AND DOC_SIG IS NULL 
						GROUP BY CVE_ART 
					  )
	FROM dbo.MINVE01 Inventarios WITH (NOLOCK)  
	WHERE CVE_ART = Inventarios.CVE_ART
		AND FECHA_DOCU >= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE()) -5, 0) 
		AND FECHA_DOCU <= DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE()) -1, -1)
		AND CVE_CPTO IN (2, 4, 51, 56)
	GROUP BY CVE_ART, ALMACEN
	) AS Datos 

)
