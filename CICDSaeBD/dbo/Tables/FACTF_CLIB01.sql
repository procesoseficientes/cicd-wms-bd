CREATE TABLE [dbo].[FACTF_CLIB01] (
    [CLAVE_DOC] VARCHAR (20)  NOT NULL,
    [CAMPLIB1]  VARCHAR (25)  NULL,
    [CAMPLIB2]  VARCHAR (10)  NULL,
    [CAMPLIB3]  FLOAT (53)    NULL,
    [CAMPLIB4]  VARCHAR (30)  NULL,
    [CAMPLIB5]  VARCHAR (30)  NULL,
    [CAMPLIB6]  VARCHAR (30)  NULL,
    [CAMPLIB7]  VARCHAR (30)  NULL,
    [CAMPLIB8]  DATETIME      NULL,
    [CAMPLIB9]  VARCHAR (20)  NULL,
    [CAMPLIB10] VARCHAR (20)  NULL,
    [CAMPLIB11] DATETIME      NULL,
    [CAMPLIB12] VARCHAR (30)  NULL,
    [CAMPLIB13] VARCHAR (30)  NULL,
    [CAMPLIB14] VARCHAR (30)  NULL,
    [CAMPLIB15] VARCHAR (50)  NULL,
    [CAMPLIB16] VARCHAR (20)  NULL,
    [CAMPLIB17] VARCHAR (60)  NULL,
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
-- =============================================
-- Author:		<Author, Brayan Isidro>
-- Create date: <Create Date, 2023-04-18>
-- Description:	<Description, >
-- =============================================
CREATE TRIGGER [dbo].[Tri_Facturas_Manifiestos]
   ON  [dbo].[FACTF_CLIB01]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 DECLARE @Clave VARCHAR(20)
    -- Insert statements for trigger here
	SELECT @Clave = CLAVE_DOC 
	FROM inserted

		UPDATE       Next.dbo.Facturas_Disponible_Manifiestos
		SET   Linea = IIF(LIN_PROD IN ('CONG','PAPA','24C&E'),'Frio','Seco')             
		FROM            Next.dbo.Facturas_Disponible_Manifiestos M INNER JOIN
								 PAR_FACTF01 AS F ON M.Factura COLLATE Latin1_General_BIN = F.CVE_DOC INNER JOIN
								 INVE01 AS I ON F.CVE_ART = I.CVE_ART
		WHERE        (M.Linea IS NULL)


		UPDATE Next.dbo.Facturas_Disponible_Manifiestos
		SET Peso = agg.Peso
		FROM Next.dbo.Facturas_Disponible_Manifiestos M 
		INNER JOIN
		(SELECT CVE_DOC, Peso = SUM(CANT * PESO)
		 FROM SAE70EMPRESA01.dbo.PAR_FACTF01 DetalleFactura WITH (NOLOCK)
		 LEFT JOIN SAE70EMPRESA01.dbo.INVE01 Inventario  WITH (NOLOCK)
		 ON DetalleFactura.CVE_ART = Inventario.CVE_ART
		-- WHERE YEAR(DetalleFactura.VERSION_SINC) = YEAR(GETDATE())
		GROUP BY CVE_DOC) agg 
		ON M.Factura COLLATE Latin1_General_BIN = agg.CVE_DOC
		WHERE M.Peso IS NULL


	INSERT INTO Next.dbo.Facturas_Disponible_Manifiestos
			(Factura, Remision, CodigoCliente, Cliente, FechaFactura, FechaEntrega, Peso, Departamento, Municipio, Vendedor, Zona, Pedido, Linea, Estado, Bodega)

	SELECT Factura, Remision, CodigoCliente, Cliente, FechaFactura, FechaEntrega, Peso, Departamento, Municipio, Vendedor, Zona, Pedido, Linea, 1,Bodega FROM

	(

	SELECT Factura, Remision, CodigoCliente, Cliente, FechaFactura = FechaFactura, FechaEntrega = FechaEntrega, Peso,  Departamento, Municipio, Vendedor, Zona, Pedido , Linea,Bodega
	FROM 
	( SELECT DISTINCT Factura, Remision, CodigoCliente, Cliente, FechaFactura, FechaEntrega = FechaEntrega, Peso, Departamento, Municipio, Vendedor, Zona, Pedido,Linea, Bodega	   
	  FROM 
	
	( SELECT Factura = Facturas.CVE_DOC, Remision = LTRIM(Facturas.DOC_ANT), CodigoCliente = LTRIM(Facturas.CVE_CLPV), Cliente = REPLACE(REPLACE(REPLACE(Clientes.NOMBRE, '''', ''), '\',''), '/',''),  
		   FechaFactura = CONVERT(DATE,Facturas.FECHA_DOC), FechaEntrega = CONVERT(DATE,Facturas.FECHA_ENT), Departamento = Zonas2.TEXTO, Municipio = Zonas.TEXTO, Vendedor = Vendedores.NOMBRE, Peso, 
		   Zona = CASE WHEN Clientes.CLASIFIC LIKE '%DT%' THEN 'Detalle'
					   WHEN  Zonas.TEXTO IN ('SAN PEDRO SULA', 'LA LIMA', 'CHOLOMA', 'VILLANUEVA') THEN 'Local'
					   WHEN  Zonas.TEXTO IN ('PUERTO CORTES', 'PROGRESO', 'EL PROGRESO', 'COFRADIA') THEN 'Region' ELSE 'Foraneo' END,
		   Pedido = LTRIM(Pedidos.CVE_DOC), Facturas.FECHAELAB,Linea, Bodega = Facturas.NUM_ALMA
	FROM SAE70EMPRESA01.dbo.FACTF01 Facturas  WITH (NOLOCK)
		LEFT JOIN SAE70EMPRESA01.dbo.CLIE01 Clientes  WITH (NOLOCK)
			ON Facturas.CVE_CLPV = Clientes.CLAVE AND DATEDIFF(DAY,Facturas.FECHA_DOC,GETDATE()) <= 20
		LEFT JOIN SAE70EMPRESA01.dbo.ZONA01 Zonas  WITH (NOLOCK)
			ON Clientes.CVE_ZONA = Zonas.CVE_ZONA
		LEFT JOIN SAE70EMPRESA01.dbo.ZONA01 Zonas2  WITH (NOLOCK)
			ON Zonas.CVE_PADRE = Zonas2.CVE_ZONA
		LEFT JOIN SAE70EMPRESA01.dbo.CLIE_CLIB01 Extras  WITH (NOLOCK)
			ON Clientes.CLAVE = Extras.CVE_CLIE
		LEFT JOIN SAE70EMPRESA01.dbo.VEND01 Vendedores  WITH (NOLOCK)
			ON Facturas.CVE_VEND = Vendedores.CVE_VEND
		LEFT JOIN 
			(
				SELECT CVE_DOC, Peso = SUM(CANT * PESO)
				FROM SAE70EMPRESA01.dbo.PAR_FACTF01 DetalleFactura WITH (NOLOCK)
					LEFT JOIN SAE70EMPRESA01.dbo.INVE01 Inventario  WITH (NOLOCK)
					ON DetalleFactura.CVE_ART = Inventario.CVE_ART
				WHERE YEAR(DetalleFactura.VERSION_SINC) = YEAR(GETDATE())
				GROUP BY CVE_DOC
			) Pesos 
			ON Facturas.CVE_DOC = Pesos.CVE_DOC
		LEFT JOIN 
			(
				SELECT F.CVE_DOC,Linea = IIF(LIN_PROD IN ('CONG','PAPA','24C&E'),'Frio','Seco') 
				FROM SAE70EMPRESA01.dbo.PAR_FACTF01 F
					 INNER JOIN SAE70EMPRESA01.dbo.INVE01 I
					 ON F.CVE_ART = I.CVE_ART
				WHERE YEAR(F.VERSION_SINC) = YEAR(GETDATE()) 
				GROUP BY CVE_DOC,LIN_PROD

			) Linea
			ON Facturas.CVE_DOC = Linea.CVE_DOC
		LEFT JOIN SAE70EMPRESA01.dbo.FACTP01 Pedidos  WITH (NOLOCK)
			ON Facturas.DOC_ANT = Pedidos.DOC_SIG
	  WHERE Facturas.CVE_DOC = @Clave

	) AS Resumen 	
	) AS Resumen

)  AS Data



 
		




END
GO
-- =============================================
-- Author:		<Author,		Diego E.>
-- Create date: <Create Date,	Agosto  19-2019>
-- Modify date: <Modify Date,	Octubre 15-2020>
-- Description:	<Description,	Para enviar el CAI automatico a SAE Facturas segun tabla de CAIs
--								Esto para modulo de Devolucion de WMS. Tambien para llevar un mejor
--								control de correlativos de facturas por temas de auditoria. Se creo Tabla de CAIs en
--								base de datos Reportes. Esto antes se manejaba solo en reporte. No hay historial de CAIs y facturas
--								en sistema>
-- Modification: <Modification,	 Se actualizo  para que se contemplen las fechas limite de emision y los rangos de las facturas y enviar alerta via correo en caso de que
-- Author:Brayan Isidro:2022-11-17	 Los Mismos ya esten vencidos, se adicionaron los canales de Mayoreo y Detalle para SPS y TGU
-- =============================================
CREATE TRIGGER [dbo].[Tri_CAI_Factura]
   ON   [dbo].[FACTF_CLIB01]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@Clave			VARCHAR(30)
	DECLARE	@CAI			VARCHAR(50)
	DECLARE	@FechaFactura	DATETIME
	DECLARE @Vencimiento    DATE
	DECLARE @Rango			INT
	DECLARE @Cuerpo		  VARCHAR(2000)

	--Obtener el ID de la factura a Registrar.
	SELECT @Clave = CLAVE_DOC 
	FROM inserted

	--Obtener Fecha Factura. DEM. Octubre 15-2020
	SELECT @FechaFactura = FECHA_DOC FROM FACTF01
	WHERE LTRIM(CVE_DOC) = LTRIM(@Clave)

	--Obtener el ultimo CAI de Alza de Facturas. En la tabla hay que agregar los demas parametros de CAI como tambien 
	--agregar Tipo de Documento. Actualmente quedara activo para Facturas para WMS.

	IF( LEFT(@Clave, 8) = '00000101' ) -- Rangos de Mayoreo
	BEGIN

		SELECT @Vencimiento = MAX(FechaLimiteEmision), @Rango = MAX(UltimoDocumento) FROM Reportes.dbo.NumeracionFacturas
		WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '000-001-01-' AND TipoCanal = 'Mayoreo' AND TipoDocumento = 'Facturas'

         IF(CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) <= @Rango)
         BEGIN
		
			SELECT @CAI = CAI FROM 
				(
					SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
					WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '000-001-01-' AND TipoCanal = 'Mayoreo'
					ORDER BY NumeracionId DESC

				) AS Datos 

				UPDATE FACTF_CLIB01
				SET CAMPLIB18 = @CAI, 
					CAMPLIB16 = @FechaFactura
				WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)
				PRINT('AMBAS VARIABLES CUMPLEN LA CONDICION')

          END
		  ELSE IF(CONVERT(DATE,@FechaFactura) > @Vencimiento AND RIGHT(@Clave,8) <= @Rango)
 			BEGIN 
			
			SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
			EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
									 @recipients		= 'brayan.isidro@grupoalza.com', 
									 @copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
									 @subject			= 'Revision de CAI Facturas SPS Canal de Mayoreo', 
									 @body				=  @Cuerpo, 
									 @body_format		= 'text'
				PRINT 'FECHA DE CAI VENCIDA'

			END
		ELSE IF(CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) > @Rango)
 		BEGIN 
				 
				 SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
			     EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
											 @recipients		= 'brayan.isidro@grupoalza.com', 
											 @copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
											 @subject			= 'Revision de CAI Facturas SPS Canal de Mayoreo', 
											 @body				=  @Cuerpo, 
											 @body_format		= 'text'
						PRINT ('RANGO DE CAI VENCIDO')
		END
		END
		ELSE IF( LEFT(@Clave, 3) = '007' )--Rangos de Detalle
		BEGIN

 			SELECT @Vencimiento = MAX(FechaLimiteEmision), @Rango = MAX(UltimoDocumento) FROM Reportes.dbo.NumeracionFacturas
			WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '007-001-01-' AND TipoCanal = 'Detalle' AND TipoDocumento = 'Facturas'

	
			 IF( CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) <= @Rango )
			 BEGIN
		
				SELECT @CAI = CAI FROM 
					(
						SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
						WHERE Ciudad = 'SPS' AND LEFT(RangoInicial,11) = '007-001-01-' AND TipoCanal = 'Detalle'
						ORDER BY NumeracionId DESC

					) AS Datos 

					UPDATE FACTF_CLIB01
					SET CAMPLIB18 = @CAI, 
						CAMPLIB16 = @FechaFactura
					WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)
					PRINT('AMBAS VARIABLES CUMPLEN LA CONDICION')

			  END
			  ELSE IF(CONVERT(DATE,@FechaFactura) > @Vencimiento AND RIGHT(@Clave,8) <= @Rango)
 				BEGIN 

		  
			    SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
				EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
										 @recipients		= 'brayan.isidro@grupoalza.com', 
										 @copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
										 @subject			= 'Revision de CAI Facturas SPS Canal de Detalle', 
										 @body				=  @Cuerpo, 
										 @body_format		= 'text'

			END
			ELSE IF(CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) > @Rango)
 			BEGIN 
 
			 SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
		   	 EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
										 @recipients		= 'brayan.isidro@grupoalza.com', 
										 @copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
										 @subject			= 'Revision de CAI Facturas SPS Canal de Detalle', 
										 @body				=  @Cuerpo, 
										 @body_format		= 'text'

				PRINT ('RANGO DE CAI VENCIDO')
			END

	END
	ELSE IF( LEFT(@Clave, 3) = '004' ) -- Rangos de Mayoreo
	BEGIN

 		SELECT @Vencimiento = MAX(FechaLimiteEmision), @Rango = MAX(UltimoDocumento) FROM Reportes.dbo.NumeracionFacturas
		WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '004-001-01-' AND TipoCanal = 'Mayoreo' AND TipoDocumento = 'Facturas'

			IF( CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) <= @Rango )
			BEGIN
		
			SELECT @CAI = CAI FROM 
				(
					SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
					WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '004-001-01-' AND TipoCanal = 'Mayoreo' 
					ORDER BY NumeracionId DESC

				) AS Datos 

				UPDATE FACTF_CLIB01
				SET CAMPLIB18 = @CAI, 
					CAMPLIB16 = @FechaFactura
				WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)
					PRINT @Clave
				PRINT('AMBAS VARIABLES CUMPLEN LA CONDICION')

			END
			ELSE IF(CONVERT(DATE,@FechaFactura) > @Vencimiento AND RIGHT(@Clave,8) <= @Rango)
 			BEGIN 
		  
			SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
			EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
										@recipients		= 'brayan.isidro@grupoalza.com', 
										@copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
										@subject			= 'Revision de CAI Facturas TGU Canal de Mayoreo', 
										@body				=  @Cuerpo, 
										@body_format		= 'text'

			END
			END
			ELSE IF(CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) > @Rango)
 			BEGIN 
		 
		    SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
			EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
												@recipients		= 'brayan.isidro@grupoalza.com', 
												@copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
												@subject			= 'Revision de CAI Facturas TGU Canal de Mayoreo', 
												@body				=  @Cuerpo, 
												@body_format		= 'text'

					PRINT ('RANGO DE CAI VENCIDO')
	END
	ELSE IF( LEFT(@Clave, 3) = '006' )--Rangos de Detalle
	BEGIN

		SELECT @Vencimiento = MAX(FechaLimiteEmision), @Rango = MAX(UltimoDocumento) FROM Reportes.dbo.NumeracionFacturas
		WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '006-001-01-' AND TipoCanal = 'Detalle' AND TipoDocumento = 'Facturas'

			IF( CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) <= @Rango )
			BEGIN
		
			SELECT @CAI = CAI FROM 
				(
					SELECT TOP 1 CAI FROM Reportes.dbo.NumeracionFacturas
					WHERE Ciudad = 'TGU' AND LEFT(RangoInicial,11) = '006-001-01-' AND TipoCanal = 'Detalle'
					ORDER BY NumeracionId DESC

				) AS Datos 

				UPDATE FACTF_CLIB01
				SET CAMPLIB18 = @CAI, 
					CAMPLIB16 = @FechaFactura
				WHERE LTRIM(CLAVE_DOC) = LTRIM(@Clave)
					PRINT @Clave
				PRINT('AMBAS VARIABLES CUMPLEN LA CONDICION')

			END
			ELSE IF(CONVERT(DATE,@FechaFactura) > @Vencimiento AND RIGHT(@Clave,8) <= @Rango)
 			BEGIN 
 
			SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
			EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
										@recipients		= 'brayan.isidro@grupoalza.com', 
										@copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
										@subject			= 'Revision de CAI Facturas TGU Canal de Detalle', 
										@body				=  @Cuerpo, 
										@body_format		= 'text'

			END
			ELSE IF(CONVERT(DATE,@FechaFactura) <= @Vencimiento AND RIGHT(@Clave,8) > @Rango)
 					BEGIN 
		  
					SET @Cuerpo = 'Se Identificado un CAI Vencido en la factura  ' + @Clave + '. Por favor ingresar al modulo control de CAI '
					EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
												@recipients		= 'brayan.isidro@grupoalza.com', 
												@copy_recipients	= 'gabriela.oviedo@grupoalza.com;alex.gonzalez@grupoalza.com;jose.ortega@grupoalza.com', 
												@subject			= 'Revision de CAI Facturas TGU Canal de Detalle', 
												@body				=  @Cuerpo, 
												@body_format		= 'text'

					PRINT ('RANGO DE CAI VENCIDO')
			END
			END

END