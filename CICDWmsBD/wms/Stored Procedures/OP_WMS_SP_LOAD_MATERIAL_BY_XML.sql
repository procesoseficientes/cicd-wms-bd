-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-Jul-17 @ Nexus Sprint AgeOfEmpires
-- Description:			SP que carga materiales, ubicaciones de los materiales y los componesntes de los master pack 

-- Modificacion 10/3/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega columna USA_LINEA_PICKING

-- Modificacion 29-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se agrega creación de propiedades por material

-- Modificacion 1-Jun-18 Sprint Dinosaurio
					-- marvin.garcia
					-- se agrega manejo de peatania UnidadDeMedida (empaques)

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180816 GForce@Humano 
-- Description:			    se agregan columnas HANDLE_CORRELATIVE_SERIALS Y PREFIX_CORRELATIVE_SERIALS

-- Autor:				henry.rodriguez
-- Fecha de creacion:	26-Jun-2019 G-Force@Cancun-Swift3pl
-- Descripcion:			Se agrego campos LEAD_TIME, SUPPLIER, NAME_SUPPLIER

-- Autor:				kevin.guerra
-- Fecha de creacion:	24-03-2020 G-Force@B
-- Descripcion:			Se agrega el campo MATERIAL_SUB_CLASS

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_LOAD_MATERIAL_BY_XML]
					@MATERIALS = N'<?xml version="1.0"?>
<Data>
  <Material>
    <CantidadMaxPorBin>1</CantidadMaxPorBin>
    <Clase>S</Clase>
    <Cliente>wms</Cliente>
    <Codigo>p1</Codigo>
    <CodigoBarras>wms/p1</CodigoBarras>
    <CodigoBarrasAlterno>wms/p1</CodigoBarrasAlterno>
    <Descripcion>p1</Descripcion>
    <DescripcionCorta>p1</DescripcionCorta>
    <EsCarro>NO</EsCarro>
    <ManejaExplosionEnRecepcion>NO</ManejaExplosionEnRecepcion>
    <ManejaLote>SI</ManejaLote>
    <ManejaMasterPack>NO</ManejaMasterPack>
    <ManejaSerie>NO</ManejaSerie>
    <UnidadPeso>LIBRA</UnidadPeso>
    <Alto>1</Alto>
    <Ancho>2</Ancho>
    <FactorVolumen>3</FactorVolumen>
    <Largo>4</Largo>
    <Peso>5</Peso>
  </Material>
  <Material>
    <CantidadMaxPorBin>1</CantidadMaxPorBin>
    <Clase>B</Clase>
    <Cliente>wms</Cliente>
    <Codigo>p2</Codigo>
    <CodigoBarras>wms/p2</CodigoBarras>
    <CodigoBarrasAlterno>wms/p2</CodigoBarrasAlterno>
    <Descripcion>p2</Descripcion>
    <DescripcionCorta>p2</DescripcionCorta>
    <EsCarro>NO</EsCarro>
    <ManejaExplosionEnRecepcion>NO</ManejaExplosionEnRecepcion>
    <ManejaLote>NO</ManejaLote>
    <ManejaMasterPack>SI</ManejaMasterPack>
    <ManejaSerie>NO</ManejaSerie>
    <UnidadPeso>KG</UnidadPeso>
    <Alto>5</Alto>
    <Ancho>4</Ancho>
    <FactorVolumen>3</FactorVolumen>
    <Largo>2</Largo>
    <Peso>1</Peso>
  </Material>
  <Material>
	<CantidadMaxPorBin></CantidadMaxPorBin> />
    <Clase>M</Clase>
    <Cliente>wms</Cliente>
    <Codigo>p3</Codigo>
    <CodigoBarras>wms/p3</CodigoBarras>
    <CodigoBarrasAlterno>wms/p3</CodigoBarrasAlterno>
    <Descripcion>p3</Descripcion>
    <DescripcionCorta>p3</DescripcionCorta>
    <EsCarro>NO</EsCarro>
    <ManejaExplosionEnRecepcion>NO</ManejaExplosionEnRecepcion>
    <ManejaLote>NO</ManejaLote>
    <ManejaMasterPack>NO</ManejaMasterPack>
    <ManejaSerie>SI</ManejaSerie>
    <UnidadPeso>ONZ</UnidadPeso>
    <Alto>3</Alto>
    <Ancho>3</Ancho>
    <FactorVolumen>3</FactorVolumen>
    <Largo>3</Largo>
    <Peso>3</Peso>
  </Material>
  <Material>
	  <CantidadMaxPorBin></CantidadMaxPorBin> />
    <Clase>P</Clase>
    <Cliente>wms</Cliente>
    <Codigo>p4</Codigo>
    <CodigoBarras>wms/p4</CodigoBarras>
    <CodigoBarrasAlterno>wms/p4</CodigoBarrasAlterno>
    <Descripcion>p4</Descripcion>
    <DescripcionCorta>p4</DescripcionCorta>
    <EsCarro>NO</EsCarro>
    <ManejaExplosionEnRecepcion>NO</ManejaExplosionEnRecepcion>
    <ManejaLote>NO</ManejaLote>
    <ManejaMasterPack>NO</ManejaMasterPack>
    <ManejaSerie>NO</ManejaSerie>
    <UnidadPeso>KG</UnidadPeso>
    <Alto>0</Alto>
    <Ancho>0</Ancho>
    <FactorVolumen>4</FactorVolumen>
    <Largo>0</Largo>
    <Peso>4</Peso>
  </Material>
  <Material>
	  <CantidadMaxPorBin></CantidadMaxPorBin> />
    <Clase />
    <Cliente>wms</Cliente>
    <Codigo>p5</Codigo>
    <CodigoBarras>wms/p5</CodigoBarras>
    <CodigoBarrasAlterno>wms/p5</CodigoBarrasAlterno>
    <Descripcion>p5</Descripcion>
    <DescripcionCorta>p5</DescripcionCorta>
    <EsCarro>NO</EsCarro>
    <ManejaExplosionEnRecepcion>SI</ManejaExplosionEnRecepcion>
    <ManejaLote>NO</ManejaLote>
    <ManejaMasterPack>SI</ManejaMasterPack>
    <ManejaSerie>NO</ManejaSerie>
    <UnidadPeso>GR</UnidadPeso>
    <Alto>0</Alto>
    <Ancho>0</Ancho>
    <FactorVolumen>0</FactorVolumen>
    <Largo>0</Largo>
    <Peso>0</Peso>
  </Material>
</Data>'
					,@LOCATIONS = N'<?xml version="1.0"?>
