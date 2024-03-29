﻿
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	20-01-2016
-- Description:			obtiene los pallets que van a expirar y tienen permitido hacer picking

/*
-- Ejemplo de Ejecucion:				
				--
EXECUTE  [SONDA].[SWIFT_SP_GET_MOBILE_LOCATION]
@CODE_WAREHOUSE = 'BODEGA_CENTRAL', 
@FLOOR_LOCATION = '',
@TYPE_LOCATION ='RACK' ,
@NAME_LOCATION =''

EXECUTE  [SONDA].[SWIFT_SP_GET_MOBILE_LOCATION]
@CODE_WAREHOUSE = 'BODEGA_CENTRAL', 
@FLOOR_LOCATION = '',
@TYPE_LOCATION ='' ,
@NAME_LOCATION =''



				--				
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_MOBILE_LOCATION]

@CODE_WAREHOUSE AS [varchar](50), 
@FLOOR_LOCATION AS [varchar](5),
@TYPE_LOCATION AS [varchar](10),
@NAME_LOCATION AS [varchar](50)
AS
BEGIN 

	SET NOCOUNT ON;
      
IF @TYPE_LOCATION = 'PASILLO'
  BEGIN
	SELECT [LOCATION]
      ,[CODE_LOCATION]
      ,[CLASSIFICATION_LOCATION]
      ,[HALL_LOCATION]
      ,[ALLOW_PICKING]
      ,[DESCRIPTION_WAREHOUSE]
      ,[CODE_WAREHOUSE]
      ,[BARCODE_LOCATION]
      ,[DESCRIPTION_LOCATION]
      ,[RACK_LOCATION]
      ,[COLUMN_LOCATION]
      ,[LEVEL_LOCATION]
      ,[SQUARE_METER_LOCATION]
      ,[FLOOR_LOCATION]
      ,[ALLOW_STORAGE]
      ,[ALLOW_RELOCATION]
      ,[STATUS_LOCATION]
	FROM [SONDA].[SWIFT_VIEW_ALL_LOCATIONS]
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE AND [CLASSIFICATION_LOCATION] = 'PASILLO' AND (FLOOR_LOCATION = @FLOOR_LOCATION OR  @FLOOR_LOCATION ='')
	AND ([HALL_LOCATION] = @NAME_LOCATION OR  @NAME_LOCATION = '')
 END
 ELSE
 IF @TYPE_LOCATION = 'RACK'
  BEGIN
	SELECT [LOCATION]
      ,[CODE_LOCATION]
      ,[CLASSIFICATION_LOCATION]
      ,[HALL_LOCATION]
      ,[ALLOW_PICKING]
      ,[DESCRIPTION_WAREHOUSE]
      ,[CODE_WAREHOUSE]
      ,[BARCODE_LOCATION]
      ,[DESCRIPTION_LOCATION]
      ,[RACK_LOCATION]
      ,[COLUMN_LOCATION]
      ,[LEVEL_LOCATION]
      ,[SQUARE_METER_LOCATION]
      ,[FLOOR_LOCATION]
      ,[ALLOW_STORAGE]
      ,[ALLOW_RELOCATION]
      ,[STATUS_LOCATION]
	FROM [SONDA].[SWIFT_VIEW_ALL_LOCATIONS]
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE AND [CLASSIFICATION_LOCATION] = 'RACK' AND (FLOOR_LOCATION = @FLOOR_LOCATION OR  @FLOOR_LOCATION ='')
	AND ([RACK_LOCATION] = @NAME_LOCATION OR  @NAME_LOCATION = '')
 END
 ELSE
 IF @TYPE_LOCATION = 'PISO'
  BEGIN
	SELECT [LOCATION]
      ,[CODE_LOCATION]
      ,[CLASSIFICATION_LOCATION]
      ,[HALL_LOCATION]
      ,[ALLOW_PICKING]
      ,[DESCRIPTION_WAREHOUSE]
      ,[CODE_WAREHOUSE]
      ,[BARCODE_LOCATION]
      ,[DESCRIPTION_LOCATION]
      ,[RACK_LOCATION]
      ,[COLUMN_LOCATION]
      ,[LEVEL_LOCATION]
      ,[SQUARE_METER_LOCATION]
      ,[FLOOR_LOCATION]
      ,[ALLOW_STORAGE]
      ,[ALLOW_RELOCATION]
      ,[STATUS_LOCATION]
	FROM [SONDA].[SWIFT_VIEW_ALL_LOCATIONS]
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE AND [CLASSIFICATION_LOCATION] = 'PISO' AND (FLOOR_LOCATION ='SI')
 END

 ELSE
   BEGIN
	SELECT [LOCATION]
      ,[CODE_LOCATION]
      ,[CLASSIFICATION_LOCATION]
      ,[HALL_LOCATION]
      ,[ALLOW_PICKING]
      ,[DESCRIPTION_WAREHOUSE]
      ,[CODE_WAREHOUSE]
      ,[BARCODE_LOCATION]
      ,[DESCRIPTION_LOCATION]
      ,[RACK_LOCATION]
      ,[COLUMN_LOCATION]
      ,[LEVEL_LOCATION]
      ,[SQUARE_METER_LOCATION]
      ,[FLOOR_LOCATION]
      ,[ALLOW_STORAGE]
      ,[ALLOW_RELOCATION]
      ,[STATUS_LOCATION]
	FROM [SONDA].[SWIFT_VIEW_ALL_LOCATIONS]
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE AND FLOOR_LOCATION = @FLOOR_LOCATION

 END




END
