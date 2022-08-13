-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Carga las clases por medio de un XML.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_LOAD_CLASSES_BY_XML]
					@XML = N'
<Data>
	<Clase>
		<Nombre>Comida para Perro</Nombre>
		<Descripcion>Comida para Perros</Descripcion>
		<Tipo>Productos</Tipo>
	</Clase>
	<Clase>
		<Nombre>Productos de Limpieza</Nombre>
		<Descripcion>Productos de Limpiezas</Descripcion>
		<Tipo>Productos</Tipo>
	</Clase>
	<Clase>
		<Nombre>Baterias</Nombre>
		<Descripcion>Baterias</Descripcion>
		<Tipo>Productos</Tipo>
	</Clase>
</Data>'
					,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_LOAD_CLASSES_BY_XML] (
		@XML XML
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@CLASS TABLE (
			[CLASS_NAME] [VARCHAR](50) NOT NULL
			,[CLASS_DESCRIPTION] [VARCHAR](250) NOT NULL
			,[CLASS_TYPE] [VARCHAR](50) NOT NULL
			,[CREATED_BY] [VARCHAR](50) NOT NULL
			,[CREATED_DATETIME] [DATETIME] NOT NULL
			,[LAST_UPDATED_BY] [VARCHAR](50) NOT NULL
			,[LAST_UPDATED] [DATETIME] NOT NULL
			,[PRIORITY] INT NOT NULL 
		);
	--
	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Inserta los valores del XML en la tabla @CLASS
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CLASS
				(
					[CLASS_NAME]
					,[CLASS_DESCRIPTION]
					,[CLASS_TYPE]
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[PRIORITY]
				)
		SELECT
			[x].[Rec].[query]('./CLASS_NAME').[value]('.','varchar(50)')
			,[x].[Rec].[query]('./CLASS_DESCRIPTION').[value]('.','varchar(250)')
			,[x].[Rec].[query]('./CLASS_TYPE').[value]('.','varchar(50)')
			,@LOGIN
			,GETDATE()
			,@LOGIN
			,GETDATE()
			,[x].[Rec].[query]('./PRIORITY').[value]('.','INT')
		FROM
			@XML.[nodes]('/ArrayOfClase/Clase') AS [x] ([Rec]);
		-- ------------------------------------------------------------------------------------
		-- Hace merge entre la tabla OP_WMS_CLASS y los valores insertados anteriormente
		-- ------------------------------------------------------------------------------------
		MERGE [wms].[OP_WMS_CLASS] AS [C]
		USING
			(SELECT
					[CLASS_NAME]
					,[CLASS_DESCRIPTION]
					,[CLASS_TYPE]
					,[CREATED_BY]
					,[CREATED_DATETIME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[PRIORITY]
				FROM
					@CLASS) AS [TC]
		ON [C].[CLASS_ID] > 0 and
			[TC].[CLASS_NAME] = [C].[CLASS_NAME]
		WHEN MATCHED THEN
			UPDATE SET
					[C].[CLASS_NAME] = [TC].[CLASS_NAME]
					,[C].[CLASS_DESCRIPTION] = [TC].[CLASS_DESCRIPTION]
					,[C].[CLASS_TYPE] = [TC].[CLASS_TYPE]
					,[C].[LAST_UPDATED_BY] = [TC].[LAST_UPDATED_BY]
					,[C].[LAST_UPDATED] = [TC].[LAST_UPDATED]
					,[C].[PRIORITY] = [TC].[PRIORITY]
		WHEN NOT MATCHED THEN
			INSERT
					(
						[CLASS_NAME]
						,[CLASS_DESCRIPTION]
						,[CLASS_TYPE]
						,[CREATED_BY]
						,[CREATED_DATETIME]
						,[LAST_UPDATED_BY]
						,[LAST_UPDATED] 
						,[PRIORITY]
					)
			VALUES	(
						[TC].[CLASS_NAME]
						,[TC].[CLASS_DESCRIPTION]
						,[TC].[CLASS_TYPE]
						,[TC].[CREATED_BY]
						,[TC].[CREATED_DATETIME]
						,[TC].[LAST_UPDATED_BY]
						,[TC].[LAST_UPDATED]
						,[TC].[PRIORITY]
					);
		-- ------------------------------------------------------------------------------------
		-- Muestra resultado
		-- ------------------------------------------------------------------------------------
		COMMIT;	
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Despliega el error
		-- ------------------------------------------------------------------------------------
		ROLLBACK;
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;