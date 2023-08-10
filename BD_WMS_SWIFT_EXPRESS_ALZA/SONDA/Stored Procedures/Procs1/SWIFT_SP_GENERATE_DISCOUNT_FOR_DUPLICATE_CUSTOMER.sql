-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Feb-17 @ A-Team Sprint Chatuluka
-- Description:			    SP que administra el proceso de generar los descuentos para los clientes que esten en ambas casos de los acuerdos comerciales


-- Autor:					rudi.garcia
-- Fecha de Creacion: 		08-May-2018 @ G-Force Sprint Caribú
-- Description:			    Se agregaron las siguientes condicione de donde obtener el sp a generar

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FOR_DUPLICATE_CUSTOMER]
					@CODE_ROUTE = '4'
					,@TYPE = 'GENERAL_AMOUNT'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_DISCOUNT_FOR_DUPLICATE_CUSTOMER (@CODE_ROUTE VARCHAR(250)
, @TYPE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @DESCRIPTION VARCHAR(250)
         ,@SP NVARCHAR(500)
         ,@ORDER INT
  --
  DECLARE @PROC TABLE (
    [DESCRIPTION] VARCHAR(250)
   ,[SP] VARCHAR(250)
   ,[ORDER] INT
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene los SPs a ejecutar
  -- ------------------------------------------------------------------------------------
  INSERT INTO @PROC ([DESCRIPTION]
  , [SP]
  , [ORDER])
    SELECT
      [DP].[DESCRIPTION]
     ,CASE @TYPE
        WHEN 'GENERAL_AMOUNT' THEN [DP].[SP_SWIFT_EXPRESS_GENERAL_AMOUNT]
        WHEN 'GENERAL_AMOUNT_AND_FAMILY' THEN [DP].[SP_SWIFT_EXPRESS_GENERAL_AMOUNT_AND_FAMILY]
        WHEN 'FAMILY_AND_PAYMENT_TYPE' THEN [DP].[SP_SWIFT_EXPRESS_FAMILY_AND_PAYMENT_TYPE]
      END
     ,[ORDER]
    FROM [SONDA].[SWIFT_DISCOUNT_PRIORITY] [DP]
    WHERE [DP].[ACTIVE_SWIFT_INTERFACE_ONLINE] = 1
    ORDER BY [DP].[ORDER];

  -- ------------------------------------------------------------------------------------
  -- Elimina los registros que esten vacios o nulos en el campo del SP
  -- ------------------------------------------------------------------------------------
  DELETE FROM @PROC
  WHERE [SP] IS NULL
    OR [SP] = ''

  -- ------------------------------------------------------------------------------------
  -- Recorre cada registro y lo manda a ejecutar
  -- ------------------------------------------------------------------------------------
  PRINT 'Inicia ciclo'
  --
  WHILE EXISTS (SELECT TOP 1
        1
      FROM @PROC)
  BEGIN
    -- ------------------------------------------------------------------------------------
    -- Obtiene el SP por ejecutar
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @DESCRIPTION = [DESCRIPTION]
     ,@SP = SP
     ,@ORDER = [ORDER]
    FROM @PROC
    ORDER BY [ORDER]
    --
    PRINT '@DESCRIPTION: ' + @DESCRIPTION
    PRINT '@SP: ' + @SP

    -- ------------------------------------------------------------------------------------
    -- Ejecuta el SP
    -- ------------------------------------------------------------------------------------
    SET @SP = @SP + ' @CODE_ROUTE = ' + CAST(@CODE_ROUTE AS VARCHAR) + ' , @ORDER = ' + CAST(@ORDER AS VARCHAR)
    --
    PRINT '@SP: ' + @SP
    --
    EXEC (@SP)
    --
    PRINT 'Ejecucion exitosa'

    -- ------------------------------------------------------------------------------------
    -- Elimina el cliente actual por ruta
    -- ------------------------------------------------------------------------------------
    DELETE FROM @PROC
    WHERE [ORDER] = @ORDER
      AND [DESCRIPTION] = @DESCRIPTION
    --
    PRINT 'Elimina registro'
  END
  --
  PRINT 'Termina ciclo'
END