<Data>
  <Ubicacion>
	<Cliente>wms</Cliente>
    <CodigoDeMaterial>p1</CodigoDeMaterial>
    <Ubicacion>B01-P02-F01-NU</Ubicacion>
    <CantidadMinima>1</CantidadMinima>
    <CantidadMaxima>1</CantidadMaxima>
  </Ubicacion>
  <Ubicacion>
	<Cliente>wms</Cliente>
    <CodigoDeMaterial>p2</CodigoDeMaterial>
    <Ubicacion>B01-P04-F01-NU</Ubicacion>
    <CantidadMinima>2</CantidadMinima>
    <CantidadMaxima>5</CantidadMaxima>
  </Ubicacion>
  <Ubicacion>
	<Cliente>wms</Cliente>
    <CodigoDeMaterial>p3</CodigoDeMaterial>
    <Ubicacion>B01-R01-C01-NC</Ubicacion>
    <CantidadMinima>3</CantidadMinima>
    <CantidadMaxima>2</CantidadMaxima>
  </Ubicacion>
  <Ubicacion>
	<Cliente>wms</Cliente>
    <CodigoDeMaterial>p4</CodigoDeMaterial>
    <Ubicacion>B01-R01-C02-NB</Ubicacion>
    <CantidadMinima>4</CantidadMinima>
    <CantidadMaxima>5</CantidadMaxima>
  </Ubicacion>
  <Ubicacion>
	<Cliente>wms</Cliente>
    <CodigoDeMaterial>p5</CodigoDeMaterial>
    <Ubicacion>B01-P01-F01-NU</Ubicacion>
    <CantidadMinima>5</CantidadMinima>
    <CantidadMaxima>5</CantidadMaxima>
  </Ubicacion>
</Data>'
					,@MASTER_PACKS = N'<?xml version="1.0"?>
<Data>
  <MasterPack>
    <Cliente>wms</Cliente>
	<CodigoMasterPack>p2</CodigoMasterPack>
    <CodigoComponente>p1</CodigoComponente>
    <Cantidad>1</Cantidad>
  </MasterPack>
  <MasterPack>
    <Cliente>wms</Cliente>
	<CodigoMasterPack>p2</CodigoMasterPack>
    <CodigoComponente>p3</CodigoComponente>
    <Cantidad>3</Cantidad>
  </MasterPack>
  <MasterPack>
    <Cliente>wms</Cliente>
	<CodigoMasterPack>p3</CodigoMasterPack>
    <CodigoComponente>p1</CodigoComponente>
    <Cantidad>5</Cantidad>
  </MasterPack>
  <MasterPack>
    <Cliente>wms</Cliente>
	<CodigoMasterPack>p3</CodigoMasterPack>
    <CodigoComponente>p5</CodigoComponente>
    <Cantidad>1</Cantidad>
  </MasterPack>
  <MasterPack>
    <Cliente>wms</Cliente>
	<CodigoMasterPack>mp3</CodigoMasterPack>
    <CodigoComponente>c5</CodigoComponente>
    <Cantidad>7</Cantidad>
  </MasterPack>
