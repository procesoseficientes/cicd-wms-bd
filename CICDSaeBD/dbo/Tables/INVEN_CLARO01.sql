CREATE TABLE [dbo].[INVEN_CLARO01] (
    [CVE_ART]        VARCHAR (16)   NOT NULL,
    [CVE_PUBL_CS]    VARCHAR (20)   NULL,
    [EDO_PUBL_CS]    VARCHAR (1)    NULL,
    [EDO_PROD_CS]    VARCHAR (8)    NULL,
    [DESC_CS]        VARCHAR (250)  NULL,
    [SKU_CS]         VARCHAR (18)   NULL,
    [EAN_CS]         VARCHAR (60)   NULL,
    [CATEG_CS]       VARCHAR (30)   NULL,
    [CVE_CATE_CS]    VARCHAR (60)   NULL,
    [MARCA_CS]       VARCHAR (60)   NULL,
    [TIEMP_EMBARQ]   INT            NULL,
    [LARGO_CS]       FLOAT (53)     NULL,
    [ALTO_CS]        FLOAT (53)     NULL,
    [ANCHO_CS]       FLOAT (53)     NULL,
    [LAST_UPDATE_CS] DATETIME       NULL,
    [IMAGEN_CS]      TEXT           NULL,
    [DISP_PUBL_CS]   VARCHAR (1)    NULL,
    [F_CREA_CS]      DATETIME       NULL,
    [FULFILLMENT]    VARCHAR (1)    NULL,
    [DESCR_ESP]      VARCHAR (4000) NULL,
    CONSTRAINT [PK_INVEN_CLARO01] PRIMARY KEY CLUSTERED ([CVE_ART] ASC)
);

