-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	04-01-2017 @ A-TEAM Sprint Balder
-- Description:			obtien los primeros 5 Documentos de Picking para la interfaz

/*
-- Ejemplo de Ejecucion:
      --
      USE SWIFT_EXPRESS
      GO
      --
      EXEC [SONDA].[SWIFT_SP_GET_TOP5_PICKING_DOCUMENT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP5_PICKING_DOCUMENT]
  AS
  BEGIN
    SELECT TOP 5
      [sph].[PICKING_HEADER]
     ,[sph].[CLASSIFICATION_PICKING]
     ,[sph].[CODE_CLIENT]
     ,[svac].[NAME_CUSTOMER]
     ,[svac].[ADRESS_CUSTOMER]
     ,[sph].[CODE_USER]
     ,[sph].[REFERENCE]
     ,[sph].[DOC_SAP_RECEPTION]
     ,[sph].[STATUS]
     ,[sph].[LAST_UPDATE]
     ,[sph].[LAST_UPDATE_BY]
     ,[sph].[COMMENTS]
     ,[sph].[SCHEDULE_FOR]
     ,[sph].[SEQ]
     ,[sph].[FF]
     ,[sph].[FF_STATUS]
     ,[sph].[ATTEMPTED_WITH_ERROR]
     ,[sph].[IS_POSTED_ERP]
     ,[sph].[POSTED_ERP]
     ,[sph].[POSTED_RESPONSE]
     ,[sph].[CODE_WAREHOUSE_SOURCE]
     ,[sph].[SOURCE_DOC_TYPE]
     ,[sph].[SOURCE_DOC]
     ,[sph].[TARGET_DOC]
     ,[sph].[CODE_SELLER]
     ,[sph].[CODE_ROUTE]
     ,[sph].[ERP_REFERENCE] 
      FROM [SONDA].[SWIFT_PICKING_HEADER] [sph]
      INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [svac] ON(
      [sph].[CODE_CLIENT] = [svac].[CODE_CUSTOMER]
      )
      WHERE [sph].[STATUS] = 'CLOSED'
      AND ISNULL([sph].[IS_POSTED_ERP],0) = 0
      ORDER BY [sph].[LAST_UPDATE] ASC
END
