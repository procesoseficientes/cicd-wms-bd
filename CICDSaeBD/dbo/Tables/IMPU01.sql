CREATE TABLE [dbo].[IMPU01] (
    [CVE_ESQIMPU]  INT          NOT NULL,
    [DESCRIPESQ]   VARCHAR (40) NULL,
    [IMPUESTO1]    FLOAT (53)   NULL,
    [IMP1APLICA]   INT          NULL,
    [IMPUESTO2]    FLOAT (53)   NULL,
    [IMP2APLICA]   INT          NULL,
    [IMPUESTO3]    FLOAT (53)   NULL,
    [IMP3APLICA]   INT          NULL,
    [IMPUESTO4]    FLOAT (53)   NULL,
    [IMP4APLICA]   INT          NULL,
    [STATUS]       VARCHAR (1)  NULL,
    [UUID]         VARCHAR (50) NULL,
    [VERSION_SINC] DATETIME     NULL,
    CONSTRAINT [PK_IMPU01] PRIMARY KEY CLUSTERED ([CVE_ESQIMPU] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de esquema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'CVE_ESQIMPU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Descripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'DESCRIPESQ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMPUESTO1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 1 aplica a {0,1} .: 0=Excento, 1 = Precio Base', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMP1APLICA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMPUESTO2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 2 aplica a {0,1,2} .: 0= Excento, 1 = Precio Base , 2 =Acumulado 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMP2APLICA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMPUESTO3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 3 aplica a {0,1,2,3} .: 0= Excento, 1 = Precio Base , 2 =Acumulado 1, 2= Acumulado 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMP3APLICA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMPUESTO4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Impuesto 4 aplica a {0,1,3,4} .: 0= Excento, 1 = Precio Base , 2 =Acumulado 1, 2= Acumulado 3, 4=Acumulado 3 ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'IMP4APLICA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Estatus [A/B] .: A=Activo, B=Baja', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'ID para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'UUID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Fecha y hora para sincronisación con SAE Movil', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'IMPU01', @level2type = N'COLUMN', @level2name = N'VERSION_SINC';

