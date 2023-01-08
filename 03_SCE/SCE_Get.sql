USE [VISA]
GO

/****** Object:  StoredProcedure [dbo].[SCE_Get]    Script Date: 07-01-2023 07:50:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SCE_Get]
AS
BEGIN
	select vt.fkc_EmployeeId as psno, 
	vt.pkc_VisaId as visaNo, 
	ve.c_EmployeeFullName as fullName, 
	sce.c_RegistrationType as regType, 
	sce.c_Profession as profession, 
	sce.c_CurrentStatus as  CurrentStatus,
	sce.c_CurrentStatusValue as CurrentStatusValue ,
	sce.c_bill_processing as bill_processing, 
	LTRIM( RTRIM( vs.c_StageId)) as stageid,
	LTRIM( RTRIM( vs.c_SubStageId)) as substageid


	from dbo.t_Visa vt LEFT JOIN dbo.SCE sce ON vt.pkc_VisaId = sce.pkc_VisaId
	LEFT JOIN dbo.t_VisaEmployee ve ON vt.fkc_EmployeeId = ve.pkc_EmployeeId
	INNER JOIN dbo.t_VisaStage vs ON vt.pkc_VisaId = vs.pkc_VisaId where vs.c_StageId = 'SCE';
END
GO


