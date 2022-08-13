-- =============================================
-- Author:		                                    <Author,,Brayan Isidro>
-- Create date:                                     <Create Date,14/10/2019>
-- Description:	      <Description, revisión semanal de productos con precio 0, ya que estos no son leídos en SONDA
--                      Ticket #5                             
--                      Req. Ricardo Matta,Diego Espinoza>
-- =============================================
-- Test:	EXEC Reportes.dbo.Proc_FIN_ProductosPrecioCero


CREATE PROCEDURE Proc_FIN_ProductosPrecioCero
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT Codigo, Articulo, Existencia, PrecioMinimo = MAX(PrecioMinimo), 
          PrecioPubliclo = MAX(PrecioPubliclo), 
          TipoArticulo = CASE WHEN Codigo LIKE 'S%' THEN 'Suministro' ELSE 'Normal' END  
          FROM 
(
SELECT Codigo = Articulos.CVE_ART, Articulo = DESCR, Existencia = EXIST, 
          PrecioMinimo   = CASE WHEN DESCRIPCION = 'Precio mínimo'  THEN PRECIO ELSE 0 END, 
          PrecioPubliclo = CASE WHEN DESCRIPCION = 'Precio público' THEN PRECIO ELSE 0 END
FROM dbo.INVE01 Articulos 
       LEFT JOIN dbo.PRECIO_X_PROD01 PreciosArticulos 
             ON Articulos.CVE_ART = PreciosArticulos.CVE_ART
       LEFT JOIN dbo.PRECIOS01 Precios 
             ON PreciosArticulos.CVE_PRECIO = Precios.CVE_PRECIO

   WHERE Articulos.CVE_ART NOT LIKE 'S%'

--WHERE EXIST > 0 
) AS Datos
GROUP BY Codigo, Articulo, Existencia
--HAVING ( MAX(PrecioMinimo) = 0 OR MAX(PrecioPubliclo) = 0 )
HAVING ( MAX(PrecioMinimo) = 0 )
--SELECT * FROM PRECIO_X_PROD01

--SELECT * FROM PRECIOS01




 
END
