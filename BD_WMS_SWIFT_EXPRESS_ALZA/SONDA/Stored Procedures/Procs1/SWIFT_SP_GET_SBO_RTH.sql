CREATE PROC [SONDA].[SWIFT_SP_GET_SBO_RTH]
@DOC_ENTRY VARCHAR(50)
AS
SELECT 
rt.RECEPTION_HEADER DocNum,
rt.RECEPTION_HEADER DocEntry ,
rt.CODE_PROVIDER CardCode ,
cus.NAME_CUSTOMER CardName,
'N'  HandWritten , 
rt.LAST_UPDATE DocDate ,
rt.COMMENTS Comments ,
'-' DocCur ,
1.0 DocRate ,
rt.REFERENCE  Reference ,
CAST(NULL AS varchar) AS UFacSerie,
CAST(NULL AS varchar) AS UFacNit, 
CAST(NULL AS varchar) AS UFacNom, 
CAST(NULL AS varchar) AS UFacFecha, 
CAST(NULL AS varchar) AS UTienda, 
CAST(NULL AS varchar) AS UStatusNc, 
CAST(NULL AS varchar) AS UnoExencion, 
CAST(NULL AS varchar) AS UtipoDocumento, 
CAST(NULL AS varchar) AS UUsuario, 
CAST(NULL AS varchar) AS UFacnum, 
CAST(NULL AS varchar) AS USucursal, 
CAST(NULL AS varchar) AS U_Total_Flete, 
CAST(NULL AS varchar) AS UTipoPago, 
CAST(NULL AS varchar) AS UCuotas, 
CAST(NULL AS varchar) AS UTotalTarjeta, 
CAST(NULL AS varchar) AS UFechap, 
CAST(NULL AS varchar) AS UTrasladoOC  ,
cast(rt.RECEPTION_HEADER as varchar)  as UTDev , 
case rt.TYPE_RECEPTION
	when   'RT' then (
						select cl.name_classification from  [SONDA].[SWIFT_CLASSIFICATION] cl 
							where rt.TYPE_RECEPTION = cl.MPC01 )--'Recepcion por Devolucion' 
	when   'RR' then (
						select cl.name_classification from  [SONDA].[SWIFT_CLASSIFICATION] cl 
							where rt.TYPE_RECEPTION = cl.MPC01 )--'Devolucion por reparacion' 
	else rt.TYPE_RECEPTION
end UDescTDev
  FROM [SONDA].SWIFT_RECEPTION_HEADER  rt
  inner join [SONDA].SWIFT_VIEW_ALL_COSTUMER  cus
  on cus.CODE_CUSTOMER = rt.CODE_PROVIDER 
where rt.RECEPTION_HEADER = @DOC_ENTRY 
and rt.TYPE_RECEPTION in ('RT','RR') 
and ISNULL(IS_POSTED_ERP,0) = 0
