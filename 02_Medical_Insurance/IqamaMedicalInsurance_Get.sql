USE [VISA]
GO

/****** Object:  StoredProcedure [dbo].[IqamaMedicalInsurance_Get]    Script Date: 07-01-2023 06:47:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[IqamaMedicalInsurance_Get]
AS
BEGIN
	select vt.fkc_EmployeeId as psno, 
	vt.pkc_VisaId as visaNo,
	ve.c_EmployeeFullName as fullName, 
	iqmi.c_Class as class, 
	iqmi.c_PolicyNumber as policyNo, 
	iqmi.c_Relation as relation, 
	iqmi.c_HealthDeclaration as healthDeclaration, 
	iqmi.d_From as effectiveDate, 
	iqmi.d_To as memberExpDate, 
	LTRIM( RTRIM( vs.c_StageId)) as stageid,
	LTRIM( RTRIM( vs.c_SubStageId)) as substageid

	from dbo.t_Visa vt LEFT JOIN dbo.t_IqamaMedicalInsurance iqmi ON vt.pkc_VisaId = iqmi.pkc_VisaId
	LEFT JOIN dbo.t_VisaEmployee ve ON vt.fkc_EmployeeId = ve.pkc_EmployeeId
	INNER JOIN dbo.t_VisaStage vs ON vt.pkc_VisaId = vs.pkc_VisaId where vs.c_StageId = 'MDIN'; 

	
END
GO


