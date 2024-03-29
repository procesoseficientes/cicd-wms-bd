﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/4/2018 @ GFORCE-Team Sprint Elefante
-- Description:			Actualiza la foto de un usuario desde Sonda Super

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_USER_PICTURE]
					@LOGIN = 'rudi@SONDA',
					@IMAGE = 'data:image/png;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCABkAGQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3+ivFNF/aK0i8uli1TTJbJGOBIr7wPrXsWn6haarYQ31jOk9tMu6ORDkEUAWaK47xf8S/Dvg0GO+uvMu+1tF8z/j6V5pL+0mnmsIfDzNGD8pM+CR+VAHvlFeC237ScDXCLdaA8cRPzMs2SPwxXrfhXxjo/jHTvtmk3IfbxJGeHQ+4oA36K8/+JPxNj+Hz2KHTzeNdAnAk27QK4L/hpWP/AKF1v+//AP8AWoA99orL8O63b+I9BtNVtuI7iMNtznae4rznxz8bI/Bvim40X+yDdeSiMZRNjJIzjGO1AHrVFcr4I8YN4v8ACn9tvZGzG5wIy+7IXvmvMrv9o6O1vJ7f/hH2bypCm7zxzg4z0oA93orwP/hpSP8A6F1/+/8A/wDWooA6PTPgv4BvLYSWsjXaNyHWYHj8K3dUTT/hT8Ob9tLD7ItzQpI2fnbp+FfKWieJtY8PXkd1pl/NA6EHAb5T7EV7v8SNXvfFHwJ03WWj2STlJJlUcdSD+HFAHg9tFf8AivxJHE8zS3l9MAZH55J619f+Ffh9oPhfSYbWGwglmCDzZpEDM7d+tfLXwvuLe1+IukS3LqkYmAy3QE9K+0OoyKAPCPj74M0y30G312wtIbaeKXy5vLXG9T04+tedfBbV7nTPiNYxRO3k3WYpUB4YY4/WvRv2ivEcK6ZYaDBMrTvJ5s6A5KqOmfxrg/gboU+qfEG3vBGTb2KmSRiOM4wBn1oA2f2ir5pvFtjaZ+WG3yB9TXl02gXcPhyDXDg2s0xhHHRhXY/G6/N58Sr2MnIt1WMflXoPhrwkviL9nX7Oif6TuluYjjnKsf6CgCH9nfxWWW88M3Dk4/f25J6D+IfrmvLfihdte/EfWnJztnMY/Dis/wAH6/L4V8V2epgsvkPiRe5HQiq2tXq6v4ou71Mlbm5Lj8TQB9ReEEXSvgjE5+QixZ2+pFfJ8StdaiinlpZQD+Jr6v8AGj/2T8D51jPlstiiKPc4r5i8IWR1LxfpNmFLGW5QYHfmgD690zwR4ej0q0SbRrNpFhUMTGMk4orp1G1FX0GKKAPnXwn+z1fPeRXPiS6iit1OWtoTuZ/Tnpivdr3w5pl94ck0GS3Uae0PkiNRjaO2K5JfiRfbRu8M6jnviM08fEi4H+s8OainpmM1v9Wqdjn+tUu54t4o+BfiXRr15NHUX9puzGyNh1HbI9auWup/GKys/wCzI4r04XarMgLKPY16+vxJOfm0HUAvc+Wad/wsy3/6BN9/37NH1er2H9ZpdzxDTPgz428UambrWD9lErZluLl9zH8K+hvBfgvTfBOirYWC7nb5ppmHzSN6msz/AIWbpveyvAfTZSj4naNj5orlW7gp0pfV6v8AKP6xS/mPB/GvgHxlrnjDVNSTRpnjlmJRh3UcA19GeBdHfQ/BOl6dNHskjgHmIezHkis5fiZoTDJMy/VKkT4k+HmB3XDpj1Wl7Cp/Kw+sUv5keGfET4Sa6vjK8m0PTWnsbhvNUx/wk8kfnXP6Z8KvGA1WzMujTLGJkLscYAyM19Mp8Q/Djrn7YR7bTUyeO/Drrn+0FHsVNL2NT+VlKtTf2kc58YtH1TVfASabo1q9xK06KyJ2QA//AFq8D074c+PtJ1CC/sdJuIbqB98ci4yp9a+pk8YaDIQF1GLn1OKsR+I9GkB26lbcesgFL2c10GqkH1Pnsv8AGzP+sv8A/wAdor6K/trSv+glZ/8Af9f8aKXLLsPnj3L1FFFSUJtBGCB+VN8mL/nkn/fIp9FAEJtLYnJt4j/wAUw6fZHraW5z/wBMx/hVmindisig+i6ZIMNYW5/4AKrv4Y0WTO7ToDn/AGa16KfPLuLkj2Ofk8E+H5eunoP93iqUvw48Oyk/6Ky/RzXW0VSq1Fs2S6NN7xRwkvwr0V/uTTx/TBrOm+EcP/LDUmP/AF0Qf0r0yirWJqrqZvC0X9k8if4Salu+S9sCv+0jZor12ir+uVe5H1Gj2CiiiuU6wooooAKKKKACiikLKoyxAHuaAFoqlc6xptom6e+gQD1cVi3Pj/w/BxHdNcH0iQmrjTnLZESqQjuzp6K4Gb4jyykrp2i3UzdiyECqE2rfEHVDi3077HE3faD+vWtFh59bL1MniYfZu/RHpmQOpFFeUnwd42uT5sup4Y9jOaKr2EP50T9Yn/Iz1eiiiuY6gpCSBwMmlooApSSaiCfLt4CO2ZD/AIVC8OrzdLqG39lj3/zrToquYnlMZtI1CU/vdZlx3CRhagbwlaSnM15fSDupnODXQUU/aSWwvZxe5gxeDNAhbcNPjZj1Lck1oxaRp0OPLsoFx6IKu0UnOT3Y1CK2QioqDCqFA7AUtFFSUFFFFACUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf//Z'

				SELECT IMAGE FROM SONDA.USERS WHERE LOGIN = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_USER_PICTURE]
    (
     @LOGIN VARCHAR(50)
    ,@IMAGE VARCHAR(MAX)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    BEGIN TRY
        UPDATE
            [SONDA].[USERS]
        SET
            [IMAGE] = @IMAGE
        WHERE
            [LOGIN] = @LOGIN;
		--
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,'' [DbData];
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,CASE CAST(@@ERROR AS VARCHAR)
              WHEN '2627' THEN ''
              ELSE ERROR_MESSAGE()
            END [Mensaje]
           ,@@ERROR [Codigo]; 
    END CATCH;
END;
