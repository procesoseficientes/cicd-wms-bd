





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_AUDIT_RECEPTION_SERIAL]
(	
	@pSINCE_DATE	DATETIME,
	@pTO_DATE		DATETIME
)
RETURNS TABLE 
AS
RETURN 
(

SELECT 
	AUDIT_ID,
	MATERIAL_ID,
	SERIAL_NUMBER AS Serial 
FROM 
	[wms].OP_WMS_AUDIT_RECEPTION_SERIES A
WHERE 
	A.MATERIAL_ID IN (
		 SELECT A.MATERIAL_ID
		 FROM [wms].OP_WMS_AUDIT_RECEPTION_SKUS A
		 WHERE A.LAST_UPDATED >= @pSINCE_DATE AND A.LAST_UPDATED <= @pTO_DATE
	)
)