</Data>'
					,@LOGIN = 'ACAMACHO'
				-- 
				SELECT * FROM 
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_LOAD_MATERIAL_BY_XML] (
		@MATERIALS XML = NULL
		,@LOCATIONS XML = NULL
		,@UNIT_MEASURE_BY_MATERIAL_XML XML = NULL
		,@MASTER_PACKS XML = NULL
		,@PROPERTIES XML = NULL
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MATERIAL TABLE (
			[LINE_NUM] INT NOT NULL
							IDENTITY(1, 1)
			,[CLIENT_OWNER] [VARCHAR](25) NOT NULL
			,[MATERIAL_ID] [VARCHAR](50) NOT NULL
			,[BARCODE_ID] [VARCHAR](25) NOT NULL
			,[ALTERNATE_BARCODE] [VARCHAR](25) NULL
			,[MATERIAL_NAME] [VARCHAR](200) NOT NULL
			,[SHORT_NAME] [VARCHAR](200) NOT NULL
			,[VOLUME_FACTOR] [DECIMAL](18, 4) NULL
			,[MATERIAL_CLASS] [VARCHAR](25) NULL
			,[MATERIAL_SUB_CLASS] [VARCHAR](25) NULL
			,[HIGH] [NUMERIC](18, 3) NULL
			,[LENGTH] [NUMERIC](18, 3) NULL
			,[WIDTH] [NUMERIC](18, 3) NULL
			,[MAX_X_BIN] [NUMERIC](18, 0) NULL
			,[WEIGTH] [DECIMAL](18, 6) NULL
			,[LAST_UPDATED] [DATETIME] NULL
			,[LAST_UPDATED_BY] [VARCHAR](25) NULL
			,[IS_CAR] [NUMERIC](18, 0) NULL
			,[BATCH_REQUESTED] [NUMERIC](18, 0) NULL
			,[SERIAL_NUMBER_REQUESTS] [NUMERIC](18, 0) NULL
			,[IS_MASTER_PACK] [INT] NOT NULL
			,[WEIGHT_MEASUREMENT] [VARCHAR](50)
			,[EXPLODE_IN_RECEPTION] [INT] NOT NULL
			,[USE_PICKING_LINE] [INT] NOT NULL
			,[HANDLE_CORRELATIVE_SERIALS] [INT] NOT NULL
			,[PREFIX_CORRELATIVE_SERIALS] VARCHAR(20)
			,[LEAD_TIME] INT
			,[SUPPLIER] [VARCHAR](64)
			,[NAME_SUPPLIER] VARCHAR(250)
		);
	--
	DECLARE	@LOCATION TABLE (
			[LINE_NUM] INT NOT NULL
							IDENTITY(1, 1)
			,[CLIENT_CODE] [VARCHAR](25) NOT NULL
			,[MATERIAL_ID] [VARCHAR](25) NOT NULL
			,[LOCATION_SPOT] [VARCHAR](25) NOT NULL
			,[LAST_UPDATED] [DATETIME] NULL
			,[LAST_UPDATED_BY] [VARCHAR](25) NULL
			,[MAX_QUANTITY] [NUMERIC](18, 0) NULL
			,[MIN_QUANTITY] [NUMERIC](18, 0) NULL
		);
	--
	DECLARE	@UNIT_MEASURE_BY_MATERIAL TABLE (
			[LINE_NUM] INT NOT NULL
							IDENTITY(1, 1)
			,[CLIENT_ID] [VARCHAR](25)
				COLLATE SQL_Latin1_General_CP1_CI_AS
				NOT NULL
			,[MATERIAL_ID] [VARCHAR](50)
				COLLATE SQL_Latin1_General_CP1_CI_AS
				NOT NULL
			,[MEASUREMENT_UNIT] [VARCHAR](50)
				COLLATE SQL_Latin1_General_CP1_CI_AS
				NOT NULL
			,[QTY] [INT] NOT NULL
			,[BARCODE] [VARCHAR](100)
				COLLATE SQL_Latin1_General_CP1_CI_AS
				NOT NULL
			,[ALTERNATIVE_BARCODE] [VARCHAR](100)
				COLLATE SQL_Latin1_General_CP1_CI_AS
				NOT NULL
			,PRIMARY KEY
				([CLIENT_ID], [MATERIAL_ID], [MEASUREMENT_UNIT])
		);
	--
	DECLARE	@MASTER_PACK TABLE (
			[LINE_NUM] INT NOT NULL
							IDENTITY(1, 1)
			,[CLIENT_CODE] [VARCHAR](25) NOT NULL
			,[MASTER_PACK_CODE] [VARCHAR](50) NOT NULL
			,[COMPONENT_MATERIAL] [VARCHAR](50) NOT NULL
			,[QTY] [DECIMAL](18, 4) NOT NULL
		);
	--
	DECLARE	@MATERIAL_PROPERTY_BY_WAREHOUSE TABLE (
			[LINE_NUM] INT NOT NULL
							IDENTITY(1, 1)
			,[MATERIAL_PROPERTY_ID] [INT] NOT NULL
			,[WAREHOUSE_ID] [VARCHAR](25) NOT NULL
			,[MATERIAL_ID] [VARCHAR](50) NOT NULL
			,[VALUE] [VARCHAR](250) NOT NULL
			,[LOGIN] VARCHAR(50) NOT NULL
			,PRIMARY KEY
				([MATERIAL_PROPERTY_ID], [MATERIAL_ID], [WAREHOUSE_ID])
		);
	--
	DECLARE	@ERROR TABLE (
			[ORDER] INT NOT NULL
			,[PART] VARCHAR(50)
			,[LINE_NUM] INT
			,[MESSAGE] VARCHAR(1000)
		);
	--
	DECLARE
		@HAS_ERROR INT = 0
		,@MATERIAL_SECCTION VARCHAR(50) = 'Materiales'
		,@LOCATION_SECCTION VARCHAR(50) = 'Ubicacion'
		,@UNIT_MEASURE_BY_MATERIAL_SECTION VARCHAR(50) = 'Unidades_de_medida'
		,@MASTER_PACK_SECCTION VARCHAR(50) = 'MasterPack'
		,@MATERIAL_PROPERTIES_SECCTION VARCHAR(50) = 'PropiedadesPorBodega'
		,@MATERIAL_ORDER INT = 1
		,@LOCATION_ORDER INT = 2
		,@UNIT_MEASURE_BY_MATERIAL_ORDER INT = 3
		,@MASTER_PACK_ORDER INT = 4
		,@MATERIAL_PROPERTIES_ORDER INT = 5;
	--
	BEGIN TRAN;
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Carga de materiales
		-- ------------------------------------------------------------------------------------
		IF @MATERIALS IS NOT NULL
		BEGIN
			BEGIN TRY
				PRINT '--> Carga de materiales';
				--
				select @MATERIAL_SECCTION = 'Carga de materiales'
				INSERT	INTO @MATERIAL
						(
							[CLIENT_OWNER]
							,[MATERIAL_ID]
							,[BARCODE_ID]
							,[ALTERNATE_BARCODE]
							,[MATERIAL_NAME]
							,[SHORT_NAME]
							,[VOLUME_FACTOR]
							,[MATERIAL_CLASS]
							,[MATERIAL_SUB_CLASS]
							,[HIGH]
							,[LENGTH]
							,[WIDTH]
							,[MAX_X_BIN]
							,[WEIGTH]
							,[LAST_UPDATED]
							,[LAST_UPDATED_BY]
							,[IS_CAR]
							,[BATCH_REQUESTED]
							,[SERIAL_NUMBER_REQUESTS]
							,[IS_MASTER_PACK]
							,[WEIGHT_MEASUREMENT]
							,[EXPLODE_IN_RECEPTION]
							,[USE_PICKING_LINE]
							,[HANDLE_CORRELATIVE_SERIALS]
							,[PREFIX_CORRELATIVE_SERIALS]
							,[LEAD_TIME]
							,[SUPPLIER]
							,[NAME_SUPPLIER]
						)
				SELECT
					[x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
					,([x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
						+ '/' + [x].[Rec].[query]('./Codigo').[value]('.',
											'varchar(50)'))
					,[x].[Rec].[query]('./CodigoBarras').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./CodigoBarrasAlterno').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./Descripcion').[value]('.',
											'varchar(200)')
					,[x].[Rec].[query]('./DescripcionCorta').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./FactorVolumen').[value]('.',
											'decimal(18,4)')
					,[x].[Rec].[query]('./Clase').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./SubClase').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./Alto').[value]('.',
											'numeric(18,3)')
					,[x].[Rec].[query]('./Largo').[value]('.',
											'numeric(18,3)')
					,[x].[Rec].[query]('./Ancho').[value]('.',
											'numeric(18,3)')
					,CASE	WHEN [x].[Rec].[query]('./CantidadMaxPorBin').[value]('.',
											'varchar(25)') = 'null'
							THEN NULL
							WHEN [x].[Rec].[query]('./CantidadMaxPorBin').[value]('.',
											'varchar(25)') = ''
							THEN NULL
							ELSE [x].[Rec].[query]('./CantidadMaxPorBin').[value]('.',
											'numeric(18,0)')
						END
					,[x].[Rec].[query]('./Peso').[value]('.',
											'numeric(18,6)')
					,GETDATE()
					,@LOGIN
					,CASE [x].[Rec].[query]('./EsCarro').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,CASE [x].[Rec].[query]('./ManejaLote').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,CASE [x].[Rec].[query]('./ManejaSerie').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,CASE [x].[Rec].[query]('./ManejaMasterPack').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,[x].[Rec].[query]('./UnidadPeso').[value]('.',
											'varchar(50)')
					,CASE [x].[Rec].[query]('./ManejaExplosionEnRecepcion').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,CASE [x].[Rec].[query]('./UsaLineaDePicking').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,CASE [x].[Rec].[query]('./ManejaSerieCorrelativa').[value]('.',
											'varchar(10)')
						WHEN 'SI' THEN '1'
						ELSE '0'
						END
					,[x].[Rec].[query]('./PrefijoSerieCorrelativa').[value]('.',
											'varchar(20)')
					,[x].[Rec].[query]('./TiempoEsperaEnDias').[value]('.',
											'INTEGER')
					,[x].[Rec].[query]('./Proveedor').[value]('.',
											'VARCHAR(64)')
					,[x].[Rec].[query]('./NombreProveedor').[value]('.',
											'VARCHAR(250)')
				FROM
					@MATERIALS.[nodes]('/Data/Material') AS [x] ([Rec]);

				-- ------------------------------------------------------------------------------------
				-- Se validan los clientes
				-- ------------------------------------------------------------------------------------
				select @MATERIAL_SECCTION = 'validan clientes'
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'No existe el cliente '
					+ [M].[CLIENT_OWNER]
				FROM
					@MATERIAL [M]
				LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON ([M].[CLIENT_OWNER] = [C].[CLIENT_CODE])
				WHERE
					[C].[CLIENT_NAME] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Alto
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El alto debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				WHERE
					[M].[HIGH] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Ancho
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El ancho debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				WHERE
					[M].[WIDTH] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Factor volumen
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El FactorVolumen debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				WHERE
					[M].[VOLUME_FACTOR] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Largo
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El largo debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				WHERE
					[M].[LENGTH] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Unidad peso
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El UnidadPeso debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_TYPE] = 'SISTEMA'
											AND [C].[PARAM_GROUP] = 'UNIDAD_PESO'
											AND [C].[PARAM_NAME] = [M].[WEIGHT_MEASUREMENT]
											)
				WHERE
					[C].[PARAM_CAPTION] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Peso
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'El peso debe de ser mayor o igual a cero'
				FROM
					@MATERIAL [M]
				WHERE
					[M].[WEIGTH] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- el producto no maneja serie pero se coloco en si el campo de serie correlativa
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MATERIAL_ORDER
					,@MATERIAL_SECCTION
					,[M].[LINE_NUM]
					,'No se puede configurar Series correlativas al material porque el material no maneja series. '
				FROM
					@MATERIAL [M]
				WHERE
					[M].[SERIAL_NUMBER_REQUESTS] = 0
					AND [M].[HANDLE_CORRELATIVE_SERIALS] = 1;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Agrega los materiales
				-- ------------------------------------------------------------------------------------
				select @MATERIAL_SECCTION = 'agrega materiales'
				IF @HAS_ERROR = 0
				BEGIN
					MERGE [wms].[OP_WMS_MATERIALS] AS [M]
					USING
						(SELECT
								[LINE_NUM]
								,[CLIENT_OWNER]
								,[MATERIAL_ID]
								,[BARCODE_ID]
								,[ALTERNATE_BARCODE]
								,[MATERIAL_NAME]
								,[SHORT_NAME]
								,[VOLUME_FACTOR]
								,[MATERIAL_CLASS]
								,[MATERIAL_SUB_CLASS]
								,[HIGH]
								,[LENGTH]
								,[WIDTH]
								,[MAX_X_BIN]
								,[WEIGTH]
								,[LAST_UPDATED]
								,[LAST_UPDATED_BY]
								,[IS_CAR]
								,[BATCH_REQUESTED]
								,[SERIAL_NUMBER_REQUESTS]
								,[IS_MASTER_PACK]
								,[WEIGHT_MEASUREMENT]
								,[EXPLODE_IN_RECEPTION]
								,[USE_PICKING_LINE]
								,[HANDLE_CORRELATIVE_SERIALS]
								,[PREFIX_CORRELATIVE_SERIALS]
								,[LEAD_TIME]
								,[SUPPLIER]
								,[NAME_SUPPLIER]
							FROM
								@MATERIAL) AS [TM]
					ON [M].[CLIENT_OWNER] = [TM].[CLIENT_OWNER]
						AND [M].[MATERIAL_ID] = [TM].[MATERIAL_ID]
					WHEN MATCHED THEN
						UPDATE SET
									[M].[BARCODE_ID] = [TM].[BARCODE_ID]
									,[M].[ALTERNATE_BARCODE] = [TM].[ALTERNATE_BARCODE]
									,[M].[MATERIAL_NAME] = [TM].[MATERIAL_NAME]
									,[M].[SHORT_NAME] = [TM].[SHORT_NAME]
									,[M].[VOLUME_FACTOR] = [TM].[VOLUME_FACTOR]
									,[M].[MATERIAL_CLASS] = [TM].[MATERIAL_CLASS]
									,[M].[MATERIAL_SUB_CLASS] = [TM].[MATERIAL_SUB_CLASS]
									,[M].[HIGH] = [TM].[HIGH]
									,[M].[LENGTH] = [TM].[LENGTH]
									,[M].[WIDTH] = [TM].[WIDTH]
									,[M].[MAX_X_BIN] = [TM].[MAX_X_BIN]
									,[M].[WEIGTH] = [TM].[WEIGTH]
									,[M].[LAST_UPDATED] = [TM].[LAST_UPDATED]
									,[M].[LAST_UPDATED_BY] = [TM].[LAST_UPDATED_BY]
									,[M].[IS_CAR] = [TM].[IS_CAR]
									,[M].[BATCH_REQUESTED] = [TM].[BATCH_REQUESTED]
									,[M].[SERIAL_NUMBER_REQUESTS] = [TM].[SERIAL_NUMBER_REQUESTS]
									,[M].[IS_MASTER_PACK] = [TM].[IS_MASTER_PACK]
									,[M].[WEIGHT_MEASUREMENT] = [TM].[WEIGHT_MEASUREMENT]
									,[M].[EXPLODE_IN_RECEPTION] = [TM].[EXPLODE_IN_RECEPTION]
									,[M].[USE_PICKING_LINE] = [TM].[USE_PICKING_LINE]
									,[M].[HANDLE_CORRELATIVE_SERIALS] = [TM].[HANDLE_CORRELATIVE_SERIALS]
									,[M].[PREFIX_CORRELATIVE_SERIALS] = [TM].[PREFIX_CORRELATIVE_SERIALS]
									,[M].[LEAD_TIME] = [TM].[LEAD_TIME]
									,[M].[SUPPLIER] = [TM].[SUPPLIER]
									,[M].[NAME_SUPPLIER] = [TM].[NAME_SUPPLIER]
					WHEN NOT MATCHED THEN
						INSERT
								(
									[CLIENT_OWNER]
									,[MATERIAL_ID]
									,[BARCODE_ID]
									,[ALTERNATE_BARCODE]
									,[MATERIAL_NAME]
									,[SHORT_NAME]
									,[VOLUME_FACTOR]
									,[MATERIAL_CLASS]
									,[MATERIAL_SUB_CLASS]
									,[HIGH]
									,[LENGTH]
									,[WIDTH]
									,[MAX_X_BIN]
									,[LAST_UPDATED]
									,[LAST_UPDATED_BY]
									,[IS_CAR]
									,[BATCH_REQUESTED]
									,[SERIAL_NUMBER_REQUESTS]
									,[IS_MASTER_PACK]
									,[WEIGHT_MEASUREMENT]
									,[EXPLODE_IN_RECEPTION]
									,[WEIGTH]
									,[USE_PICKING_LINE]
									,[HANDLE_CORRELATIVE_SERIALS]
									,[PREFIX_CORRELATIVE_SERIALS]
									,[LEAD_TIME]
									,[SUPPLIER]
									,[NAME_SUPPLIER]
								)
						VALUES	(
									[TM].[CLIENT_OWNER]
									,[TM].[MATERIAL_ID]
									,[TM].[BARCODE_ID]
									,[TM].[ALTERNATE_BARCODE]
									,[TM].[MATERIAL_NAME]
									,[TM].[SHORT_NAME]
									,[TM].[VOLUME_FACTOR]
									,[TM].[MATERIAL_CLASS]
									,[TM].[MATERIAL_SUB_CLASS]
									,[TM].[HIGH]
									,[TM].[LENGTH]
									,[TM].[WIDTH]
									,[TM].[MAX_X_BIN]
									,[TM].[LAST_UPDATED]
									,[TM].[LAST_UPDATED_BY]
									,[TM].[IS_CAR]
									,[TM].[BATCH_REQUESTED]
									,[TM].[SERIAL_NUMBER_REQUESTS]
									,[TM].[IS_MASTER_PACK]
									,[TM].[WEIGHT_MEASUREMENT]
									,[TM].[EXPLODE_IN_RECEPTION]
									,[TM].[WEIGTH]
									,[TM].[USE_PICKING_LINE]
									,[TM].[HANDLE_CORRELATIVE_SERIALS]
									,[TM].[PREFIX_CORRELATIVE_SERIALS]
									,[TM].[LEAD_TIME]
									,[TM].[SUPPLIER]
									,[TM].[NAME_SUPPLIER]
								);
				END;
			END TRY
			BEGIN CATCH
				SET @HAS_ERROR = 1;
				--
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					1
					,@MATERIAL_SECCTION
					,-1
					,ERROR_MESSAGE();
			END CATCH;
		END;

		-- ------------------------------------------------------------------------------------
		-- Carga de ubicaciones
		-- ------------------------------------------------------------------------------------
		IF @LOCATIONS IS NOT NULL
		BEGIN
			BEGIN TRY
				PRINT '--> Carga de ubicaciones';
				select @MATERIAL_SECCTION = 'carga ubicaciones'
				--
				INSERT	INTO @LOCATION
						(
							[CLIENT_CODE]
							,[MATERIAL_ID]
							,[LOCATION_SPOT]
							,[LAST_UPDATED]
							,[LAST_UPDATED_BY]
							,[MAX_QUANTITY]
							,[MIN_QUANTITY]
						)
				SELECT
					[x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
					,([x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
						+ '/'
						+ [x].[Rec].[query]('./CodigoDeMaterial').[value]('.',
											'varchar(50)'))
					,[x].[Rec].[query]('./Ubicacion').[value]('.',
											'varchar(25)')
					,GETDATE()
					,@LOGIN
					,[x].[Rec].[query]('./CantidadMaxima').[value]('.',
											'numeric(18,0)')
					,[x].[Rec].[query]('./CantidadMinima').[value]('.',
											'numeric(18,0)')
				FROM
					@LOCATIONS.[nodes]('/Data/Ubicacion') AS [x] ([Rec]);

				-- ------------------------------------------------------------------------------------
				-- Se validan los clientes
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@LOCATION_ORDER
					,@LOCATION_SECCTION
					,[L].[LINE_NUM]
					,'No existe el cliente '
					+ [L].[CLIENT_CODE]
				FROM
					@LOCATION [L]
				LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON ([L].[CLIENT_CODE] = [C].[CLIENT_CODE])
				WHERE
					[C].[CLIENT_NAME] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Se validan los materiales
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@LOCATION_ORDER
					,@LOCATION_SECCTION
					,[L].[LINE_NUM]
					,'No existe el material '
					+ [L].[MATERIAL_ID]
				FROM
					@LOCATION [L]
				LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [L].[MATERIAL_ID])
				WHERE
					[M].[CLIENT_OWNER] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Se validan las ubicaciones
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@LOCATION_ORDER
					,@LOCATION_SECCTION
					,[L].[LINE_NUM]
					,'No existe la ubicacion '
					+ [L].[LOCATION_SPOT]
				FROM
					@LOCATION [L]
				LEFT JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON ([S].[LOCATION_SPOT] = [L].[LOCATION_SPOT])
				WHERE
					[S].[WAREHOUSE_PARENT] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Se valida cantidad minima
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@LOCATION_ORDER
					,@LOCATION_SECCTION
					,[L].[LINE_NUM]
					,'La cantidad minima debe de ser mayor o igual a cero'
				FROM
					@LOCATION [L]
				WHERE
					[L].[MIN_QUANTITY] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Se valida cantidad maxima
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@LOCATION_ORDER
					,@LOCATION_SECCTION
					,[L].[LINE_NUM]
					,'La cantidad maxima debe de ser mayor o igual a la cantidad minima'
				FROM
					@LOCATION [L]
				WHERE
					[L].[MAX_QUANTITY] < 0
					OR [L].[MAX_QUANTITY] < [L].[MIN_QUANTITY];
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				
				-- ------------------------------------------------------------------------------------
				-- Se insetan las ubicaciones
				-- ------------------------------------------------------------------------------------
				select @MATERIAL_SECCTION = 'inserta ubicaciones'
				IF @HAS_ERROR = 0
				BEGIN
					MERGE [wms].[OP_WMS_MATERIALS_JOIN_SPOTS]
						AS [S]
					USING
						(SELECT
								[L].[LINE_NUM]
								,[L].[MATERIAL_ID]
								,[S].[WAREHOUSE_PARENT]
								,[L].[LOCATION_SPOT]
								,[L].[LAST_UPDATED]
								,[L].[LAST_UPDATED_BY]
								,[L].[MAX_QUANTITY]
								,[L].[MIN_QUANTITY]
							FROM
								@LOCATION [L]
							INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON ([S].[LOCATION_SPOT] = [L].[LOCATION_SPOT]))
						AS [TL]
					ON [S].[MATERIAL_ID] = [TL].[MATERIAL_ID]
						AND [S].[LOCATION_SPOT] = [TL].[LOCATION_SPOT]
					WHEN MATCHED THEN
						UPDATE SET
									[S].[WAREHOUSE_PARENT] = [TL].[WAREHOUSE_PARENT]
									,[S].[LAST_UPDATED] = [TL].[LAST_UPDATED]
									,[S].[LAST_UPDATED_BY] = [TL].[LAST_UPDATED_BY]
									,[S].[MAX_QUANTITY] = [TL].[MAX_QUANTITY]
									,[S].[MIN_QUANTITY] = [TL].[MIN_QUANTITY]
					WHEN NOT MATCHED THEN
						INSERT
								(
									[MATERIAL_ID]
									,[WAREHOUSE_PARENT]
									,[LOCATION_SPOT]
									,[LAST_UPDATED]
									,[LAST_UPDATED_BY]
									,[MAX_QUANTITY]
									,[MIN_QUANTITY]
								)
						VALUES	(
									[TL].[MATERIAL_ID]
									,[TL].[WAREHOUSE_PARENT]
									,[TL].[LOCATION_SPOT]
									,[TL].[LAST_UPDATED]
									,[TL].[LAST_UPDATED_BY]
									,[TL].[MAX_QUANTITY]
									,[TL].[MIN_QUANTITY]
								);
				END;
			END TRY
			BEGIN CATCH
				SET @HAS_ERROR = 1;
				--
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					2
					,@LOCATION_SECCTION
					,-1
					,ERROR_MESSAGE();
			END CATCH;
		END;
		
		-- ----------------------------------
		-- carga de unidades de medida
		-- ----------------------------------
		IF @UNIT_MEASURE_BY_MATERIAL_XML IS NOT NULL
		BEGIN
		select @MATERIAL_SECCTION = 'carga unids'
			BEGIN TRY
				PRINT '--> Carga de unidades de medida';
			
				INSERT	INTO @UNIT_MEASURE_BY_MATERIAL
						(
							[CLIENT_ID]
							,[MATERIAL_ID]
							,[MEASUREMENT_UNIT]
							,[QTY]
							,[BARCODE]
							,[ALTERNATIVE_BARCODE]
						)
				SELECT
					[x].[Rec].[query]('./CodigoDeCliente').[value]('.',
											'varchar(25)')
					,[x].[Rec].[query]('./CodigoDeMaterial').[value]('.',
											'varchar(50)')
					,[x].[Rec].[query]('./UnidadDeMedida').[value]('.',
											'varchar(50)')
					,[x].[Rec].[query]('./Cantidad').[value]('.',
											'numeric(18,0)')
					,[x].[Rec].[query]('./CodigoDeBarras').[value]('.',
											'varchar(100)')
					,[x].[Rec].[query]('./CodigoDeBarrasAlternativo').[value]('.',
											'varchar(100)')
				FROM
					@UNIT_MEASURE_BY_MATERIAL_XML.[nodes]('/Data/UnidadDeMedida')
					AS [x] ([Rec]);

					-- ------------------------------------------------
					-- SE VALIDA LA EXISTENCIA DE CLIENTES
					-- ------------------------------------------------

				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,'No existe el cliente '
					+ [UMBM].[CLIENT_ID]
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON ([C].[CLIENT_CODE] = [UMBM].[CLIENT_ID])
				WHERE
					[C].[CLIENT_CODE] IS NULL;

				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Valida que no permita insertar cantidad 0 para factor de conversion de unidad de medida
				-- ------------------------------------------------------------------------------------
				
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,'Cantidad debe ser mayor a 0 '
					+ [UMBM].[CLIENT_ID]
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				WHERE
					[UMBM].[QTY] <= 0;

				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
			
					-- -------------------------------------------------
					-- SE VALIDA LA EXISTENCIA DE LOS MATERIALES
					-- -------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,'No existe el material '
					+ [UMBM].[MATERIAL_ID]
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [UMBM].[MATERIAL_ID])
				WHERE
					[M].[MATERIAL_ID] IS NULL;
					--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
			

					-- SE VALIDA QUE LOS CODIGOS DE BARRAS NO COINCIDAN CON NINGUN MATERIAL
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,CASE	WHEN [UMBM].[BARCODE] = [M].[BARCODE_ID]
							THEN 'El código de barras '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de productos'
							WHEN [UMBM].[BARCODE] = [M].[ALTERNATE_BARCODE]
							THEN 'El código de barras '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de productos'
						END
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				JOIN [wms].[OP_WMS_MATERIALS] [M] ON [UMBM].[MATERIAL_ID] = [M].[MATERIAL_ID]
				WHERE
					(
						([M].[BARCODE_ID] = [UMBM].[BARCODE])
						OR ([M].[ALTERNATE_BARCODE] = [UMBM].[BARCODE])
					)
					AND [M].[CLIENT_OWNER] = [UMBM].[CLIENT_ID];
			

				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,CASE	WHEN [UMBM].[ALTERNATIVE_BARCODE] = [M].[BARCODE_ID]
							THEN 'El código de barras alternativo '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de productos'
							WHEN [UMBM].[ALTERNATIVE_BARCODE] = [M].[ALTERNATE_BARCODE]
							THEN 'El código de barras alternativo '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de productos'
						END
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				JOIN [wms].[OP_WMS_MATERIALS] [M] ON [UMBM].[MATERIAL_ID] = [M].[MATERIAL_ID]
				WHERE
					ISNULL([UMBM].[ALTERNATIVE_BARCODE], '') != ''
					AND (
							([M].[BARCODE_ID] = [UMBM].[ALTERNATIVE_BARCODE])
							OR ([M].[ALTERNATE_BARCODE] = [UMBM].[ALTERNATIVE_BARCODE])
						)
					AND [M].[CLIENT_OWNER] = [UMBM].[CLIENT_ID];
			
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- se valida que el codigo de barras alternativo no coincida con ningun material
				-- ------------------------------------------------------------------------------------
				
				
				-- ----------------------------------------------------------------------
				-- SE VALIDAN LAS CONFIGURACIONES (UNIDADES DE MEDIDA EN [ONFIGURATIONS])
				-- ----------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,'No existe la unidad de medida '
					+ [UMBM].[MEASUREMENT_UNIT]
					+ ' en configuraciones'
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON (
											[C].[PARAM_NAME] = [UMBM].[MEASUREMENT_UNIT]
											AND [C].[PARAM_TYPE] = 'ALMACENAMIENTO'
											AND [C].[PARAM_GROUP] = 'TIPOS_EMPAQUE'
											)
				WHERE
					[C].[PARAM_NAME] IS NULL;
			
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
			
			
					-- --------------------------------------------------------------------------
					-- SE VALIDA EXISTENCIA DE DUPLICADOS(BARCODE) EN TABLA [UNIT_MEASUREMENT_BY_MATERIAL]
					-- --------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,CASE	WHEN [UMBM].[BARCODE] = [UM].[BARCODE]
							THEN 'El código de barras '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de unidades de medida'
							WHEN [UMBM].[BARCODE] = [UM].[ALTERNATIVE_BARCODE]
							THEN 'El código de barras '
									+ [UMBM].[BARCODE]
									+ ' ya existe en el catálogo de unidades de medida'
						END
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UM] ON (
											[UMBM].[MATERIAL_ID] = [UM].[MATERIAL_ID]
											AND [UMBM].[CLIENT_ID] = [UM].[CLIENT_ID]
											)
				WHERE
					(
						[UMBM].[BARCODE] = [UM].[BARCODE]
						OR [UMBM].[BARCODE] = [UM].[ALTERNATIVE_BARCODE]
					);
				
			
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- --------------------------------------------------------------------------
					-- SE VALIDA EXISTENCIA DE DUPLICADOS(ALTERNATE_BARCODE) EN TABLA [UNIT_MEASUREMENT_BY_MATERIAL]
					-- --------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@UNIT_MEASURE_BY_MATERIAL_ORDER
					,@UNIT_MEASURE_BY_MATERIAL_SECTION
					,[UMBM].[LINE_NUM]
					,CASE	WHEN [UMBM].[ALTERNATIVE_BARCODE] = [UM].[BARCODE]
							THEN 'El código de barras alternativo '
									+ [UMBM].[ALTERNATIVE_BARCODE]
									+ ' ya existe en el catálogo de unidades de medida'
							WHEN [UMBM].[ALTERNATIVE_BARCODE] = [UM].[ALTERNATIVE_BARCODE]
							THEN 'El código de barras alternativo '
									+ [UMBM].[ALTERNATIVE_BARCODE]
									+ ' ya existe en el catálogo de unidades de medida'
						END
				FROM
					@UNIT_MEASURE_BY_MATERIAL [UMBM]
				JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UM] ON (
											[UMBM].[MATERIAL_ID] = [UM].[MATERIAL_ID]
											AND [UMBM].[CLIENT_ID] = [UM].[CLIENT_ID]
											)
				WHERE
					ISNULL([UMBM].[ALTERNATIVE_BARCODE], '') != ''
					AND (
							[UMBM].[ALTERNATIVE_BARCODE] = [UM].[BARCODE]
							OR [UMBM].[ALTERNATIVE_BARCODE] = [UM].[ALTERNATIVE_BARCODE]
						);
				
			
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
			
			
					-- -----------------------------
					-- INSERTANDO UNIDADES DE MEDIDA 
					-- -----------------------------
				IF @HAS_ERROR = 0
				BEGIN
					MERGE [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL]
						AS [TABLEBDD]
					USING
						(SELECT
								[CLIENT_ID]
								,[MATERIAL_ID]
								,[MEASUREMENT_UNIT]
								,[QTY]
								,[BARCODE]
								,[ALTERNATIVE_BARCODE]
							FROM
								@UNIT_MEASURE_BY_MATERIAL)
						AS [TABLEVIRTUAL]
					ON (
						[TABLEBDD].[CLIENT_ID] = [TABLEVIRTUAL].[CLIENT_ID]
						AND [TABLEBDD].[MATERIAL_ID] = [TABLEVIRTUAL].[MATERIAL_ID]
						AND [TABLEBDD].[MEASUREMENT_UNIT] = [TABLEVIRTUAL].[MEASUREMENT_UNIT]
						)
					WHEN MATCHED THEN
						UPDATE SET
									[TABLEBDD].[QTY] = [TABLEVIRTUAL].[QTY]
									,[TABLEBDD].[BARCODE] = [TABLEVIRTUAL].[BARCODE]
									,[TABLEBDD].[ALTERNATIVE_BARCODE] = [TABLEVIRTUAL].[ALTERNATIVE_BARCODE]
					WHEN NOT MATCHED THEN
						INSERT
								(
									[CLIENT_ID]
									,[MATERIAL_ID]
									,[MEASUREMENT_UNIT]
									,[QTY]
									,[BARCODE]
									,[ALTERNATIVE_BARCODE]
								)
						VALUES	(
									[TABLEVIRTUAL].[CLIENT_ID]
									,[TABLEVIRTUAL].[MATERIAL_ID]
									,[TABLEVIRTUAL].[MEASUREMENT_UNIT]
									,[TABLEVIRTUAL].[QTY]
									,[TABLEVIRTUAL].[BARCODE]
									,[TABLEVIRTUAL].[ALTERNATIVE_BARCODE]
								);
				END;
			
			END TRY
			BEGIN CATCH
			
				SET @HAS_ERROR = 1;
			
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					1
					,@MATERIAL_SECCTION
					,-1
					,ERROR_MESSAGE();
			
			END CATCH;
		END;			

		-- ------------------------------------------------------------------------------------
		-- Carga de master pack
		-- ------------------------------------------------------------------------------------
		IF @MASTER_PACKS IS NOT NULL
		BEGIN
			BEGIN TRY
				PRINT '--> Carga de master packs';
				select @MASTER_PACK_SECCTION = 'Carga de master packs'
				--
				INSERT	INTO @MASTER_PACK
						(
							[CLIENT_CODE]
							,[MASTER_PACK_CODE]
							,[COMPONENT_MATERIAL]
							,[QTY]
						)
				SELECT
					[x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
					,([x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
						+ '/'
						+ [x].[Rec].[query]('./CodigoMasterPack').[value]('.',
											'varchar(50)'))
					,([x].[Rec].[query]('./Cliente').[value]('.',
											'varchar(25)')
						+ '/'
						+ [x].[Rec].[query]('./CodigoComponente').[value]('.',
											'varchar(50)'))
					,[x].[Rec].[query]('./Cantidad').[value]('.',
										'DECIMAL(18,5)')
				FROM
					@MASTER_PACKS.[nodes]('/Data/MasterPack')
					AS [x] ([Rec]);

				-- ------------------------------------------------------------------------------------
				-- Se validan los clientes
				-- ------------------------------------------------------------------------------------
				select @MASTER_PACK_SECCTION = '2'
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MASTER_PACK_ORDER
					,@MASTER_PACK_SECCTION
					,[M].[LINE_NUM]
					,'No existe el cliente '
					+ [M].[CLIENT_CODE]
				FROM
					@MASTER_PACK [M]
				LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON ([M].[CLIENT_CODE] = [C].[CLIENT_CODE])
				WHERE
					[C].[CLIENT_NAME] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				select @MASTER_PACK_SECCTION = '3'
				-- ------------------------------------------------------------------------------------
				-- Valida que existan los masterpack y esten configurados como tal
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MASTER_PACK_ORDER
					,@MASTER_PACK_SECCTION
					,[M].[LINE_NUM]
					,'No existe el master pack '
					+ [M].[MASTER_PACK_CODE]
				FROM
					@MASTER_PACK [M]
				LEFT JOIN [wms].[OP_WMS_MATERIALS] [MA] ON (
											[MA].[MATERIAL_ID] = [M].[MASTER_PACK_CODE]
											AND [MA].[IS_MASTER_PACK] = 1
											)
				WHERE
					[MA].[CLIENT_OWNER] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;
				select @MASTER_PACK_SECCTION = '4'
				-- ------------------------------------------------------------------------------------
				-- Validar que existan los componentes
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MASTER_PACK_ORDER
					,@MASTER_PACK_SECCTION
					,[M].[LINE_NUM]
					,'No existe el componente '
					+ [M].[COMPONENT_MATERIAL]
				FROM
					@MASTER_PACK [M]
				LEFT JOIN [wms].[OP_WMS_MATERIALS] [MA] ON ([MA].[MATERIAL_ID] = [M].[COMPONENT_MATERIAL])
				WHERE
					[MA].[CLIENT_OWNER] IS NULL;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
					select @MASTER_PACK_SECCTION = '10'
				END;

				-- ------------------------------------------------------------------------------------
				-- Validar Cantidad
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					@MASTER_PACK_ORDER
					,@MASTER_PACK_SECCTION
					,[M].[LINE_NUM]
					,'La cantidad del componente debe ser mayor a cero'
				FROM
					@MASTER_PACK [M]
				WHERE
					[M].[QTY] < 0;
				--
				IF @@ROWCOUNT > 0
				BEGIN
					SET @HAS_ERROR = 1;
				END;

				-- ------------------------------------------------------------------------------------
				-- Se agregan los componentes
				-- ------------------------------------------------------------------------------------
				IF @HAS_ERROR = 0
				BEGIN
				select @MASTER_PACK_SECCTION = 'Se agregan los componentes'
					MERGE [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
						AS [C]
					USING
						(SELECT
								[M].[LINE_NUM]
								,[M].[MASTER_PACK_CODE]
								,[M].[COMPONENT_MATERIAL]
								,[M].[QTY]
							FROM
								@MASTER_PACK [M]) AS [TM]
					ON [C].[MASTER_PACK_CODE] = [TM].[MASTER_PACK_CODE]
						AND [C].[COMPONENT_MATERIAL] = [TM].[COMPONENT_MATERIAL]
					WHEN MATCHED THEN
						UPDATE SET
									[C].[QTY] = [TM].[QTY]
					WHEN NOT MATCHED THEN
						INSERT
								(
									[MASTER_PACK_CODE]
									,[COMPONENT_MATERIAL]
									,[QTY]
								)
						VALUES	(
									[TM].[MASTER_PACK_CODE]
									,[TM].[COMPONENT_MATERIAL]
									,[TM].[QTY]
								);
				END;
			END TRY
			BEGIN CATCH
				SET @HAS_ERROR = 1;
				--
				INSERT	INTO @ERROR
						(
							[ORDER]
							,[PART]
							,[LINE_NUM]
							,[MESSAGE]
						)
				SELECT
					3
					,@MASTER_PACK_SECCTION
					,-1
					,ERROR_MESSAGE();
			END CATCH;
		END;

		-- ------------------------------------------------------------------------------------
		-- Carga de Propiedades 
		-- ------------------------------------------------------------------------------------
		IF @PROPERTIES IS NOT NULL
		BEGIN 
			
			-- ------------------------------------------------------------------------------------
			-- Lee el xml
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @MATERIAL_PROPERTY_BY_WAREHOUSE
					(
						[MATERIAL_PROPERTY_ID]
						,[WAREHOUSE_ID]
						,[MATERIAL_ID]
						,[VALUE]
						,[LOGIN]
					)
			SELECT
				ISNULL([P].[MATERIAL_PROPERTY_ID],
						CAST([x].[Rec].[query]('./Propiedad').[value]('.',
											'varchar(250)') AS INT))
				,[x].[Rec].[query]('./Bodega').[value]('.',
											'varchar(50)')
				,[x].[Rec].[query]('./Material').[value]('.',
											'varchar(50)')
				,ISNULL([O].[VALUE],
						[x].[Rec].[query]('./Valor').[value]('.',
											'varchar(250)'))
				,@LOGIN
			FROM
				@PROPERTIES.[nodes]('/Data/PropiedadesPorBodega')
				AS [x] ([Rec])
			LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [P] ON [P].[DESCRIPTION] = [x].[Rec].[query]('./Propiedad').[value]('.',
											'varchar(250)')
			LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_OPTION] [O] ON [O].[MATERIAL_PROPERTY_ID] = [O].[MATERIAL_PROPERTY_ID]
											AND [x].[Rec].[query]('./Valor').[value]('.',
											'varchar(250)') = [O].[TEXT];

		-- ------------------------------------------------------------------------------------
		-- Valida que existan la propiedad
		-- ------------------------------------------------------------------------------------
			INSERT	INTO @ERROR
					(
						[ORDER]
						,[PART]
						,[LINE_NUM]
						,[MESSAGE]
						
					)
			SELECT
				@MATERIAL_PROPERTIES_ORDER
				,@MATERIAL_PROPERTIES_SECCTION
				,[M].[LINE_NUM]
				,'No existe alguna propiedad de los materiales'
			FROM
				@MATERIAL_PROPERTY_BY_WAREHOUSE [M]
			LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON ([MP].[MATERIAL_PROPERTY_ID] = [M].[MATERIAL_PROPERTY_ID])
			WHERE
				[MP].[MATERIAL_PROPERTY_ID] IS NULL;
				--
			IF @@ROWCOUNT > 0
			BEGIN
				SET @HAS_ERROR = 1;
			END;
		-- ------------------------------------------------------------------------------------
		-- Valida que la propiedad tenga un valor correcto
		-- ------------------------------------------------------------------------------------
			INSERT	INTO @ERROR
					(
						[ORDER]
						,[PART]
						,[LINE_NUM]
						,[MESSAGE]
						
					)
			SELECT
				@MATERIAL_PROPERTIES_ORDER
				,@MATERIAL_PROPERTIES_SECCTION
				,[M].[LINE_NUM]
				,'No es correcto el valor de alguna propiedad de los materiales'
			FROM
				@MATERIAL_PROPERTY_BY_WAREHOUSE [M]
			LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_OPTION] [O] ON (
											[O].[MATERIAL_PROPERTY_ID] = [M].[MATERIAL_PROPERTY_ID]
											AND [O].[VALUE] = [M].[VALUE]
											)
			WHERE
				[O].[VALUE] IS NULL;
				--
			IF @@ROWCOUNT > 0
			BEGIN
				SET @HAS_ERROR = 1;
			END;


		-- ------------------------------------------------------------------------------------
		-- Valida que existan las bodegas
		-- ------------------------------------------------------------------------------------
		

			INSERT	INTO @ERROR
					(
						[ORDER]
						,[PART]
						,[LINE_NUM]
						,[MESSAGE]
						
					)
			SELECT
				@MATERIAL_PROPERTIES_ORDER
				,@MATERIAL_PROPERTIES_SECCTION
				,[M].[LINE_NUM]
				,'No existe alguna bodega'
			FROM
				@MATERIAL_PROPERTY_BY_WAREHOUSE [M]
			LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [M].[WAREHOUSE_ID])
			WHERE
				[W].[WAREHOUSE_ID] IS NULL;
				--
			IF @@ROWCOUNT > 0
			BEGIN
				SET @HAS_ERROR = 1;
			END;
	
		-- ------------------------------------------------------------------------------------
		-- Valida que existan los materiales
		-- ------------------------------------------------------------------------------------
		
			INSERT	INTO @ERROR
					(
						[ORDER]
						,[PART]
						,[LINE_NUM]
						,[MESSAGE]
						
					)
			SELECT
				@MATERIAL_PROPERTIES_ORDER
				,@MATERIAL_PROPERTIES_SECCTION
				,[M].[LINE_NUM]
				,'No existe algún material'
			FROM
				@MATERIAL_PROPERTY_BY_WAREHOUSE [M]
			LEFT JOIN [wms].[OP_WMS_MATERIALS] [W] ON ([W].[MATERIAL_ID] = [M].[MATERIAL_ID])
			WHERE
				[W].[MATERIAL_ID] IS NULL;
				--
			IF @@ROWCOUNT > 0
			BEGIN
				SET @HAS_ERROR = 1;
			END;
		    
		


			-- ------------------------------------------------------------------------------------
			-- Realiza el merge
			-- ------------------------------------------------------------------------------------
			MERGE [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE]
				AS [MPW]
			USING
				(SELECT
						[M].[MATERIAL_PROPERTY_ID]
						,[M].[WAREHOUSE_ID]
						,[M].[MATERIAL_ID]
						,[M].[VALUE]
						,[M].[LOGIN]
					FROM
						@MATERIAL_PROPERTY_BY_WAREHOUSE [M])
				AS [M]
			ON [MPW].[MATERIAL_PROPERTY_ID] = [M].[MATERIAL_PROPERTY_ID]
				AND [MPW].[WAREHOUSE_ID] = [M].[WAREHOUSE_ID]
				AND [MPW].[MATERIAL_ID] = [M].[MATERIAL_ID]
			WHEN MATCHED THEN
				UPDATE SET
							[MPW].[VALUE] = [M].[VALUE]
							,[MPW].[LAST_UPDATE_BY] = [M].[LOGIN]
							,[MPW].[LAST_UPDATE] = GETDATE()
			WHEN NOT MATCHED THEN
				INSERT
						(
							[MATERIAL_PROPERTY_ID]
							,[WAREHOUSE_ID]
							,[MATERIAL_ID]
							,[VALUE]
							,[CREATED_BY]
							,[CREATED_DATETIME]
							,[LAST_UPDATE_BY]
							,[LAST_UPDATE]
							
						)
				VALUES	(
							[M].[MATERIAL_PROPERTY_ID]  -- MATERIAL_PROPERTY_ID - int
							,[M].[WAREHOUSE_ID]  -- WAREHOUSE_ID - varchar(25)
							,[M].[MATERIAL_ID]  -- MATERIAL_ID - varchar(50)
							,[M].[VALUE]  -- VALUE - varchar(250)
							,[M].[LOGIN]  -- CREATED_BY - varchar(50)
							,GETDATE()  -- CREATED_DATETIME - datetime
							,[M].[LOGIN]  -- LAST_UPDATE_BY - varchar(50)
							,GETDATE()  -- LAST_UPDATE - datetime
							
						);
		
	
		END; 



		-- ------------------------------------------------------------------------------------
		-- Resultado final
		-- ------------------------------------------------------------------------------------
		IF @HAS_ERROR = 0
		BEGIN
			COMMIT;
		    --
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,'' [DbData];
		END;
		ELSE
		BEGIN
			ROLLBACK;
		    --
			SELECT
				-1 AS [Resultado]
				,'Validar listado de errores' [Mensaje]
				,0 [Codigo]
				,'' [DbData];
			--
			SELECT
				[E].[ORDER]
				,[E].[PART]
				,[E].[LINE_NUM]
				,[E].[MESSAGE]
			FROM
				@ERROR [E]
			ORDER BY
				[E].[ORDER]
				,[E].[LINE_NUM];
		END;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		--
		DECLARE	@Mensaje AS VARCHAR(MAX) = ERROR_MESSAGE(); 

		SELECT
			-1 AS [Resultado]
			,CASE	WHEN CAST(@@ERROR AS VARCHAR) = '2627'
					THEN 'Un registro se encuentra duplicado, por favor revisar.'
					WHEN @Mensaje LIKE '%Cannot insert duplicate key in object%'
					THEN 'Un registro se encuentra duplicado, por favor revisar.'
					ELSE @Mensaje
				END [Mensaje]
			,@@ERROR [Codigo];

		--
		SELECT
			[E].[ORDER]
			,[E].[PART]
			,[E].[LINE_NUM]
			,[E].[MESSAGE]
		FROM
			@ERROR [E]
		ORDER BY
			[E].[ORDER]
			,[E].[LINE_NUM];

		

	END CATCH;
END;