-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [wms].[GET_ORDERS] 
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	--INSERT INTO [192.168.16.158].[OP_WMS].[cealsa].[OP_WMS_DEMAND_TO_PICK]
	INSERT INTO [wms].[OP_WMS_DEMAND_TO_PICK]
				   ([ERP_DOCUMENT]
				   ,[ERP_DOC_DATE]
				   ,[LOADED_DATE]
				   ,[CLIENT_ID]
				   ,[CLIENT_NAME]
				   ,[CLIENT_ROUTE]
				   ,[MATERIAL_ID]
				   ,[MATERIAL_NAME]
				   ,[QTY]
				   ,[IS_ASSIGNED]
				   ,[ASSIGNED_BY]
				   ,[CLIENT_REGION])
		Select distinct 
			A.DocNum as Documento
		,	A.DocDate as FechaDoc 
		,	Current_TimeStamp as FechaCargado
		,	A.CardCode as CodigoCliente
		,	A.CardName as NombreCliente
		,	isnull(C.U_RTU, ' ') as RutaCliente --C.U_RUTA
		,	B.ItemCode as Articulo
		,	B.Dscription as NombreArticulo
		,	SUM(B.Quantity) as Cantidad
		,	0 as Asignado
		,	NULL as Asignadopor
		,   ISNULL(D.Slpname, '') as Region
		from 
			nave_SB1.dbo.OINV A JOIN
			nave_SB1.dbo.INV1 B ON A.DOCENTRY = B.DOCENTRY and B.TreeType in ('N', 'I') JOIN
			nave_SB1.dbo.OCRD C ON A.CardCode = C.CardCode JOIN
			nave_SB1.dbo.OSLP D ON C.SlpCode = D.SlpCode
		WHERE 
			--A.DocEntry = @List_of_Cols_Val_Tab_Del
			A.DocDate >= GETDATE()-1
			and a.Series in (42,43)
		group by 
			A.DocNum
		,	A.DocDate
		,	A.CardCode
		,	A.CardName
		,	isnull(C.U_RTU , ' ')--C.U_RUTA
		,	B.ItemCode
		,	B.Dscription
		,   ISNULL(D.Slpname, '')
END