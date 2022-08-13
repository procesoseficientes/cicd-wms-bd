
-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Elimina de las 3 tablas filtrando por secuencia.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] @Sequence = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE] (@Sequence INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE FROM [wms].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]
  WHERE [Sequence] = @Sequence
  --
  DELETE FROM [wms].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
  WHERE [Sequence] = @Sequence
  --
  DELETE FROM [wms].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
  WHERE [Sequence] = @Sequence
--
END

