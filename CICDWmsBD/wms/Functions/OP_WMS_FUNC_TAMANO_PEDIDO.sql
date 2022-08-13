CREATE function [wms].[OP_WMS_FUNC_TAMANO_PEDIDO] (@pUnidades int) returns varchar(5) as
Begin
	DECLARE @vTamano varchar(5)
	select @vTamano = ISNULL(SIZE,'') from OP_WMS_LINES_BALANCING where @pUnidades between INITIAL_RANGE and FINAL_RANGE
	return @vTamano
End