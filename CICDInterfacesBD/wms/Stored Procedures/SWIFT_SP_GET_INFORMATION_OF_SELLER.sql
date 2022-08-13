
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	24-Jul-2018 @ G-Force Team Sprint FocaMonje
-- Description:			SP que obtiene la informacion del vendedor.
/*
-- Ejemplo de Ejecucion:
				DECLARE @DOC_NUM INT =-1
				--
				EXEC [wms].[SWIFT_SP_GET_INFORMATION_OF_SELLER]				
					@DOC_NUM = '19295, 162'
				--
				SELECT @DOC_NUM
*/
-- =============================================
CREATE PROCEDURE [wms].[SWIFT_SP_GET_INFORMATION_OF_SELLER] (@DOC_NUM VARCHAR(MAX))
AS
BEGIN
  SET NOCOUNT ON;
  --

  DECLARE @QUERY NVARCHAR(2000)

  SELECT
    @QUERY = N'SELECT
      a.docnum [DOC_NUM]
     ,b.slpname [SELLER]
     ,c.trnspname [TRNSP_NAME]
     ,a.comments [COMMENTS]
     ,e.pymntgroup [PYMNT_GROUP]
     ,f.u_branchname AS [BRANCH_NAME]    
    FROM [SBOwms].[dbo].ORDR a
    INNER JOIN [SBOwms].[dbo].rdr1 a1
      ON a.docentry = a1.docentry
    INNER JOIN [SBOwms].[dbo].oslp b
      ON a.slpcode = b.slpcode
    INNER JOIN [SBOwms].[dbo].oshp c
      ON a.trnspcode = c.trnspcode
    INNER JOIN [SBOwms].[dbo].ocrd d
      ON a.cardcode = d.cardcode
    INNER JOIN [SBOwms].[dbo].octg e
      ON d.groupnum = e.groupnum
    INNER JOIN [SBOwms].[dbo].[@SUCURSAL_CCOSTO] f
      ON a.u_sucursal = f.name
    WHERE a.docnum IN (' + @DOC_NUM + ')'
  --

  SET @QUERY = N'SELECT * FROM OPENQUERY ([SAPSERVER], ''' + @QUERY + ''')'

  PRINT @QUERY

  EXEC sp_executesql @QUERY


END
  


