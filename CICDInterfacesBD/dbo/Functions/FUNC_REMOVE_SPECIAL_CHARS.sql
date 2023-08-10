

CREATE FUNCTION [dbo].[FUNC_REMOVE_SPECIAL_CHARS] (@Cadena AS VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
  DECLARE @Caracteres VARCHAR(255);
  SET @Caracteres = '-;''´()&\Ñ¡!?#:$%[_*@{}ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜàáâãäåæçèéêëìíîïðñòóôõö÷øùúûü';
  --Quitar Caracteres
  WHILE @Cadena LIKE '%[' + @Caracteres + ']%'
  BEGIN
  SELECT
    @Cadena = REPLACE(@Cadena,
    SUBSTRING(@Cadena,
    PATINDEX('%[' + @Caracteres
    + ']%', @Cadena), 1),
    '');
  END;

  RETURN @Cadena;
END;








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FUNC_REMOVE_SPECIAL_CHARS] TO [ALZAHN]
    AS [dbo];

