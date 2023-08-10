
/*=========================

 Autor: diego.as
 Fecha de Creacion: 15-07-206 Sprint ζ
 Descripcion: Inserta un registro de resolucion
    Nota: El SP ya existia, se firma porque carecia de la misma.

Ejemplo de Ejecucion:
    exec [SONDA].SWIFT_SP_INSERT_RESOLUTION
         @AUTH_ID = 'Prueba'
          , @SERIE = 'Prueba'
          , @BRANCH_NAME = '...'
          , @BRANCH_ADDRES = '...'
          , @BRANCH_ADDRESS2 = '...'
          , @BRANCH_ADDRESS3 = '...'
          , @BRANCH_ADDRESS4 = '...'
          , @DOC_FROM = 0
          , @DOC_TO = 500
          , @POST_DATETIME = '7/15/2016 9:23:36 AM'
          , @ASSIGNED_BY = '...'
          , @ASSIGNED_TO = '...'
          , @pResult = ''

=========================*/

CREATE PROC [SONDA].[SWIFT_SP_INSERT_RESOLUTION] 
  @AUTH_ID VARCHAR(50)
  , @SERIE VARCHAR(100)
  , @BRANCH_NAME VARCHAR(50)
  , @BRANCH_ADDRES VARCHAR(150)
  , @BRANCH_ADDRESS2 VARCHAR(30)
  , @BRANCH_ADDRESS3 VARCHAR(30)
  , @BRANCH_ADDRESS4 VARCHAR(30)
  , @DOC_FROM INT
  , @DOC_TO INT
  , @POST_DATETIME DATETIME
  , @ASSIGNED_BY VARCHAR(100)
  , @ASSIGNED_TO VARCHAR(100)
  , @pResult VARCHAR(250) OUTPUT
AS
BEGIN
  --Valida si el numero de resolucion ya fue ingresado
  IF EXISTS (SELECT
        1
      FROM SONDA_POS_RES_SAT
      WHERE AUTH_ID = @AUTH_ID)
  BEGIN
    SELECT
      @pResult = 'El numero de resolucion ya fue ingresado.'
    RETURN -1
  END
  --
  --Valida si la fecha de resolucion tiene 10 dias de antiguedad
  DECLARE @DATE_I DATE;
  DECLARE @DATE_F DATE;

  SELECT
    @DATE_I = GETDATE();
  SELECT
    @DATE_F = DATEADD(DAY, -9, @DATE_I)

  IF @DATE_I < @POST_DATETIME
    OR @DATE_F > @POST_DATETIME
  BEGIN
    SELECT
      @pResult = 'La fecha no puede ser mayor a ' + CONVERT(VARCHAR(10), @DATE_I) + ' y menor a ' + CONVERT(VARCHAR(10), @DATE_F)
    RETURN -1
  END
  --
  BEGIN TRAN t1
  BEGIN
    DECLARE @ASSIGNED_DATETIME DATETIME;
    DECLARE @LIMIT_DATETIME DATETIME;

    --Valida se se asigno la resolucion, SI: engresa la fecha de hoy, NO: ingresa la fecha nula
    SELECT
      @ASSIGNED_DATETIME = GETDATE();

    IF @ASSIGNED_TO = ''
    BEGIN
      SELECT
        @ASSIGNED_DATETIME = NULL;
    END
    --			
    SELECT
      @LIMIT_DATETIME = DATEADD(YEAR, 2, @POST_DATETIME)
    --VAlida si es la primera resolu8cion que se ingresa
    IF (SELECT
          COUNT(*)
        FROM SONDA_POS_RES_SAT)
      = 0
    BEGIN
      SELECT
        @LIMIT_DATETIME = DATEADD(YEAR, 1, @POST_DATETIME)
    END

    INSERT INTO SONDA_POS_RES_SAT ([AUTH_ID]
        , [AUTH_ASSIGNED_DATETIME]
        , [AUTH_POST_DATETIME]
        , [AUTH_ASSIGNED_BY]
        , [AUTH_DOC_FROM]
        , [AUTH_DOC_TO]
        , [AUTH_SERIE]
        , [AUTH_DOC_TYPE]
        , [AUTH_ASSIGNED_TO]
        , [AUTH_CURRENT_DOC]
        , [AUTH_LIMIT_DATETIME]
        , [AUTH_STATUS]
        , [AUTH_BRANCH_NAME]
        , [AUTH_BRANCH_ADDRESS]
        , [BRANCH_ADDRESS2]
        , [BRANCH_ADDRESS3]
        , [BRANCH_ADDRESS4])
      VALUES (@AUTH_ID
        , @ASSIGNED_DATETIME
        , @POST_DATETIME
        , @ASSIGNED_BY
        , @DOC_FROM
        , @DOC_TO
        , @SERIE
        , 'FACTURA'
        , @ASSIGNED_TO
        , @DOC_FROM
        , @LIMIT_DATETIME
        , 1
        , @BRANCH_NAME
        , @BRANCH_ADDRES
        , @BRANCH_ADDRESS2
        , @BRANCH_ADDRESS3
        , @BRANCH_ADDRESS4)
  END
  IF @@error = 0
  BEGIN
    SELECT
      @pResult = 'OK'
    COMMIT TRAN t1
  END
  ELSE
  BEGIN
    ROLLBACK TRAN t1
    SELECT
      @pResult = ERROR_MESSAGE()
  END
END
