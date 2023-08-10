;
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			    Obtiene las consignaciones de una ruta

-- MODIFICADO:			06-10-2016 @ A-TEAM Sprint 2
--		Autor:			diego.as
--		Descripcion:	Se agregan los Campos DOC_SERIE, DOC_NUM, IMG E IS_CLOSED

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-14 @ Team REBORN - Sprint Eberhard
-- Description:	   Se agrega tipo de consignacion

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SONDA_SP_GET_CONSIGNMENTS_BY_ROUTE  @CODE_ROUTE = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_CONSIGNMENTS_BY_ROUTE @CODE_ROUTE VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  --
  UPDATE [SONDA].SWIFT_CONSIGNMENT_HEADER
  SET IS_ACTIVE_ROUTE = 1
  WHERE POS_TERMINAL = @CODE_ROUTE
  -- 
  SELECT
    [H].[CONSIGNMENT_ID]
   ,[H].[CUSTOMER_ID]
   ,[H].[DATE_CREATE]
   ,[H].[DATE_UPDATE]
   ,[H].[STATUS]
   ,[H].[POSTED_BY]
   ,[H].[IS_POSTED]
   ,[H].[POS_TERMINAL]
   ,[H].[GPS_URL]
   ,[H].[DOC_DATE]
   ,[H].[CLOSED_ROUTE_DATETIME]
   ,[H].[IS_ACTIVE_ROUTE]
   ,[H].[DUE_DATE]
   ,[H].[CONSIGNMENT_HH_NUM]
   ,[H].[TOTAL_AMOUNT]
   ,[H].[DOC_SERIE]
   ,[H].[DOC_NUM]
   ,[H].[IMG]
   ,[H].[IS_CLOSED]
   ,[H].[CONSIGNMENT_TYPE]
  FROM [SONDA].SWIFT_CONSIGNMENT_HEADER H
  WHERE H.POS_TERMINAL = @CODE_ROUTE
  AND H.STATUS <> 'CANCELLED'
END
