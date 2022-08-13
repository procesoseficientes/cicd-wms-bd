CREATE PROCEDURE [wms].[OP_WMS_SP_GET_query]
	@License varchar(25)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT MATERIAL_ID,MATERIAL_NAME,LICENSE_ID FROM OP_WMS_INV_X_LICENSE
	where LICENSE_ID=@License
/**	WHERE 	MATERIAL_NAME= @License **/
	--31/May/11 J.R. para que haya tope al dar Next Bin, solo se libera el bin para el sig.usuario cuando el ant.usuario lo termino de llenar
/**	AND BIN_RELEASED = 'S'
	ORDER BY DATETIME_PASSED
	**/
--07-Abr-11 J.R. se usa de otra forma ahora se obtiene solo de la tabla ctrl_bin_pass
--select	
--		A.ASSIGNED_DATE,
--		A.bin_target, 
--		A.ERP_LEGACY_ID 
--from	OP_WMS_TASK_LIST A
--where	A.IS_COMPLETED2 = 0 AND
--		A.IS_COMPLETED = 0 AND --06-Abr-11 trae todas las tareas incluso las ya completadas.
--		A.IS_CANCELED = 0 AND 
--		A.IS_PAUSED = 0 AND
--		A.TASK_ASSIGNEDTO = @pLoginID AND
--		A.ERP_LEGACY_ID NOT IN 
--			(SELECT B.ERP_LEGACY_ID FROM OP_WMS_CTRL_BIN_PASSING B WHERE B.TASK_ASSIGNEDTO = A.TASK_ASSIGNEDTO)
			
--group by
--		A.ASSIGNED_DATE, 
--		BIN_TARGET, 
--		ERP_LEGACY_ID

					
		
END