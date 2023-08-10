-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/21/2017 @ A-TEAM Sprint  
-- Description:			SP que valida un manifiesto de 3pl escaneado desde sonda sd

-- Modificacion 1/4/2018 @ A-Team Sprint Quiterio
					-- diego.as
					-- Se agregan if's para los nuevos estados del manifiesto

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_MANIFEST_3PL] @MANIFEST_HEADER_ID = 2152
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATE_MANIFEST_3PL (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DATABASE_NAME VARCHAR(MAX)
         ,@SCHEMA_NAME VARCHAR(MAX)
         ,@LINKED_SERVER VARCHAR(50)
         ,@QUERY VARCHAR(MAX);
  --
  -- -----------------------------------------------------------------------
  -- Se obtiene el nombre de la BD y el Esquema de la implementacion de 3PL
  -- -----------------------------------------------------------------------
  SELECT
    @LINKED_SERVER = [S].[LINKED_SERVER]
   ,@DATABASE_NAME = [S].[DATABASE_NAME]
   ,@SCHEMA_NAME = [S].[SCHEMA_NAME]
  FROM [SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
  WHERE [S].[EXTERNAL_SOURCE_ID] > 0;

  -- -------------------------------------------------------------------------------------
  -- Se obtiene el STATUS del manifiesto escaneado para hacer sus diferentes validaciones
  -- -------------------------------------------------------------------------------------
  SELECT
    @QUERY = '
			DECLARE @STATUS_MANIFEST VARCHAR(50);

      SELECT @STATUS_MANIFEST=STATUS 
            FROM  OPENQUERY(' + @LINKED_SERVER + ',''SELECT ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_FUNC_GET_STATUS_MANIFEST_BY_MANIFEST_ID](''''' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + ''''') as STATUS'')           

		IF(@STATUS_MANIFEST = ''CREATED'') 
			BEGIN
				RAISERROR(''El manifiesto aún no ha sido certificado, por favor, verifique y vuelva a intentar.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST = ''CANCELED'') 
			BEGIN
				RAISERROR(''El manifiesto ha sido cancelado, por favor, comuníquese con su asistente de bodega.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST = ''ASSIGNED'') 
			BEGIN
				RAISERROR(''El manifiesto ya fue escaneado y procesado, por favor, verifique y vuelva a intentar.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST = ''CERTIFYING'') 
			BEGIN
				RAISERROR(''El manifiesto se encuentra en proceso de certificación, por favor, verifique y vuelva a intentar.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST = ''IN_PICKING'') 
			BEGIN
				RAISERROR(''El manifiesto tiene pickings pendientes, por favor, verifique y vuelva a intentar.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST = ''COMPLETED'') 
			BEGIN
				RAISERROR(''El manifiesto ya se encuentra completado, por favor, verifique y vuelva a intentar.'',16,1)
			END 
		ELSE IF(@STATUS_MANIFEST <> ''CERTIFIED'') 
			BEGIN
				RAISERROR(''El manifiesto tiene un estado erroneo, por favor, comuníquese con su Administrador.'',16,1)
			END 
		';
  EXEC (@QUERY);

END;
