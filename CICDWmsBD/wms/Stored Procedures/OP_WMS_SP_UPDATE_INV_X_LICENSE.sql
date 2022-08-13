
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Resta el inventario de la tabla inv_x_licencia
/*
-- Ejemplo de Ejecucion:				
				--
				exec [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE] 
							@QTY ='75'
							,@Code_sku ='110017' 
							,@CUSTOMER ='C00330'
							,@RESULTADO =''
				--				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE]
   @QTY AS INT
  ,@Code_sku as varchar(100) 
  ,@CUSTOMER as varchar(100)
  ,@RESULTADO AS VARCHAR(150) output 
AS
	  
	  DECLARE 
	          @ACTUAL AS INT
			  ,@ERROR AS VARCHAR(150)
			  ,@Disponible int
			  ,@TOTAL AS INT
			  ,@LICENCIA AS INT
			  ,@Registro int =0
			  ,@codigo as varchar(100)= @CUSTOMER+'/'+@Code_sku

	  SELECT @TOTAL = SUM(QTY)
      FROM [wms].[OP_WMS_INV_X_LICENSE]
      where  MATERIAL_ID=@Codigo
	  --SELECT @TOTAL TOTAL

	  SELECT top 1 @Registro= 1
      FROM [wms].[OP_WMS_INV_X_LICENSE]
      where  MATERIAL_ID=@Codigo

	  if(@Registro=0)
	  begin
	  SET @RESULTADO = 'EL CODIGO -> ' +@Codigo+ ' <- NO EXISTE ' SELECT @RESULTADO AS RESULTADO
	  end
	  ELSE
	  BEGIN

	 IF(@TOTAL>= @QTY)
	  BEGIN
	 -- SET @RESULTADO = 'SI CUBRE' SELECT @RESULTADO AS RESULTADO

		 WHILE @QTY>0
		 BEGIN
		        --OBTIENE EL VALOR TOTAL DE LA LICENCIA
				SELECT TOP 1 @ACTUAL = (QTY)
				FROM [wms].[OP_WMS_INV_X_LICENSE]
				where  MATERIAL_ID=@Codigo
				AND QTY>0
				--SELECT @ACTUAL LICENCIA_A_RESTAR

				--OBTIENE LA LICENCIA A RESTAR
				SELECT TOP 1 @LICENCIA = LICENSE_ID
				FROM [wms].[OP_WMS_INV_X_LICENSE]
				where  MATERIAL_ID=@Codigo
				AND QTY>0
				
				--SELECT @LICENCIA AS LICENCIA_NUMERO
				         --RESTA TODA LA LICENCIA, SI ES MAYOR LA SALIDA
						 IF(@ACTUAL<@QTY) 
						 BEGIN

							 SET @QTY= @QTY - @ACTUAL
							-- SELECT @QTY RESTANTE_RESTANTE_RESTANTE
					
								  UPDATE [wms].[OP_WMS_INV_X_LICENSE] 
								  SET  QTY= 0
								  ,ENTERED_QTY=@QTY
								  where MATERIAL_ID = @Codigo
								  AND LICENSE_ID = @LICENCIA
						 END
							 ELSE  
							 --SELECT @QTY EEEEEEEE
							 BEGIN  UPDATE [wms].[OP_WMS_INV_X_LICENSE] 
									  SET  QTY=  QTY-@QTY
									  where MATERIAL_ID = @Codigo
									  AND LICENSE_ID = @LICENCIA
									  SET @RESULTADO = 'EL CODIGO -> ' +@Codigo+ ' <- Actualizado correctamente' SELECT @RESULTADO AS RESULTADO
									  RETURN
							 END
			END
    END
	ELSE 
			   BEGIN
			 SET @RESULTADO = 'EL CODIGO -> ' +@Codigo+ ' <- NO CUBRE LA CANTIDAD A RESTAR' SELECT @RESULTADO AS RESULTADO
			   END

END