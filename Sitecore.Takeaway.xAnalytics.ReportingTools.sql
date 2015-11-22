DECLARE	@ID uniqueidentifier
DECLARE	@Name varchar(max)

DECLARE @DropReportView varchar(max)
DECLARE @ReportView varchar(max)

SET @DropReportView = N'
IF OBJECT_ID(''@Name'', ''V'') IS NOT NULL
    DROP VIEW @Name'

SET @ReportView = N'
CREATE VIEW @Name AS
WITH ReportData AS
(
SELECT	dbo.Fact_SegmentMetrics.SegmentRecordId
		, dbo.Fact_SegmentMetrics.ContactTransitionType
		, dbo.Fact_SegmentMetrics.Visits
		, dbo.Fact_SegmentMetrics.Value
		, dbo.Fact_SegmentMetrics.Bounces
		, dbo.Fact_SegmentMetrics.Conversions
		, CAST(dbo.Fact_SegmentMetrics.TimeOnSite AS [BigInt]) AS TimeOnSite
		, dbo.Fact_SegmentMetrics.Pageviews
		, dbo.Fact_SegmentMetrics.Count
		, dbo.SegmentRecords.SegmentId
		, dbo.SegmentRecords.Date
		, dbo.SegmentRecords.SiteNameId
		, dbo.SegmentRecords.DimensionKeyId
		, dbo.DimensionKeys.DimensionKey
FROM    dbo.Fact_SegmentMetrics INNER JOIN
		dbo.SegmentRecords ON dbo.Fact_SegmentMetrics.SegmentRecordId = dbo.SegmentRecords.SegmentRecordId INNER JOIN
		dbo.DimensionKeys ON dbo.SegmentRecords.DimensionKeyId = dbo.DimensionKeys.DimensionKeyId
WHERE	SegmentId = ''@ID''
UNION 
SELECT	dbo.Fact_SegmentMetricsReduced.SegmentRecordId
		, dbo.Fact_SegmentMetricsReduced.ContactTransitionType
		, dbo.Fact_SegmentMetricsReduced.Visits
		, dbo.Fact_SegmentMetricsReduced.Value
		, dbo.Fact_SegmentMetricsReduced.Bounces
		, dbo.Fact_SegmentMetricsReduced.Conversions
		, CAST(dbo.Fact_SegmentMetricsReduced.TimeOnSite AS [BigInt]) AS TimeOnSite
		, dbo.Fact_SegmentMetricsReduced.Pageviews
		, dbo.Fact_SegmentMetricsReduced.Count
		, dbo.SegmentRecordsReduced.SegmentId
		, dbo.SegmentRecordsReduced.Date
		, dbo.SegmentRecordsReduced.SiteNameId
		, dbo.SegmentRecordsReduced.DimensionKeyId
		, dbo.DimensionKeys.DimensionKey
FROM    dbo.Fact_SegmentMetricsReduced INNER JOIN
        dbo.SegmentRecordsReduced ON dbo.Fact_SegmentMetricsReduced.SegmentRecordId = dbo.SegmentRecordsReduced.SegmentRecordId INNER JOIN
        dbo.DimensionKeys ON dbo.SegmentRecordsReduced.DimensionKeyId = dbo.DimensionKeys.DimensionKeyId
WHERE	SegmentId = ''@ID''
)
, MasterItems AS
(
SELECT	ID
		, Name
		, TemplateID
		, ParentID
FROM	scEsplanade_master.dbo.Items
)
, DimensionItems AS
(
SELECT	DimensionKeyId
		, LOWER(DimensionKey) AS DimensionKey
		, COALESCE(i.Name COLLATE DATABASE_DEFAULT, LOWER(dk.DimensionKey)) AS SegmentValue
		, t.Name
FROM	DimensionKeys dk LEFT OUTER JOIN
		MasterItems i ON dk.DimensionKey = CONVERT(varchar(max), i.ID) LEFT OUTER JOIN
		MasterItems t ON i.TemplateID = t.ID 
)
SELECT	d.SegmentRecordId
		, d.ContactTransitionType
		, d.Visits
		, d.Value
		, d.Bounces
		, d.Conversions
		, d.TimeOnSite
		, d.Pageviews
		, d.Count
		, d.SegmentId
		, d.Date
		, d.SiteNameId
		, d.DimensionKeyId
		, d.DimensionKey
		, dfi.Name AS DimensionGroup
		, di.Name AS Dimension
		, si.Name AS Segment
		, dk.Name AS Template
		, dk.SegmentValue
FROM	ReportData d INNER JOIN
		Segments s ON d.SegmentId = s.SegmentId INNER JOIN
		MasterItems di ON s.DimensionId = di.ID INNER JOIN
		MasterItems si ON s.SegmentId = si.ID INNER JOIN
		MasterItems dfi ON di.ParentID = dfi.ID INNER JOIN
		DimensionItems dk ON d.DimensionKeyId = dk.DimensionKeyId
'

DECLARE Segment_Cursor CURSOR FOR
SELECT	DISTINCT
		ID
		, '[Fact ' + Name + ']' AS Name
FROM	scEsplanade_master.dbo.Items i INNER JOIN
		Segments s ON i.ID = s.SegmentId

OPEN Segment_Cursor

FETCH NEXT FROM Segment_Cursor
INTO	@ID
		, @Name

WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @ExecuteDropReportView varchar(max)
DECLARE @ExecuteReportView varchar(max)

SET @ExecuteDropReportView = @DropReportView 
SET @ExecuteDropReportView = REPLACE(@ExecuteDropReportView,'@Name', @Name)

SET @ExecuteReportView = @ReportView 
SET @ExecuteReportView = REPLACE(@ExecuteReportView,'@Name', @Name)
SET @ExecuteReportView = REPLACE(@ExecuteReportView,'@ID', @ID)

EXECUTE(@ExecuteDropReportView)

EXECUTE(@ExecuteReportView)


FETCH NEXT FROM Segment_Cursor 
INTO	@ID
		, @Name

END

CLOSE Segment_Cursor;
DEALLOCATE Segment_Cursor;



