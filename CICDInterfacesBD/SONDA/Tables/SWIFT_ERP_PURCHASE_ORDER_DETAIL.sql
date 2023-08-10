CREATE TABLE [SONDA].[SWIFT_ERP_PURCHASE_ORDER_DETAIL] (
    [ItemCode]       NVARCHAR (20) NULL,
    [DocEntry]       INT           NOT NULL,
    [ObjType]        NVARCHAR (20) NULL,
    [Line_Num]       INT           NOT NULL,
    [Warehouse_Code] NVARCHAR (8)  NOT NULL,
    [Sales_Unit]     VARCHAR (2)   NOT NULL
);

