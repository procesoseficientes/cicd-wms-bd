
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa clientes

-- Modificado Fecha
-- hector.gonzalez
-- Se agrego el campo DISCOUNT
-- Modificado 2016-05-02
-- joel.delcompare
-- Se Agregaron los campos  [OFICINA_VENTAS]	,	[RUTA_VENTAS],		[RUTA_ENTREGA],		[SECUENCIA]

-- Modificado 18-08-2016
-- diego.as
-- Se corrigio el nombre del campo [NAME_CLASIFICATION] ya que tenia doble S y provocaba error

-- Modificado 27-11-2016
-- hector.gonzalez
-- SSe agrego columna RGA_CODE

-- Modificacion 3/14/2017 @ A-Team Sprint Ebonne
-- rodrigo.gomez
-- Se agregaron las columas OWNER y OWNER_ID

-- Modificacion 04-May-17 @ A-Team Sprint Hondo
-- alberto.ruiz
-- Se agrega el campo balance

-- Modificacion 29-May-17 @ A-Team Sprint Jibade
-- alberto.ruiz
-- Se agregaron campos de nit y nombre de facturacion

-- Modificacion 22-Jun-17 @ A-Team Sprint Khalid
-- alberto.ruiz
-- Ajuste por alutech, se agrego el campo [ORGANIZACION_VENTAS]

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrega la columna CODE_CUSTOMER_ALTERNATE para el merge
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_CUSTOMER]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_CUSTOMER]
AS
BEGIN
  SET NOCOUNT ON;
  --
  MERGE [wms].[SWIFT_ERP_CUSTOMERS] [TRG]
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_COSTUMER]) AS [SRC]
  ON [TRG].[CODE_CUSTOMER] = [SRC].[CODE_CUSTOMER] COLLATE DATABASE_DEFAULT
  WHEN MATCHED
    THEN UPDATE
      SET [TRG].[CODE_CUSTOMER] = [SRC].[CODE_CUSTOMER]
         ,[TRG].[NAME_CUSTOMER] = [SRC].[NAME_CUSTOMER]
         ,[TRG].[PHONE_CUSTOMER] = [SRC].[PHONE_CUSTOMER]
         ,[TRG].[ADRESS_CUSTOMER] = [SRC].[ADRESS_CUSTOMER]
         ,[TRG].[CLASSIFICATION_CUSTOMER] = [SRC].[CLASSIFICATION_CUSTOMER]
         ,[TRG].[CONTACT_CUSTOMER] = [SRC].[CONTACT_CUSTOMER]
         ,[TRG].[CODE_ROUTE] = [SRC].[CODE_ROUTE]
         ,[TRG].[LAST_UPDATE] = [SRC].[LAST_UPDATE]
         ,[TRG].[LAST_UPDATE_BY] = [SRC].[LAST_UPDATE_BY]
         ,[TRG].[SELLER_DEFAULT_CODE] = [SRC].[SELLER_DEFAULT_CODE]
         ,[TRG].[CREDIT_LIMIT] = [SRC].[CREDIT_LIMIT]
         ,[TRG].[FROM_ERP] = [SRC].[FROM_ERP]
         ,[TRG].[NAME_ROUTE] = [SRC].[NAME_ROUTE]
         ,[TRG].[NAME_CLASSIFICATION] = [SRC].[NAME_CLASSIFICATION]
         ,[TRG].[GPS] = ISNULL([SRC].[LATITUDE] + ','
          + [SRC].[LONGITUDE], '0,0')
         ,[TRG].[LATITUDE] = ISNULL([SRC].[LATITUDE], '0')
         ,[TRG].[LONGITUDE] = ISNULL([SRC].[LONGITUDE],
          '0')
         ,[TRG].[FREQUENCY] = ISNULL([SRC].[FREQUENCY],
          '1')
         ,[TRG].[SUNDAY] = ISNULL([SRC].[SUNDAY], '0')
         ,[TRG].[MONDAY] = ISNULL([SRC].[MONDAY], '0')
         ,[TRG].[TUESDAY] = ISNULL([SRC].[TUESDAY], '0')
         ,[TRG].[WEDNESDAY] = ISNULL([SRC].[WEDNESDAY],
          '0')
         ,[TRG].[THURSDAY] = ISNULL([SRC].[THURSDAY], '0')
         ,[TRG].[FRIDAY] = ISNULL([SRC].[FRIDAY], '0')
         ,[TRG].[SATURDAY] = ISNULL([SRC].[SATURDAY], '0')
         ,[TRG].[SCOUTING_ROUTE] = [SRC].[SCOUTING_ROUTE]
         ,[TRG].[EXTRA_MONT] = [SRC].[EXTRA_MONT]
         ,[TRG].[EXTRA_DAYS] = [SRC].[EXTRA_DAYS]
         ,[TRG].[DISCOUNT] = [SRC].[DISCOUNT]
         ,[TRG].[OFIVENTAS] = [SRC].[OFICINA_VENTAS]
         ,[TRG].[RUTAVENTAS] = [SRC].[RUTA_VENTAS]
         ,[TRG].[RUTAENTREGA] = [SRC].[RUTA_ENTREGA]
         ,[TRG].[SECUENCIA] = [SRC].[SECUENCIA]
         ,[TRG].[RGA_CODE] = [SRC].[RGA_CODE]
         ,[TRG].[OWNER] = [SRC].[OWNER]
         ,[TRG].[OWNER_ID] = [SRC].[OWNER_ID]
         ,[TRG].[BALANCE] = [SRC].[Balance]
         ,[TRG].[TAX_ID] = [SRC].[TAX_ID]
         ,[TRG].[INVOICE_NAME] = [SRC].[INVOICE_NAME]
         ,[TRG].[ORGANIZACION_VENTAS] = [SRC].[ORGANIZACION_VENTAS]
         ,[TRG].[CODE_CUSTOMER_ALTERNATE] = [SRC].CODE_CUSTOMER_ALTERNATE
  WHEN NOT MATCHED
    THEN INSERT ([CODE_CUSTOMER]
      , [NAME_CUSTOMER]
      , [PHONE_CUSTOMER]
      , [ADRESS_CUSTOMER]
      , [CLASSIFICATION_CUSTOMER]
      , [CONTACT_CUSTOMER]
      , [CODE_ROUTE]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [SELLER_DEFAULT_CODE]
      , [CREDIT_LIMIT]
      , [FROM_ERP]
      , [NAME_ROUTE]
      , [NAME_CLASSIFICATION]
      , [GPS]
      , [LATITUDE]
      , [LONGITUDE]
      , [FREQUENCY]
      , [SUNDAY]
      , [MONDAY]
      , [TUESDAY]
      , [WEDNESDAY]
      , [THURSDAY]
      , [FRIDAY]
      , [SATURDAY]
      , [SCOUTING_ROUTE]
      , [EXTRA_MONT]
      , [EXTRA_DAYS]
      , [DISCOUNT]
      , [OFIVENTAS]
      , [RUTAVENTAS]
      , [RUTAENTREGA]
      , [SECUENCIA]
      , [RGA_CODE]
      , [OWNER]
      , [OWNER_ID]
      , [BALANCE]
      , [TAX_ID]
      , [INVOICE_NAME]
      , [ORGANIZACION_VENTAS]
      , [CODE_CUSTOMER_ALTERNATE])
        VALUES ([SRC].[CODE_CUSTOMER], [SRC].[NAME_CUSTOMER], [SRC].[PHONE_CUSTOMER], [SRC].[ADRESS_CUSTOMER], [SRC].[CLASSIFICATION_CUSTOMER], [SRC].[CONTACT_CUSTOMER], [SRC].[CODE_ROUTE], [SRC].[LAST_UPDATE], [SRC].[LAST_UPDATE_BY], [SRC].[SELLER_DEFAULT_CODE], [SRC].[CREDIT_LIMIT], [SRC].[FROM_ERP], [SRC].[NAME_ROUTE], [SRC].[NAME_CLASSIFICATION], ISNULL([SRC].[LATITUDE] + ',' + [SRC].[LONGITUDE], '0,0'), ISNULL([SRC].[LATITUDE], '0'), ISNULL([SRC].[LONGITUDE], '0'), ISNULL([SRC].[FREQUENCY], '1'), ISNULL([SRC].[SUNDAY], '0'), ISNULL([SRC].[MONDAY], '0'), ISNULL([SRC].[TUESDAY], '0'), ISNULL([SRC].[WEDNESDAY], '0'), ISNULL([SRC].[THURSDAY], '0'), ISNULL([SRC].[FRIDAY], '0'), ISNULL([SRC].[SATURDAY], '0'), [SRC].[SCOUTING_ROUTE], [SRC].[EXTRA_MONT], [SRC].[EXTRA_DAYS], [SRC].[DISCOUNT], [SRC].[OFICINA_VENTAS], [SRC].[RUTA_VENTAS], [SRC].[RUTA_ENTREGA], [SRC].[SECUENCIA], [SRC].[RGA_CODE], [SRC].[OWNER], [SRC].[OWNER_ID], [SRC].[Balance], [SRC].[TAX_ID], [SRC].[INVOICE_NAME], [ORGANIZACION_VENTAS], SRC.CODE_CUSTOMER_ALTERNATE);
END


