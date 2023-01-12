USE [VISA]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[IqamaMed_UP]
		@visa_Id = 23654171,
		@entryDate = N'2023-01-10T00:00:00.000Z',
		@expDate = N'2024-01-09T00:00:00.000Z',
		@borderno =  N'123456',
		@iqamaDate = N'2022-09-12T18:30:00.000Z',
		@iqama_ExpiryDate = N'2022-09-12T18:30:00.000Z',
		@remarks = N'2022-09-13T18:30:00.000Z',
		@status = N'OK',
		@createdBy = N'co',
		@p_attachment = N'system',
		@existing_stage_id		= N'IQMD',
		@existing_substage_id		= N'1',
		@new_stage_id				= N'MDIN',
		@new_substage_id			= N'1'

SELECT	'Return Value' = @return_value

GO

