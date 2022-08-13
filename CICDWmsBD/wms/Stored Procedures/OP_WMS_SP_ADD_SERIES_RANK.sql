-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190123 GForce@Rinoceronte
-- Description:			SP que inserta en recepcion/reubicacion o compromete en un picking un rango de series


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_ADD_SERIES_RANK] @LICENSE_ID = NULL, -- numeric
	@MATERIAL_ID = '', -- varchar(250)
	@BATCH = '', -- varchar(50)
	@DATE_EXPIRATION = '2019-01-24 17:06:33', -- date
	@PREFIX = '', -- varchar(500)
	@START_VALUE = '', -- varchar(500)
	@END_VALUE = '', -- varchar(500)
	@SUFIX = '', -- varchar(500)
	@STATUS = 0, -- int
	@WAVE_PICKING_ID = 0, -- int
	@OPERATION_TYPE = '', -- varchar(50)
	@LOGIN = '' -- varchar(50)



*/

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_SERIES_RANK] (
		@LICENSE_ID NUMERIC(18, 0)
		,@MATERIAL_ID VARCHAR(250)
		,@BATCH VARCHAR(50) = NULL
		,@DATE_EXPIRATION DATE = NULL
		,@PREFIX VARCHAR(500)
		,@START_VALUE VARCHAR(500)
		,@END_VALUE VARCHAR(500)
		,@SUFIX VARCHAR(500)
		,@STATUS INT = NULL
		,@WAVE_PICKING_ID INT = NULL
		,@OPERATION_TYPE VARCHAR(50)
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	
		 
	DECLARE
		@width INT     = LEN(@START_VALUE)
		,@pad CHAR(1) = '0'
		,@ErrorCode INT
		,@Mensaje VARCHAR(MAX)
		,@I_SERIAL VARCHAR(250)
		,@startnum INT= CAST(@START_VALUE AS INT)
		,@endnum INT= CAST(@END_VALUE AS INT)
		,@SERIES_COUNT INT = 0;


	DECLARE	@OPERACION TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(MAX)
			,[Codigo] INT
			,[DbData] VARCHAR(MAX)
		);
	WITH	[gen]
				AS (SELECT
						@startnum AS [num]
					UNION ALL
					SELECT
						[num] + 1
					FROM
						[gen]
					WHERE
						[num] + 1 <= @endnum)
		SELECT
			@PREFIX
			+ CAST(STUFF(CONVERT(VARCHAR(99), [gen].[num]),                            -- source string (converted from numeric value)
							CASE	WHEN [gen].[num] < 0
									THEN 2
									ELSE 1
							END,                 -- insert position
							0,                                                  -- count of characters to remove from source string
							REPLICATE(@pad,
										@width
										- LEN(CONVERT(VARCHAR(99), [gen].[num])))-- text to be inserted
         ) AS VARCHAR) + @SUFIX [SERIAL]
			,0 [USED]
		INTO
			[#SERIAL]
		FROM
			[gen]
	OPTION
			(MAXRECURSION 32767);

	SELECT
		@SERIES_COUNT = COUNT(*)
	FROM
		[#SERIAL];
	IF @SERIES_COUNT > = 1000
	BEGIN
		SELECT
			-1 AS [Resultado]
			,'El rango sobrepasa el maximo de 1000 series.' [Mensaje]
			,3060 [Codigo]
			,'' [DbData];
		RETURN; 
	END; 

	BEGIN TRAN; 
	BEGIN TRY
			

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#SERIAL]
						WHERE
							[USED] = 0 )
		BEGIN

			PRINT @I_SERIAL;
			
			SELECT TOP 1
				@I_SERIAL = [SERIAL]
			FROM
				[#SERIAL]
			WHERE
				[USED] = 0;
			PRINT @I_SERIAL;

			IF (@OPERATION_TYPE = 'TAREA_RECEPCION')
			BEGIN

				
				INSERT	INTO @OPERACION
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
							,[DbData]
						
						)
						EXEC [wms].[OP_WMS_SP_INSERT_MATERIAL_X_SERIAL_NUMBER] @LICENSE_ID = @LICENSE_ID, -- numeric
							@MATERIAL_ID = @MATERIAL_ID, -- varchar(250)
							@SERIAL = @I_SERIAL; -- varchar(50)
			END;
			ELSE
				IF (@OPERATION_TYPE = 'DESPACHO_GENERAL')
				BEGIN 
					INSERT	INTO @OPERACION
							(
								[Resultado]
								,[Mensaje]
								,[Codigo]
								,[DbData]
						
							)
							EXEC [wms].[OP_WMS_SP_UPDATE_SCANNED_SERIAL_NUMBER_TO_PROCESS_RANK] @SERIAL_NUMBER = @I_SERIAL, -- varchar(50)
								@LICENSE_ID = @LICENSE_ID, -- decimal
								@STATUS = @STATUS, -- int
								@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
								@MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
								@LOGIN = @LOGIN, -- varchar(50)
								@TASK_TYPE = @OPERATION_TYPE; -- varchar(25)
				END; 
				ELSE
					IF (@OPERATION_TYPE = 'REUBICACION_PARCIAL')
					BEGIN
						INSERT	INTO @OPERACION
								(
									[Resultado]
									,[Mensaje]
									,[Codigo]
									,[DbData]
						
								)
								EXEC [wms].[OP_WMS_SP_UPDATE_SCANNED_SERIAL_NUMBER_TO_PROCESS_RANK] @SERIAL_NUMBER = @I_SERIAL, -- varchar(50)
									@LICENSE_ID = @LICENSE_ID, -- decimal
									@STATUS = @STATUS, -- int
									@WAVE_PICKING_ID = NULL, -- int
									@MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
									@LOGIN = @LOGIN, -- varchar(50)
									@TASK_TYPE = @OPERATION_TYPE; -- varchar(25)
								
					END; 
					ELSE
					BEGIN 
						SELECT
							@ErrorCode = -1;
						RAISERROR ('Operación erronea', 16, 1);
					END;  



			IF EXISTS ( SELECT TOP 1
							1
						FROM
							@OPERACION
						WHERE
							[Resultado] = -1 )
			BEGIN 
				SELECT TOP 1
					@ErrorCode = [Codigo]
					,@Mensaje = [Mensaje]
				FROM
					@OPERACION
				WHERE
					[Resultado] = -1;
				RAISERROR (@Mensaje, 16, 1);
				RETURN;
			END; 
				
			UPDATE
				[#SERIAL]
			SET	
				[USED] = 1
			WHERE
				[SERIAL] = @I_SERIAL;	

		END; 

		SELECT
			1 [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,1 [Codigo]
			,CAST('' AS VARCHAR) [DbData];

		SELECT
			[SERIAL]
		FROM
			[#SERIAL];

		COMMIT;

		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END; 
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@ErrorCode [Codigo]
			,'' [DbData];
	END CATCH;

	
END;




