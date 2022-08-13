-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 4
-- Description:			    Funcion que genera una tabla de un split del caracter indicado

-- Modificacion 8/9/2017 @ NEXUS-Team Sprint Banjo-Kazooie
					-- rodrigo.gomez
					-- Se cambio a NVARCHAR(MAX) 

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_SPLIT]('A|B|C|D','|')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_SPLIT]
(
    @STRING NVARCHAR(MAX)
    ,@DELIMITER NCHAR(1)
)
RETURNS @RtnValue table
(
	ID int identity(1,1),
	VALUE nvarchar(100)
)
AS
BEGIN
	Declare @Cnt int
	Set @Cnt = 1

	While (Charindex(@DELIMITER,@STRING)>0)
	Begin
		Insert Into @RtnValue (VALUE)
		Select
			Data = ltrim(rtrim(Substring(@STRING,1,Charindex(@DELIMITER,@STRING)-1)))

		Set @STRING = Substring(@STRING,Charindex(@DELIMITER,@STRING)+1,len(@STRING))
		Set @Cnt = @Cnt + 1
	End
	
	Insert Into @RtnValue (VALUE)
	Select Data = ltrim(rtrim(@STRING))

	Return
END