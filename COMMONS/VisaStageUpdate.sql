USE [VISA]
GO

/****** Object:  StoredProcedure [dbo].[Location_UP]    Script Date: 07-01-2023 09:33:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[VisaStageUpdate]
(
		 
		 @visa_id					bigint,
		 @existing_stage_id			char(10),
		 @existing_substage_id		char(10),
		 @new_stage_id				char(10),
		 @new_substage_id			char(200)
) as 


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
			set @Success_Message = 'Details updated for visa no : ' + CAST( @visa_id as varchar(20))+'.';

			
			insert into [dbo].t_VisaStage(pkc_VisaId,c_StageId,c_SubStageId,d_createdBy)
			values(@visa_id,@new_stage_id,@new_substage_id,'SYSTEM');

			
			IF EXISTS(SELECT * FROM [dbo].[t_VisaStage] WHERE dbo.t_VisaStage.pkc_VisaId = @visa_id)
			begin
				update [dbo].[t_VisaStage]
				set 
					 d_ActiveFlg		= 0
					,d_To				= CURRENT_TIMESTAMP  
				where  dbo.t_VisaStage.pkc_VisaId = @visa_id and LTRIM( RTRIM(dbo.t_VisaStage.c_StageId)) = @existing_stage_id and LTRIM( RTRIM(dbo.t_VisaStage.c_SubStageId)) = @existing_substage_id;

			end


			insert into dbo.AuditLog
				([AppName],CallingFunction,[URL],[Body],[Error],[Timestamp])

				select 
					 'visa'
					,'stageUpdate'
					,'SQL'
					,''
					,@Err_flg + '-'+ @Success_Code + '-'+@Success_Message
					,CURRENT_TIMESTAMP;

				select 
						@Err_flg	Err_flg	 
					,coalesce(@SQL_Err_Code   , @Err_Code	 ,@Success_Code	   ) Err_Code	 
					,coalesce(@SQL_Err_Message, @Err_Message ,@Success_Message ) Err_Message

			
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
				 'visa'
				,'StageUpdate'
				,'SQL'
				,''
				,@Err_flg + '-'+ @Success_Code + '-'+@Success_Message
				,CURRENT_TIMESTAMP
				
			;
		select 
	 @Err_flg	Err_flg	 
	,coalesce(@SQL_Err_Code   , @Err_Code	 ,@Success_Code	   ) Err_Code	 
	,coalesce(@SQL_Err_Message, @Err_Message ,@Success_Message ) Err_Message

end catch

END
GO







