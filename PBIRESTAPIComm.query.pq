// Use this file to write queries to test your data connector
let
    /*** TEST VARIABLES***/
    AppTestID = "{INSERT APP ID}",
    GroupTestID = "{INSERT GROUP ID}",
    DatasetTestID = "{INSERT DATASET ID}",
    ReportTestID = "{INSERT REPORT ID}",

    Query = "DEFINE
	// Pick a static date(s)
	VAR __January2011 = DATE(2011,1,1)
    VAR __January2011Filter = TREATAS({__January2011}, 'DateDim'[Date])
	VAR __BlankDayFilter = TREATAS({0},'DateDim'[DateID])
	/* Check for blank date */
	VAR _Date_Dim_Blank_Format = CALCULATE(MIN('DateDim'[Month Year]),__BlankDayFilter)
	VAR _Date_Dim_NonBlank_Format = CALCULATE(MAX('DateDim'[Month Year]),__January2011Filter)
	
/*Run Tests*/
VAR _Tests = 
UNION(
ROW(
	""TestName"", ""Calculated Column: Month Year column should be blank when no date (1/1/0001) is selected."", 
	""ExpectedValue"", ""Not Available"",
	""ActualValue"", _Date_Dim_Blank_Format
),
ROW(
	""TestName"", ""Calculated Column: Month Year column should be Jan-11 when filtered by January 1, 2011."", 
	""ExpectedValue"", _Date_Dim_NonBlank_Format,
	""ActualValue"", ""Jan-11""
)
)

/*Output Pass/Fail*/
EVALUATE ADDCOLUMNS(_Tests,""Passed"",[ExpectedValue] = [ActualValue])",

    /*** End TEST VARIABLES***/

    Source = NavigationTable.Simple(),
    /* Apps */
    GetApp = Source{[Key="GetApp"]}[Data],
    GetAppResult = GetApp(AppTestID),

    GetApps = Source{[Key="GetApps"]}[Data],
    GetAppsResult = GetApps(),    

    /* Datasets */
    GetDatasetsInGroup = Source{[Key="GetDatasetsInGroup"]}[Data],
    GetDatasetsInGroupResult = GetDatasetsInGroup(GroupTestID),
    DatasetsJson = Json.Document(GetDatasetsInGroupResult)[value],
    DatasetsTable = Table.FromList(ReportsJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Datasets = Table.ExpandRecordColumn(ReportsTable, "Column1", {"id"}, {"Dataset ID"}),

    ExecuteQuery = Source{[Key="ExecuteQuery"]}[Data],
    Result2 = ExecuteQuery(DatasetTestID, Query, null),

    RefreshScheduleForDataset = Source{[Key="RefreshScheduleForDataset"]}[Data],
    Result3 = RefreshScheduleForDataset(GroupTestID,DatasetTestID),    

    /* Reports */
    GetReportsInGroup = Source{[Key="GetReportsInGroup"]}[Data],
    GetReportsInGroupResult = GetReportsInGroup(GroupTestID),
    ReportsJson = Json.Document(GetReportsInGroupResult)[value],
    ReportsTable = Table.FromList(ReportsJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Reports = Table.ExpandRecordColumn(ReportsTable, "Column1", {"id"}, {"ReportID"}),
    ReportsTest = Table.UnpivotOtherColumns(Reports,{},"Attribute","Value"),

    /* Workspaces */
    GetGroups = Source{[Key="GetGroups"]}[Data],
    GetGroupsResult = GetGroups(null,null,null),
    GroupsJson = Json.Document(GetGroupsResult)[value],
    GroupsTable = Table.FromList(GroupsJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Groups = Table.ExpandRecordColumn(GroupsTable, "Column1", {"id","name"}, {"Workspace ID","Name"})

in
    Source