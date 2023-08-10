CREATE VIEW  [SONDA].[SWIFT_VIEW_SBO_PURCHASE_ORDER_HEADER] 
AS 
SELECT     TOP (1) [po].[Doc_Entry] AS [Doc_Entry], [po].[Card_Code] AS [Card_Code], [po].[Card_Name] AS [Card_Name], 'N' AS [Hand_Written], ISNULL([t].[TXN_CREATED_STAMP], GETDATE()) AS [Doc_Date], [po].[Comments] AS [Comments], 
                      [po].[Doc_Cur] AS [Doc_Cur], [po].[Doc_Rate] AS [Doc_Rate], CAST(NULL AS varchar) AS [U_FacSerie], CAST(NULL AS varchar) AS [U_FacNit], CAST(NULL AS varchar) AS [U_FacNom], CAST(NULL AS varchar) 
                      AS [U_FacFecha], CAST(NULL AS varchar) AS [U_Tienda], CAST(NULL AS varchar) AS [U_STATUS_NC], CAST(NULL AS varchar) AS [U_NO_EXENCION], CAST(NULL AS varchar) AS [U_TIPO_DOCUMENTO], 
                      CAST(NULL AS varchar) AS [U_usuario], CAST(NULL AS varchar) AS [U_Facnum], CAST(NULL AS varchar) AS [U_SUCURSAL], CAST(NULL AS varchar) AS [U_Total_Flete], CAST(NULL AS varchar) 
                      AS [U_Tipo_Pago], CAST(NULL AS varchar) AS [U_Cuotas], CAST(NULL AS varchar) AS [U_Total_Tarjeta], CAST(NULL AS varchar) AS [U_FECHAP], CAST(NULL AS varchar) AS [U_TrasladoOC]
FROM         [SONDA].[SWIFT_TXNS] AS [t] INNER JOIN
                      [SWIFT_INTERFACES].[SONDA].[ERP_VIEW_PURCHASE_ORDER_HEADER] AS [po] ON [po].[Doc_Entry] = [t].[SAP_REFERENCE]
WHERE     ([t].[TXN_CATEGORY] = 'PO') AND (ISNULL([t].[TXN_IS_POSTED_ERP], 0) = 0)
