CREATE TABLE [dbo].[FACTD01] (
    [TIP_DOC]        VARCHAR (1)   NULL,
    [CVE_DOC]        VARCHAR (20)  NOT NULL,
    [CVE_CLPV]       VARCHAR (10)  NOT NULL,
    [STATUS]         VARCHAR (1)   NOT NULL,
    [CVE_VEND]       VARCHAR (5)   NULL,
    [CVE_PEDI]       VARCHAR (20)  NULL,
    [FECHA_DOC]      DATETIME      NOT NULL,
    [FECHA_ENT]      DATETIME      NULL,
    [FECHA_VEN]      DATETIME      NULL,
    [FECHA_CANCELA]  DATETIME      NULL,
    [CAN_TOT]        FLOAT (53)    NULL,
    [IMP_TOT1]       FLOAT (53)    NULL,
    [IMP_TOT2]       FLOAT (53)    NULL,
    [IMP_TOT3]       FLOAT (53)    NULL,
    [IMP_TOT4]       FLOAT (53)    NULL,
    [DES_TOT]        FLOAT (53)    NULL,
    [DES_FIN]        FLOAT (53)    NULL,
    [COM_TOT]        FLOAT (53)    NULL,
    [CONDICION]      VARCHAR (25)  NULL,
    [CVE_OBS]        INT           NULL,
    [NUM_ALMA]       INT           NULL,
    [ACT_CXC]        VARCHAR (1)   NULL,
    [ACT_COI]        VARCHAR (1)   NULL,
    [ENLAZADO]       VARCHAR (1)   NULL,
    [TIP_DOC_E]      VARCHAR (1)   NULL,
    [NUM_MONED]      INT           NULL,
    [TIPCAMB]        FLOAT (53)    NULL,
    [NUM_PAGOS]      INT           NULL,
    [FECHAELAB]      DATETIME      NULL,
    [PRIMERPAGO]     FLOAT (53)    NULL,
    [RFC]            VARCHAR (15)  NULL,
    [CTLPOL]         INT           NULL,
    [ESCFD]          VARCHAR (1)   NULL,
    [AUTORIZA]       INT           NULL,
    [SERIE]          VARCHAR (10)  NULL,
    [FOLIO]          INT           NULL,
    [AUTOANIO]       VARCHAR (4)   NULL,
    [DAT_ENVIO]      INT           NULL,
    [CONTADO]        VARCHAR (1)   NULL,
    [DAT_MOSTR]      INT           NULL,
    [CVE_BITA]       INT           NULL,
    [BLOQ]           VARCHAR (1)   NULL,
    [FORMAENVIO]     VARCHAR (1)   NULL,
    [DES_FIN_PORC]   FLOAT (53)    NULL,
    [DES_TOT_PORC]   FLOAT (53)    NULL,
    [IMPORTE]        FLOAT (53)    NULL,
    [COM_TOT_PORC]   FLOAT (53)    NULL,
    [METODODEPAGO]   VARCHAR (255) NULL,
    [NUMCTAPAGO]     VARCHAR (255) NULL,
    [TIP_DOC_ANT]    VARCHAR (1)   NULL,
    [DOC_ANT]        VARCHAR (20)  NULL,
    [TIP_DOC_SIG]    VARCHAR (1)   NULL,
    [DOC_SIG]        VARCHAR (20)  NULL,
    [UUID]           VARCHAR (50)  NULL,
    [VERSION_SINC]   DATETIME      NULL,
    [FORMADEPAGOSAT] VARCHAR (5)   NULL,
    [USO_CFDI]       VARCHAR (5)   NULL,
    [NUM_ALM_DES]    INT           NULL,
    [TIP_TRASLADO]   VARCHAR (1)   NULL,
    CONSTRAINT [PK_FACTD01] PRIMARY KEY CLUSTERED ([CVE_DOC] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTD_CLIE01]
    ON [dbo].[FACTD01]([CVE_CLPV] ASC, [CVE_DOC] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_FACTD_FECHA01]
    ON [dbo].[FACTD01]([FECHA_DOC] ASC, [CVE_DOC] ASC);


GO
-- =============================================
-- Author:			<Author,			Diego Espinoza>
-- Create date:		<Create Date,		Septiembre 16 2020>
-- Description:		<Description,		Para remover de manera automatica de Xpress las facturas a las cuales se les aplica Nota de Crredito.>
-- Ticket:			<Ticket,			5493>
-- Solicitado Por:	<Solicitado Por,	Osman Flores>
-- =============================================
--CREATE TRIGGER [dbo].[Tri_FacturasRemoverXpressNC]
--   ON  [dbo].[FACTD01] 
--   AFTER INSERT
--AS 
--BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
--	SET NOCOUNT ON;

--    -- Insert statements for trigger here
--	DECLARE @FacturaCompleta	VARCHAR(30), 
--			@Factura			VARCHAR(30)	

--	--DEM. Obtengo la Factura a la cual se le esta Aplicando la NC. para luego buscarla en Xpress y removerla.
--	SELECT @FacturaCompleta = DOC_ANT, @Factura = RIGHT(DOC_ANT, 8)
--	FROM inserted

--	--Inserto la factura en la tabla de facturas con opcion de eliminar para Remover de Xpress de Manera automatica. 
--	INSERT INTO Next.dbo.Facturas(Factura, FacturaCompleta, Comentario, FechaIngreso, Estado)
--	VALUES        (@Factura, @FacturaCompleta, 'Remover de Xpress Automatico por NC SAE. Trigger', GETDATE(), 'Eliminar')


--END

GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [IDX_CVEPEDI_STATUS_D01]
    ON [dbo].[FACTD01]([CVE_PEDI] ASC, [STATUS] ASC);

