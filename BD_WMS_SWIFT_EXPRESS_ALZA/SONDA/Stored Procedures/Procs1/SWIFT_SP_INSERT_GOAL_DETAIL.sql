-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	04-07-2018
-- Description:			Inserta el detalle de metas para el equipo.

-- Modificacion 		8/5/2019 @ G-Force Team Sprint Groenlandia
-- Autor: 				diego.as
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/5/2019 - Se modifica SP para que tome como parametro un XML con toda la informacion de la meta que ha sido procesada en el BO de Swift Express

/*
-- Ejemplo de Ejecucion:
	exec [SONDA].[SWIFT_SP_INSERT_GOAL_DETAIL]
	@GOAL = '
	<Meta>
		<GOAL_HEADER_ID>2022</GOAL_HEADER_ID>
		<GOAL_NAME>PRUEBA DA</GOAL_NAME>
		<TEAM_ID>2</TEAM_ID>
		<SUPERVISOR_ID xsi:nil=\"true\" />
		<GOAL_AMOUNT>5000</GOAL_AMOUNT>
		<GOAL_DATE_FROM>2019-08-06T00:00:00</GOAL_DATE_FROM>
		<GOAL_DATE_TO>2019-08-31T00:00:00</GOAL_DATE_TO>
		<STATUS>CREATED</STATUS>
		<INCLUDE_SATURDAY>1</INCLUDE_SATURDAY>
		<LAST_UPDATE>2019-08-05T12:21:43.7450633-06:00</LAST_UPDATE>
		<LAST_UPDATE_BY>gerente@SONDA</LAST_UPDATE_BY>
		<SALE_TYPE>PRE</SALE_TYPE>
		<PERIOD_DAYS>0</PERIOD_DAYS>
		<GOAL_DETAIL>
			<MetaDetalle>
				<GOAL_DETAIL_ID>0</GOAL_DETAIL_ID>
				<GOAL_HEADER_ID>0</GOAL_HEADER_ID>
				<SELLER_ID>0</SELLER_ID>
				<GOAL_BY_SELLER>1250</GOAL_BY_SELLER>
				<DAILY_GOAL_BY_SELLER>54.347826086956521739130434783</DAILY_GOAL_BY_SELLER>
				<CORRELATIVE>3</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<NAME_USER>Soy Gerente!</NAME_USER>
			</MetaDetalle>
			<MetaDetalle>
				<GOAL_DETAIL_ID>0</GOAL_DETAIL_ID>
				<GOAL_HEADER_ID>0</GOAL_HEADER_ID>
				<SELLER_ID>0</SELLER_ID>
				<GOAL_BY_SELLER>1250</GOAL_BY_SELLER>
				<DAILY_GOAL_BY_SELLER>54.347826086956521739130434783</DAILY_GOAL_BY_SELLER>
				<CORRELATIVE>4</CORRELATIVE>
				<LOGIN>marvin@SONDA</LOGIN>
				<NAME_USER>Operador 2</NAME_USER>
			</MetaDetalle>
			<MetaDetalle>
				<GOAL_DETAIL_ID>0</GOAL_DETAIL_ID>
				<GOAL_HEADER_ID>0</GOAL_HEADER_ID>
				<SELLER_ID>0</SELLER_ID>
				<GOAL_BY_SELLER>1250</GOAL_BY_SELLER>
				<DAILY_GOAL_BY_SELLER>54.347826086956521739130434783</DAILY_GOAL_BY_SELLER>
				<CORRELATIVE>14</CORRELATIVE>
				<LOGIN>BRIAN@SONDA</LOGIN>
				<NAME_USER>Brian Morales</NAME_USER>
			</MetaDetalle>
			<MetaDetalle>
				<GOAL_DETAIL_ID>0</GOAL_DETAIL_ID>
				<GOAL_HEADER_ID>0</GOAL_HEADER_ID>
				<SELLER_ID>0</SELLER_ID>
				<GOAL_BY_SELLER>1250</GOAL_BY_SELLER>
				<DAILY_GOAL_BY_SELLER>54.347826086956521739130434783</DAILY_GOAL_BY_SELLER>
				<CORRELATIVE>15</CORRELATIVE>
				<LOGIN>JUAN@SONDA</LOGIN>
				<NAME_USER>Juan Gonzales</NAME_USER>
			</MetaDetalle>
		</GOAL_DETAIL>
	</Meta>
	'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_GOAL_DETAIL] @GOAL XML
AS
BEGIN
    --
    SET NOCOUNT ON;
    --
    DECLARE @INITIAL_DATE AS DATE,
            @END_DATE AS DATE,
            @SELLERS_WITH_GOAL_IN_PROGRESS INT = 0,
            @GOAL_HEADER_ID AS INT;
    --
    DECLARE @GOAL_DETAIL TABLE
    (
        [ID] INT IDENTITY(1, 1),
        [GOAL_HEADER_ID] INT,
        [SELLER_ID] INT,
        [GOAL_BY_SELLER] DECIMAL(18, 6),
        [DAILY_GOAL_BY_SELLER] DECIMAL(18, 6)
    );
    --
    BEGIN TRY
        BEGIN
            -- ---------------------------------------------------------------------------------------
            -- Traemos los datos almacenados para la meta en el encabezado.
            -- ---------------------------------------------------------------------------------------
            SELECT @GOAL_HEADER_ID = [x].[Rec].[query]('./GOAL_HEADER_ID').[value]('.', 'INT'),
                   @INITIAL_DATE = [x].[Rec].[query]('./GOAL_DATE_FROM').[value]('.', 'DATETIME'),
                   @END_DATE = [x].[Rec].[query]('./GOAL_DATE_TO').[value]('.', 'DATETIME')
            FROM @GOAL.[nodes]('Meta') AS [x]([Rec]);

            -- ---------------------------------------------------------------
            -- Limpia los datos existentes para cuando es actualizacion
            -- ---------------------------------------------------------------
            DELETE FROM [SONDA].[SWIFT_GOAL_DETAIL]
            WHERE [GOAL_HEADER_ID] = @GOAL_HEADER_ID;

            -- ---------------------------------------------------------------------------------------
            -- Seleccionamos el numero de vendedores para ese tipo venta y equipo.
            -- ---------------------------------------------------------------------------------------
            INSERT INTO @GOAL_DETAIL
            (
                [GOAL_HEADER_ID],
                [SELLER_ID],
                [GOAL_BY_SELLER],
                [DAILY_GOAL_BY_SELLER]
            )
            SELECT @GOAL_HEADER_ID,
                   [x].[Rec].[query]('./CORRELATIVE').[value]('.', 'INT'),
                   [x].[Rec].[query]('./GOAL_BY_SELLER').[value]('.', 'DECIMAL(18,6)'),
                   [x].[Rec].[query]('./DAILY_GOAL_BY_SELLER').[value]('.', 'DECIMAL(18,6)')
            FROM @GOAL.[nodes]('Meta/GOAL_DETAIL/MetaDetalle') AS [x]([Rec]);

            -- -------------------------------------------------------------------------------------------
            -- Calculamos la cantidad de operadores que se encuentren en una meta y que este en progreso
            -- -------------------------------------------------------------------------------------------
            SELECT @SELLERS_WITH_GOAL_IN_PROGRESS = COUNT([UOT].[SELLER_ID])
            FROM @GOAL_DETAIL AS [UOT]
                INNER JOIN [SONDA].[SWIFT_GOAL_DETAIL] AS [GD]
                    ON [GD].[SELLER_ID] = [UOT].[SELLER_ID]
                INNER JOIN [SONDA].[SWIFT_GOAL_HEADER] AS [GH]
                    ON [GH].[GOAL_HEADER_ID] = [GD].[GOAL_HEADER_ID]
            WHERE [GH].[STATUS] = 'IN_PROGRESS'
                  AND
                  (
                      @INITIAL_DATE
                  BETWEEN [GH].[GOAL_DATE_FROM] AND [GH].[GOAL_DATE_TO]
                      OR @END_DATE
                  BETWEEN [GH].[GOAL_DATE_FROM] AND [GH].[GOAL_DATE_TO]
                  );

            -- -------------------------------------------------------------------------------------------
            -- Verificamos que no existan operadores que se encuentren en una meta en progreso
            -- -------------------------------------------------------------------------------------------
            IF (@SELLERS_WITH_GOAL_IN_PROGRESS > 0)
            BEGIN
                RAISERROR('Uno de los operadores ya se encuentra en cumplimiento de una meta', 16, 1);
            END;
            ELSE
            BEGIN
                -- -------------------------------------------------------------------------------------------
                -- Insertamos el operador con los datos de la meta respectiva
                -- -------------------------------------------------------------------------------------------
                INSERT INTO [SONDA].[SWIFT_GOAL_DETAIL]
                (
                    [GOAL_HEADER_ID],
                    [SELLER_ID],
                    [GOAL_BY_SELLER],
                    [DAILY_GOAL_BY_SELLER]
                )
                SELECT [GOAL_HEADER_ID],
                       [SELLER_ID],
                       [GOAL_BY_SELLER],
                       [DAILY_GOAL_BY_SELLER]
                FROM @GOAL_DETAIL
                WHERE [ID] > 0;
            END;

            -- -----------------------------------------------------------
            -- Se devuelve resultado positivo
            -- -----------------------------------------------------------
            SELECT 1 AS [Resultado],
                   'Proceso Exitoso' [Mensaje],
                   0 [Codigo],
                   '0' [DbData];
        END;
    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@ERROR [Codigo];
    END CATCH;
END;

