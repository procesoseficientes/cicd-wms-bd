CREATE TABLE [dbo].[FACTF_CLIB01] (
    [CLAVE_DOC] VARCHAR (20)  NOT NULL,
    [CAMPLIB1]  VARCHAR (25)  NULL,
    [CAMPLIB2]  VARCHAR (10)  NULL,
    [CAMPLIB3]  VARCHAR (16)  NULL,
    [CAMPLIB4]  VARCHAR (30)  NULL,
    [CAMPLIB5]  VARCHAR (30)  NULL,
    [CAMPLIB6]  VARCHAR (30)  NULL,
    [CAMPLIB7]  VARCHAR (30)  NULL,
    [CAMPLIB8]  DATETIME      NULL,
    [CAMPLIB9]  VARCHAR (20)  NULL,
    [CAMPLIB10] VARCHAR (60)  NULL,
    [CAMPLIB11] VARCHAR (20)  NULL,
    [CAMPLIB12] DATETIME      NULL,
    [CAMPLIB13] VARCHAR (30)  NULL,
    [CAMPLIB14] VARCHAR (30)  NULL,
    [CAMPLIB15] VARCHAR (30)  NULL,
    [CAMPLIB16] DATETIME      NULL,
    [CAMPLIB17] VARCHAR (20)  NULL,
    [CAMPLIB18] VARCHAR (60)  NULL,
    [CAMPLIB19] VARCHAR (20)  NULL,
    [CAMPLIB20] VARCHAR (1)   NULL,
    [CAMPLIB21] VARCHAR (100) NULL,
    [CAMPLIB22] INT           NULL,
    [CAMPLIB23] VARCHAR (40)  NULL,
    [CAMPLIB24] VARCHAR (250) NULL,
    CONSTRAINT [PK_FACTF_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC)
);


--GO
---- =============================================
---- Author:		<Author,		Diego E.>
---- Create date: <Create Date,	Agosto  19-2019>
---- Modify date: <Modify Date,	Octubre 15-2020>
---- Description:	<Description,	Para enviar el CAI automatico a SAE Facturas segun tabla de CAIs
----								Esto para modulo de Devolucion de WMS. Tambien para llevar un mejor
----								control de correlativos de facturas por temas de auditoria. Se creo Tabla de CAIs en
----								base de datos Reportes. Esto antes se manejaba solo en reporte. No hay historial de CAIs y facturas
----								en sistema>
---- Modification: <Modification,	DEM. Adaptacion de CAI de TGU y SPS. Se actualizaron en tabla segun Gabriela O., actualizados por Brayan I.
----							    Se agrego Fecha Factura se obtiene de tabla facturas. Se actualizaron registros historicos de facturas
----								para funcion de los CAI.>
---- Nota Brayan Isidro: Cuando se crea una nueva factura el triger busca el ultimo CAI en la tabla Reporte.dbo.NumeracionFacturas y lo inserta en los campos libres de Facturas y Devoluciones
---- =============================================
--CREATE TRIGGER [dbo].[Tri_CAI_Factura]
--   ON   [dbo].[FACTF_CLIB01]
--   AFTER INSERT
--AS 
--BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	-- interfering with SELECT statements.
--	SET NOCOUNT ON;

--	DECLARE	@Clave			VARCHAR(30)
--	DECLARE	@CAI			VARCHAR(50)
--	DECLARE	@FechaFactura	DATETIME

--	--Obtener el ID de la factura a Registrar.
--	SELECT @Clave = CLAVE_DOC 
--	FROM inserted

--	--Obtener Fecha Factura. DEM. Octubre 15-2020
--	SELECT @FechaFactura = FECHA_DOC FROM FACTF01
--	WHERE LTRIM(CVE_DOC) = LTRIM(@Clave)

--	--Obtener el ultimo CAI de Alza de Facturas. En la tabla hay que agregar los demas parametros de CAI como tambien 
--	--agregar Tipo de Documento. Actualmente quedara activo para Facturas para WMS.

--	IF( LEFT(@Clave, 8) = '00000101' )
--	BEGIN

-- 		SELECT @CAI = CAI FROM 
--		(
--			SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
--			WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '000-001-01-'
--			ORDER BY NumeracionId DESC

--		) AS Datos 

--		UPDATE FACTF_CLIB01
--		SET CAMPLIB18 = @CAI, 
--			CAMPLIB16 = @FechaFactura
--		WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

--	END
--	ELSE IF( LEFT(@Clave, 3) = '007' )
--	BEGIN

-- 		SELECT @CAI = CAI FROM 
--		(
--			SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
--			WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '007-001-01-'
--			ORDER BY NumeracionId DESC

--		) AS Datos 

--		UPDATE FACTF_CLIB01
--		SET CAMPLIB18 = @CAI, 
--			CAMPLIB16 = @FechaFactura
--		WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

--	END

--	ELSE IF( LEFT(@Clave, 3) = '004' )
--	BEGIN

-- 		SELECT @CAI = CAI FROM 
--		(
--			SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
--			WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '004-001-01-'
--			ORDER BY NumeracionId DESC

--		) AS Datos 

--		UPDATE FACTF_CLIB01
--		SET CAMPLIB18 = @CAI, 
--			CAMPLIB16 = @FechaFactura
--		WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

--	END

--	ELSE IF( LEFT(@Clave, 3) = '006' )
--	BEGIN

-- 		SELECT @CAI = CAI FROM 
--		(
--			SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
--			WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '006-001-01-'
--			ORDER BY NumeracionId DESC

--		) AS Datos 

--		UPDATE FACTF_CLIB01
--		SET CAMPLIB18 = @CAI, 
--			CAMPLIB16 = @FechaFactura
--		WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

--	END



	--DECLARE	@Clave			VARCHAR(30)
	--DECLARE	@CAI			VARCHAR(50)
	--DECLARE	@FechaFactura	DATETIME

	----Obtener el ID de la factura a Registrar.
	--SELECT @Clave = CLAVE_DOC 
	--FROM inserted

	----Obtener Fecha Factura. DEM. Octubre 15-2020
	--SELECT @FechaFactura = FECHA_DOC FROM FACTF01
	--WHERE LTRIM(CVE_DOC) = LTRIM(@Clave)

	----Obtener el ultimo CAI de Alza de Facturas. En la tabla hay que agregar los demas parametros de CAI como tambien 
	----agregar Tipo de Documento. Actualmente quedara activo para Facturas para WMS.

	--IF( LEFT(@Clave, 8) = '00000101' )
	--BEGIN

 --		SELECT @CAI = CAI FROM 
	--	(
	--		SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
	--		WHERE Ciudad = 'SPS'
	--		ORDER BY NumeracionId DESC

	--	) AS Datos 

	--	UPDATE FACTF_CLIB01
	--	SET CAMPLIB18 = @CAI, 
	--		CAMPLIB16 = @FechaFactura
	--	WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

	--END
	--ELSE IF( LEFT(@Clave, 3) = '004' )
	--BEGIN

 --		SELECT @CAI = CAI FROM 
	--	(
	--		SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
	--		WHERE Ciudad = 'TGU'
	--		ORDER BY NumeracionId DESC

	--	) AS Datos 

	--	UPDATE FACTF_CLIB01
	--	SET CAMPLIB18 = @CAI, 
	--		CAMPLIB16 = @FechaFactura
	--	WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)

	--END

--END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Clave de facturas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FACTF_CLIB01', @level2type = N'COLUMN', @level2name = N'CLAVE_DOC';

