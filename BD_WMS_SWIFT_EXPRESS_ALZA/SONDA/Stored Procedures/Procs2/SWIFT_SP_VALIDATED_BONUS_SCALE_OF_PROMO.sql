/*=======================================================
Autor:				      hector.gonzalez
Fecha de Creacion:	04-08-2017 REBORN-TEAM @ Bearbeitung
Descripcion:		Valida si los datos de bonificacion que se envian como parametros, no colisionan con algun registro ya existente.

Ejemplo de Ejecucion:

	EXEC [SONDA].SWIFT_SP_VALIDATED_BONUS_SCALE_OF_PROMO
		@PROMO_ID = 21
		,@CODE_SKU = '100005'
		,@PACK_UNIT = 7
		,@LOW_LIMIT = 1
		,@HIGH_LIMIT = 15
		,@CODE_SKU_BONUS = '100005'
		,@PACK_UNIT_BONUS = 7
		,@BONUS_QTY = 1
		------------------------------
		SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE]
=======================================================*/
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATED_BONUS_SCALE_OF_PROMO (@PROMO_ID INT
, @CODE_SKU VARCHAR(50)
, @PACK_UNIT INT
, @LOW_LIMIT NUMERIC(18, 0)
, @HIGH_LIMIT NUMERIC(18, 0)
, @CODE_SKU_BONUS VARCHAR(50)
, @PACK_UNIT_BONUS INT
, @BONUS_QTY NUMERIC(18, 0)
, @PROMO_BONUS_BY_SCALE_ID INT = NULL)
AS
BEGIN
  --
  SET NOCOUNT ON;

  --
  DECLARE @MESSAGE VARCHAR(250) = NULL

  --
  SELECT TOP 1
    @MESSAGE =
              CASE
                WHEN @LOW_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT THEN 'Limite inferior del SKU: ' + CAST(@CODE_SKU AS VARCHAR) + ' entre rango existente'
                WHEN @HIGH_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT THEN 'Limite superior del SKU: ' + CAST(@CODE_SKU AS VARCHAR) + ' entre rango existente'
                WHEN S.LOW_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango del SKU: ' + CAST(@CODE_SKU AS VARCHAR) + ' absorbe un rango ya existente'
                WHEN S.HIGH_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango del SKU: ' + CAST(@CODE_SKU AS VARCHAR) + ' absorbe un rango ya existente'
                ELSE 'Rangos mal definidos'
              END
  FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE] AS S
  WHERE S.CODE_SKU = @CODE_SKU
  AND S.PACK_UNIT = @PACK_UNIT
  AND (
  (
  (@LOW_LIMIT > S.LOW_LIMIT AND  @LOW_LIMIT< S.HIGH_LIMIT)
  OR (@HIGH_LIMIT > S.LOW_LIMIT AND @HIGH_LIMIT< S.HIGH_LIMIT)
  )
  OR (
  (S.LOW_LIMIT > @LOW_LIMIT AND [S].[LOW_LIMIT]< @HIGH_LIMIT)
  OR (S.HIGH_LIMIT > @LOW_LIMIT AND [S].[HIGH_LIMIT] < @HIGH_LIMIT)
  )
  )
  AND S.[PROMO_ID] = @PROMO_ID


  --
  IF @MESSAGE IS NOT NULL
  BEGIN
    RAISERROR (@MESSAGE, 16, 1)
  END
END
