USE [VISA]
GO

/****** Object:  StoredProcedure [dbo].[IqamaMed_UP]    Script Date: 08-01-2023 11:30:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[IqamaMed_UP]
	(
		 @visa_Id					bigint,

		 @entryDate					datetime,
		 @expDate					datetime,

		 @borderno					varchar(50),

		 @iqamaDate					datetime,
		 @iqama_ExpiryDate			datetime,
		 
		 @remarks					varchar(max),
		 @status					char(2),
		 @createdBy					varchar(200),
		 
		 @p_attachment				varchar(max),

		 @existing_stage_id			char(10),
		 @existing_substage_id		char(10),
		 @new_stage_id				char(10),
		 @new_substage_id			char(200)
	)
AS
BEGIN

declare @Err_flg			char(1)		 = '';
declare @Err_Code			varchar(20)	 = null ;
declare @Err_Message		varchar(max) = null ;
declare @Success_Code		varchar(20)  = null ;
declare @Success_Message	varchar(max) = null ;
declare @SQL_Err_Code		varchar(20)	 = null ;
declare @SQL_Err_Message	varchar(max) = null ;



SET NOCOUNT ON;

begin try

	 begin transaction t1
			BEGIN
			set @Err_flg		 = 'S';
			set @Success_Code	 = '204';
			set @Success_Message = 'Iqama Details updated for Visa no: ';

			IF EXISTS(SELECT * FROM [dbo].[t_IqamaMedical] WHERE dbo.t_IqamaMedical.pkc_VisaId = @visa_Id  )
			begin
				update [dbo].[t_IqamaMedical]
				set c_Remarks			= @remarks
					,c_Status			= @status
					,d_From				= @iqamaDate
					,d_To				= @iqama_ExpiryDate
					,d_createdBy		= @createdBy
				where  dbo.t_IqamaMedical.pkc_VisaId = @visa_Id;

				-- Update Entry Date
				update dbo.t_Visa
				set c_ActualEntryDate	=  @entryDate,
				    c_BorderNo			= @borderno
				where  dbo.t_Visa.pkc_VisaId = @visa_Id;

				-- Update Exit Date
				update dbo.t_TripInfo
				set c_TripEndTimeActual	=  @expDate
				where  dbo.t_TripInfo.fkc_VisaId = @visa_Id;

				

			end
			else
			begin
				INSERT INTO [dbo].[t_IqamaMedical]
				   (
						[pkc_VisaId]
					   ,[c_Remarks]
					   ,[c_Status]
					   ,[d_From]
					   ,[d_To]
					   ,[d_createdBy]
					)
							
				VALUES
					(
						@visa_Id
					   ,@remarks
					   ,@status
					   ,@iqamaDate
					   ,@iqama_ExpiryDate
					   ,@createdBy
					   
					)

				-- Update Entry Date
				update dbo.t_Visa
				set c_ActualEntryDate	=  @entryDate, 
					c_BorderNo			= @borderno
				where  dbo.t_Visa.pkc_VisaId = @visa_Id;

				-- Update Exit Date
				update dbo.t_TripInfo
				set c_TripEndTimeActual	=  @expDate
				where  dbo.t_TripInfo.fkc_VisaId = @visa_Id;
			end

			insert into ref.r_document
			(pkc_EmployeeId,pkc_VisaId,fkc_DocumentType,c_DocumentName,c_DocumentURL,d_createdBy,d_From,d_To)
				select 
				'',
				@visa_Id,
				dbo.SplitIndex ('~',value,3) ,
				dbo.SplitIndex ('~',value,2) ,
				dbo.SplitIndex ('~',value,1) ,
				@createdBy,
			    CONVERT(varchar(20),CURRENT_TIMESTAMP,23),
			   '9999-12-31'

				from  
				 (SELECT Split.a.value('.', 'NVARCHAR(MAX)') value
					FROM
					(
 
						SELECT CAST('<X>'+REPLACE(@p_attachment, '|', '</X><X>')+'</X>' AS XML) AS String
					) AS A
					CROSS APPLY String.nodes('/X') AS Split(a))ref
				where dbo.SplitIndex ('~',value,3) is not null;

			EXEC [dbo].[VisaStageUpdate]
				 @visa_Id,
				 @existing_stage_id,
				 @existing_substage_id,
				 @new_stage_id, 
				 @new_substage_id	

			-- Send to Medical Insurance
				EXEC [dbo].[IqamaMedicalInsurance_UP]
				@visaID = 23654171,
				@class = NULL,
				@policyNo = NULL,
				@relation = NULL,
				@healthDeclaration = NULL,
				@createdBy = 'SYSTEM',
				@effectiveDate = '2022-09-10 00:00:00.000',
				@memberExpDate = '2023-09-10 00:00:00.000',
				@renew = NULL


			insert into dbo.AuditLog
			([AppName],CallingFunction,[URL],[Body],[Error],[Timestamp])

			select 
				 'iqama medical','IqamaMed_UP','SQL',''
				,@Err_flg + '-'+ @Success_Code + '-'+@Success_Message
				,CURRENT_TIMESTAMP
				;
	

				select 
					 @Err_flg	Err_flg	 
					,coalesce(@SQL_Err_Code   , @Err_Code	 ,@Success_Code	   ) Err_Code	 
					,coalesce(@SQL_Err_Message, @Err_Message ,@Success_Message ) Err_Message;

				SELECT [pkc_VisaId]
				  ,[pkc_SrNo]
				  ,[c_Remarks]
				  ,[c_Status]
				  ,[d_createdBy]
				  ,[d_From]
				  ,[d_To]
				  ,[d_ActiveFlg]
			  FROM [dbo].[t_IqamaMedical] WHERE dbo.t_IqamaMedical.pkc_VisaId = @visa_Id

			  SELECT *
			  FROM [ref].[r_Document] 
					

		END
	 commit transaction t1
end try

begin catch
	rollback transaction t1;

	set @Err_flg			=	'E';
	set @SQL_Err_Code		=	cast(ERROR_NUMBER() as varchar(20)) ; 
	set @SQL_Err_Message	=	'Error State: '+ cast(ERROR_STATE() as varchar(20))+
								' | Error Severity: '+ cast(ERROR_SEVERITY() as varchar(20))+ 
								' | Error Message: ' + cast(ERROR_MESSAGE()  as varchar(max)) +
								' | Possible Error at Line Number: ' + cast(ERROR_LINE() as varchar(20)) 
								; 
insert into dbo.AuditLog
			([AppName],CallingFunction,[URL],[Body],[Error],[Timestamp])

	select 
	 'iqama medical'
	,'IqamaMed_UP'
	,'SQL'
	,''
	,@Err_flg+ '-'+@SQL_Err_Code+ '-'+@SQL_Err_Message
	,CURRENT_TIMESTAMP
	;
	
	

	select 
	 @Err_flg	Err_flg	 
	,coalesce(@SQL_Err_Code   , @Err_Code	 ,@Success_Code	   ) Err_Code	 
	,coalesce(@SQL_Err_Message, @Err_Message ,@Success_Message ) Err_Message


end catch
END
GO


