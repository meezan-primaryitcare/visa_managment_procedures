USE [VISA]
GO

/****** Object:  StoredProcedure [dbo].[IqamaMedical_Get]    Script Date: 08-01-2023 11:29:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[IqamaMedical_Get]
AS
BEGIN
	select vt.fkc_EmployeeId as psno, 
	vt.pkc_VisaId as visaNo, 
	--vt.c_VisaNo as visaNo, 
	vt.fkc_EmployeeId as EmployeeId, 
	ve.c_EmployeeFullName as fullName, 
	vt.c_ActualEntryDate as entryDate, 
	ti.c_TripEndTimeActual as expDate, 
	vt.c_BorderNo, 
	iqm.d_From iqamaDate, 
	iqm.d_To as iqamaExpDate, 
	iqm.c_Status as iqamastatus, iqm.c_Remarks as remarks,
	LTRIM( RTRIM( vs.c_StageId)) as stageid,
	LTRIM( RTRIM( vs.c_SubStageId)) as substageid

	from dbo.t_IqamaMedical iqm 
	LEFT JOIN dbo.t_Visa vt ON vt.pkc_VisaId = iqm.pkc_VisaId
	LEFT JOIN dbo.t_TripInfo ti ON vt.pkc_VisaId = ti.fkc_VisaId 
	Left JOIN t_VisaEmployee ve ON vt.fkc_EmployeeId = ve.pkc_EmployeeId
	INNER JOIN dbo.t_VisaStage vs ON vt.pkc_VisaId = vs.pkc_VisaId where vs.c_StageId = 'IQMD' and vs.d_ActiveFlg = 1; 

END
GO

IqamaMedical_Get
