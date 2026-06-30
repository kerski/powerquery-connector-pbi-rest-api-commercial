/*
    Author: John Kerski

    Description: Connector wraps many of the "Get" endpoints in the Power BI API (with the exception of ExecuteQuery),
    so that OAuth can be used to authenticate to the service.  This connector serves
    as a way to have a library of Power Query functions to build datasets without the need
    for storing client secrets or passwords in the dataset.  The custom data connector will need
    to be installed in the a Power BI Gateway in order to refresh datasets leveraging this
    custom connector.  For more information on installing a custom data connector with a gateway
    please see: https://learn.microsoft.com/en-us/power-bi/connect-data/service-gateway-custom-connectors .
*/
[Version = "1.3.0"]
section PBIRESTAPIComm;
[
    DataSource.Kind = "PBIRESTAPIComm",
    Publish = "PBIRESTAPIComm.Publish"
]
/*****************
    Navigation Table
*****************/
shared PBIRESTAPIComm.FunctionCatalog = () =>
let
	objects = #table(
            {"Name","Key","Data","ItemKind","ItemName","IsLeaf"},{
            /* Apps */
            {"GetApp","GetApp",PBIRESTAPIComm.GetApp,"Function","GetApp",true},
            {"GetApps","GetApps",PBIRESTAPIComm.GetApps,"Function","GetApps",true},
            {"GetDashboardInApp","GetDashboardInApp",PBIRESTAPIComm.GetDashboardInApp,"Function","GetDashboardInApp",true},
            {"GetDashboardsInApp","GetDashboardsInApp",PBIRESTAPIComm.GetDashboardsInApp,"Function","GetDashboardsInApp",true},  
            {"GetReportInApp","GetReportInApp",PBIRESTAPIComm.GetReportInApp,"Function","GetReportInApp",true},
            {"GetReportsInApp","GetReportsInApp",PBIRESTAPIComm.GetReportsInApp,"Function","GetReportsInApp",true},                      
            {"GetDashboardTileInApp","GetDashboardTileInApp",PBIRESTAPIComm.GetDashboardTileInApp,"Function","GetDashboardTileInApp",true},                      
            {"GetDashboardTilesInApp","GetDashboardTilesInApp",PBIRESTAPIComm.GetDashboardTilesInApp,"Function","GetDashboardTilesInApp",true},                      
            /* Dashboards */
            {"GetDashboardInGroup","GetDashboardInGroup",PBIRESTAPIComm.GetDashboardInGroup,"Function","GetDashboardInGroup",true},                      
            {"GetDashboardsInGroup","GetDashboardsInGroup",PBIRESTAPIComm.GetDashboardsInGroup,"Function","GetDashboardsInGroup",true},                      
            {"GetDashboardTileInGroup","GetDashboardTileInGroup",PBIRESTAPIComm.GetDashboardTileInGroup,"Function","GetDashboardTileInGroup",true},                      
            {"GetDashboardTilesInGroup","GetDashboardTilesInGroup",PBIRESTAPIComm.GetDashboardTilesInGroup,"Function","GetDashboardTilesInGroup",true},                      
            /* Dataflows */
            {"GetDataflowInGroup","GetDataflowInGroup",PBIRESTAPIComm.GetDataflowInGroup,"Function","GetDataflowInGroup",true},            
            {"GetDataflowDataSourcesInGroup","GetDataflowDataSourcesInGroup",PBIRESTAPIComm.GetDataflowDataSourcesInGroup,"Function","GetDataflowDataSourcesInGroup",true},            
            {"GetDataflowTransactionsInGroup","GetDataflowTransactionsInGroup",PBIRESTAPIComm.GetDataflowTransactionsInGroup,"Function","GetDataflowTransactionsInGroup",true},            
            {"GetDataflowsInGroup","GetDataflowsInGroup",PBIRESTAPIComm.GetDataflowsInGroup,"Function","GetDataflowsInGroup",true},            
            {"GetUpstreamDataflowsInGroup","GetUpstreamDataflowsInGroup",PBIRESTAPIComm.GetUpstreamDataflowsInGroup,"Function","GetUpstreamDataflowsInGroup",true},                                    
            /* Datasets */
            {"GetDatasetDiscoverGatewaysInGroup","GetDatasetDiscoverGatewaysInGroup",PBIRESTAPIComm.GetDatasetDiscoverGatewaysInGroup,"Function","GetDatasetDiscoverGatewaysInGroup",true},            
            {"GetDatasetInGroup","GetDatasetInGroup",PBIRESTAPIComm.GetDatasetInGroup,"Function","GetDatasetInGroup",true},
            {"GetDatasetToDataflowsLinksInGroup","GetDatasetToDataflowsLinksInGroup",PBIRESTAPIComm.GetDatasetToDataflowsLinksInGroup,"Function","GetDatasetToDataflowsLinksInGroup",true},
            {"GetDatasetUsersInGroup","GetDatasetUsersInGroup",PBIRESTAPIComm.GetDatasetUsersInGroup,"Function","GetDatasetUsersInGroup",true},
            {"GetDatasetsInGroup","GetDatasetsInGroup",PBIRESTAPIComm.GetDatasetsInGroup,"Function","GetDatasetsInGroup",true},
            {"GetDatasetDatasourcesInGroup","GetDatasetDatasourcesInGroup",PBIRESTAPIComm.GetDatasetDatasourcesInGroup,"Function","GetDatasetDatasourcesInGroup",true},
            {"GetDatasetDirectQueryRefreshScheduleInGroup","GetDatasetDirectQueryRefreshScheduleInGroup",PBIRESTAPIComm.GetDatasetDirectQueryRefreshScheduleInGroup,"Function","GetDatasetDirectQueryRefreshScheduleInGroup",true},
            {"GetDatasetParametersInGroup","GetDatasetParametersInGroup",PBIRESTAPIComm.GetDatasetParametersInGroup,"Function","GetDatasetParametersInGroup",true},
            {"GetDatasetQueryScaleOutStatusInGroup","GetDatasetQueryScaleOutStatusInGroup",PBIRESTAPIComm.GetDatasetQueryScaleOutStatusInGroup,"Function","GetDatasetQueryScaleOutStatusInGroup",true},
            {"GetDatasetRefreshExecutionDetailsInGroup","GetDatasetRefreshExecutionDetailsInGroup",PBIRESTAPIComm.GetDatasetRefreshExecutionDetailsInGroup,"Function","GetDatasetRefreshExecutionDetailsInGroup",true},
            {"GetDatasetRefreshHistoryInGroup","GetDatasetRefreshHistoryInGroup",PBIRESTAPIComm.GetDatasetRefreshHistoryInGroup,"Function","GetDatasetRefreshHistoryInGroup",true},
            {"GetDatasetRefreshScheduleInGroup","GetDatasetRefreshScheduleInGroup",PBIRESTAPIComm.GetDatasetRefreshScheduleInGroup,"Function","GetDatasetRefreshScheduleInGroup",true},
            {"ExecuteQuery","ExecuteQuery",PBIRESTAPIComm.ExecuteQuery,"Function","ExecuteQuery",true},
            {"ExecuteQueryInGroup","ExecuteQueryInGroup",PBIRESTAPIComm.ExecuteQueryInGroup,"Function","ExecuteQueryInGroup",true},
            {"ExecuteDaxQueries","ExecuteDaxQueries",PBIRESTAPIComm.ExecuteDaxQueries,"Function","ExecuteDaxQueries",true},
            {"ExecuteDaxQueriesInGroup","ExecuteDaxQueriesInGroup",PBIRESTAPIComm.ExecuteDaxQueriesInGroup,"Function","ExecuteDaxQueriesInGroup",true},
            /* Reports */
            {"GetPaginatedReportDatasourcesInGroup","GetPaginatedReportDatasourcesInGroup",PBIRESTAPIComm.GetPaginatedReportDatasourcesInGroup,"Function","GetPaginatedReportDatasourcesInGroup",true},
            {"GetReportPageInGroup","GetReportPageInGroup",PBIRESTAPIComm.GetReportPageInGroup,"Function","GetReportPageInGroup",true},
            {"GetReportPagesInGroup","GetReportPagesInGroup",PBIRESTAPIComm.GetReportPagesInGroup,"Function","GetReportPagesInGroup",true},
            {"GetReportInGroup","GetReportInGroup",PBIRESTAPIComm.GetReportInGroup,"Function","GetReportInGroup",true},
            {"GetReportsInGroup","GetReportsInGroup",PBIRESTAPIComm.GetReportsInGroup,"Function","GetReportsInGroup",true},
            {"ExportReportInGroup","ExportReportInGroup",PBIRESTAPIComm.ExportReportInGroup,"Function","ExportReportInGroup",true},
            /* Goal Values */            
            {"GetScorecardGoalValuesInGroup","GetScorecardGoalValuesInGroup",PBIRESTAPIComm.GetScorecardGoalValuesInGroup,"Function","GetScorecardGoalValuesInGroup",true},
            {"GetScorecardGoalValueInGroup","GetScorecardGoalValueInGroup",PBIRESTAPIComm.GetScorecardGoalValueInGroup,"Function","GetScorecardGoalValueInGroup",true},            
            /* Goals */
            {"GetScorecardGoalsInGroup","GetScorecardGoalsInGroup",PBIRESTAPIComm.GetScorecardGoalsInGroup,"Function","GetScorecardGoalsInGroup",true},            
            {"GetScorecardGoalInGroup","GetScorecardGoalInGroup",PBIRESTAPIComm.GetScorecardGoalInGroup,"Function","GetScorecardGoalInGroup",true},            
            {"GetScorecardGoalRefreshHistoryInGroup","GetScorecardGoalRefreshHistoryInGroup",PBIRESTAPIComm.GetScorecardGoalRefreshHistoryInGroup,"Function","GetScorecardGoalRefreshHistoryInGroup",true},            
            /* GoalsStatusRules */
            {"GetScorecardGoalsStatusRulesInGroup","GetScorecardGoalsStatusRulesInGroup",PBIRESTAPIComm.GetScorecardGoalsStatusRulesInGroup,"Function","GetScorecardGoalsStatusRulesInGroup",true},
            /* Groups */
            {"GetGroupUsers","GetGroupUsers",PBIRESTAPIComm.GetGroupUsers,"Function","GetGroupUsers",true},
            {"GetGroups","GetGroups",PBIRESTAPIComm.GetGroups,"Function","GetGroups",true},
            /* Pipelines */
            {"GetPipeline","GetPipeline",PBIRESTAPIComm.GetPipeline,"Function","GetPipeline",true}, 
            {"GetPipelineOperation","GetPipelineOperation",PBIRESTAPIComm.GetPipelineOperation,"Function","GetPipelineOperation",true},
            {"GetPipelineOperations","GetPipelineOperations",PBIRESTAPIComm.GetPipelineOperations,"Function","GetPipelineOperations",true},
            {"GetPipelineStageArtifacts","GetPipelineStageArtifacts",PBIRESTAPIComm.GetPipelineStageArtifacts,"Function","GetPipelineStageArtifacts",true},
            {"GetPipelineStages","GetPipelineStages",PBIRESTAPIComm.GetPipelineStages,"Function","GetPipelineStages",true},
            {"GetPipelineUsers","GetPipelineUsers",PBIRESTAPIComm.GetPipelineUsers,"Function","GetPipelineUsers",true},
            {"GetPipelines","GetPipelines",PBIRESTAPIComm.GetPipelines,"Function","GetPipelines",true},
            /* Scorecards */
            {"GetScorecardsInGroup","GetScorecardsInGroup",PBIRESTAPIComm.GetScorecardsInGroup,"Function","GetScorecardsInGroup",true},
            {"GetScorecardInGroup","GetScorecardInGroup",PBIRESTAPIComm.GetScorecardInGroup,"Function","GetScorecardInGroup",true},                                     
            {"GetScorecardByReportIdInGroup","GetScorecardByReportIdInGroup",PBIRESTAPIComm.GetScorecardByReportIdInGroup,"Function","GetScorecardByReportIdInGroup",true}                                           
        }),
	navTable = Table.ForceToNavigationTable(objects, {"Key"},"Name","Data","ItemKind","ItemName","IsLeaf")
in
	navTable;

/*****************
    Test Hooks
*****************/

shared PBIRESTAPIComm.ArrowDetectionGetContentType = ArrowDetectionGetContentType;
shared PBIRESTAPIComm.ArrowDetectionIsArrowContentType = ArrowDetectionIsArrowContentType;
shared PBIRESTAPIComm.ArrowDetectionHasArrowMagic = ArrowDetectionHasArrowMagic;
shared PBIRESTAPIComm.ArrowDetectionIsArrowResponse = ArrowDetectionIsArrowResponse;
shared PBIRESTAPIComm.ArrowBinaryExBuffer = (binary as binary) as binary => Binary.Buffer(binary);
shared PBIRESTAPIComm.ArrowBinaryExSlice = (binary as binary, offset as number, length as number) as binary => Binary.Range(binary, offset, length);
shared PBIRESTAPIComm.ArrowBinaryExLength = (binary as binary) as number => Binary.Length(binary);
shared PBIRESTAPIComm.ArrowFromBinary = ArrowFromBinary;
shared PBIRESTAPIComm.ArrowReadUInt8 = ArrowReadUInt8;
shared PBIRESTAPIComm.ArrowTestRaise = ArrowError;
shared PBIRESTAPIComm.ArrowValidateDictionaryBatch = ArrowValidateDictionaryBatch;
shared PBIRESTAPIComm.ArrowMergeDictionaryValues = ArrowMergeDictionaryValues;
shared PBIRESTAPIComm.ExecuteDaxJsonToTable = ExecuteDaxJsonToTable;
shared PBIRESTAPIComm.ExecuteDaxParseArrowResponse = ExecuteDaxParseArrowResponse;
shared PBIRESTAPIComm.ExecuteDaxParseJsonResponse = ExecuteDaxParseJsonResponse;
shared PBIRESTAPIComm.ExecuteDaxDetectResponseKind = ExecuteDaxDetectResponseKind;
shared PBIRESTAPIComm.ExecuteDaxResponseAsTable = ExecuteDaxResponseAsTable;

/*****************
    APPS
*****************/

/*** GetApp ***/
shared PBIRESTAPIComm.GetApp = Value.ReplaceType(
    GetApp,
    GetAppType
);

GetAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The Application ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetApp",
    Documentation.LongDescription = "Returns the specified installed app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetApp(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-app#app"
        ]
    }
];

GetApp = (optional appId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId)
    in
        result;
/*** End GetApp ***/
/*** GetApps***/
shared PBIRESTAPIComm.GetApps = Value.ReplaceType(
    GetApps,
    GetAppsType
);

GetAppsType = type function (
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetApps",
    Documentation.LongDescription = "Returns a list of installed apps.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetApps()",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-apps#apps"
        ]
    }
];

GetApps = () =>
    let
        result = GetJSON("v1.0/myorg/apps")
    in
        result;
/*** End GetApps***/

/*** GetDashboardInApp***/
shared PBIRESTAPIComm.GetDashboardInApp = Value.ReplaceType(
    GetDashboardInApp,
    GetDashboardInAppType
);

GetDashboardInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The Application ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The Dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardInApp",
    Documentation.LongDescription = "Returns the specified dashboard from the specified app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardInApp(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-dashboard#dashboard"
        ]
    }
];

GetDashboardInApp = (optional appId as text, optional dashboardId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/dashboards/" & dashboardId)
    in
        result;

/*** End GetDashboardInApp***/

/*** GetDashboardsInApp***/
shared PBIRESTAPIComm.GetDashboardsInApp = Value.ReplaceType(
    GetDashboardsInApp,
    GetDashboardsInAppType
);

GetDashboardsInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The Application ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardsInApp",
    Documentation.LongDescription = "Returns a list of dashboards from the specified app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardsInApp(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-dashboards#dashboards"
        ]
    }
];

GetDashboardsInApp = (optional appId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/dashboards")
    in
        result;

/*** End GetDashboardsInApp***/

/*** GetReportInApp***/
shared PBIRESTAPIComm.GetReportInApp = Value.ReplaceType(
    GetReportInApp,
    GetReportInAppType
);

GetReportInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The Application ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportInApp",
    Documentation.LongDescription = "Returns the specified report from the specified app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportInApp(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-report#report"
        ]
    }
];

GetReportInApp = (optional appId as text, optional reportId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/reports/" & reportId)
    in
        result;

/*** End GetReportInApp***/

/*** GetReports***/
shared PBIRESTAPIComm.GetReportsInApp = Value.ReplaceType(
    GetReportsInApp,
    GetReportsInAppType
);

GetReportsInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "Application ID",
            Documentation.FieldDescription = "The Application ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportsInApp",
    Documentation.LongDescription = "Returns a list of reports from the specified app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportsInApp(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-reports#reports"
        ]
    }
];

GetReportsInApp = (optional appId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/reports")
    in
        result;

/*** End GetReports***/

/*** GetDashboardTileInApp***/
shared PBIRESTAPIComm.GetDashboardTileInApp = Value.ReplaceType(
    GetDashboardTileInApp,
    GetDashboardTileInAppType
);

GetDashboardTileInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The application ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional tileId as (
        type text meta [
            Documentation.FieldCaption = "Tile ID",
            Documentation.FieldDescription = "The tile ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardTileInApp",
    Documentation.LongDescription = "Returns the specified tile within the specified dashboard from the specified app.
                                     Supported tiles include datasets and live tiles that contain an entire report page.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardTileInApp(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-tile#tile"
        ]
    }
];

GetDashboardTileInApp = (optional appId as text, optional dashboardId as text, optional tileId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/dashboards/" & dashboardId & "/tiles/" & tileId)
    in
        result;
/*** End GetDashboardTileApp***/

/*** GetDashboardTilesInApp***/
shared PBIRESTAPIComm.GetDashboardTilesInApp = Value.ReplaceType(
    GetDashboardTilesInApp,
    GetDashboardTilesInAppType
);

GetDashboardTilesInAppType = type function (
    optional appId as (
        type text meta [
            Documentation.FieldCaption = "App ID",
            Documentation.FieldDescription = "The application ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ) 
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardTilesInApp",
    Documentation.LongDescription = "Returns a list of tiles within the specified dashboard from the specified app.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardTilesInApp(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-tiles#tiles"
        ]
    }
];

GetDashboardTilesInApp = (optional appId as text, optional dashboardId as text) =>
    let
        result = GetJSON("v1.0/myorg/apps/" & appId & "/dashboards/" & dashboardId & "/tiles")
    in
        result;
/*** End GetDashboardTilesInApp***/

/*****************
    Dashboards
*****************/

/*** GetDashboardInGroup***/
shared PBIRESTAPIComm.GetDashboardInGroup = Value.ReplaceType(
    GetDashboardInGroup,
    GetDashboardInGroupType
);

GetDashboardInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardInGroup",
    Documentation.LongDescription = "Returns the specified dashboard from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-dashboard-in-group#dashboard"
        ]
    }
];

GetDashboardInGroup = (optional groupId as text, optional dashboardId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/dashboards/" & dashboardId)
    in
        result;
/*** End GetDashboardInGroup***/

/*** GetDashboardsInGroup***/
shared PBIRESTAPIComm.GetDashboardsInGroup = Value.ReplaceType(
    GetDashboardsInGroup,
    GetDashboardsInGroupType
);

GetDashboardsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardsInGroup",
    Documentation.LongDescription = "Returns a list of dashboards from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardsInGroup(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-dashboards-in-group#dashboards"
        ]
    }
];

GetDashboardsInGroup = (optional groupdId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dashboards")
    in
        result;
/*** End GetDashboardsInGroup***/

/*** GetDashboardTileInGroup***/
shared PBIRESTAPIComm.GetDashboardTileInGroup = Value.ReplaceType(
    GetDashboardTileInGroup,
    GetDashboardTileInGroupType
);

GetDashboardTileInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional tileId as (
        type text meta [
            Documentation.FieldCaption = "Tile ID",
            Documentation.FieldDescription = "The tile ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardTileInGroup",
    Documentation.LongDescription = "Returns the specified tile within the specified dashboard from the specified workspace.
                                     Supported tiles include datasets and live tiles that contain an entire report page.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardTileInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-tile-in-group#tile"
        ]
    }
];
GetDashboardTileInGroup = (optional groupId as text, optional dashboardId as text, optional tileId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/dashboards/" & dashboardId & "/tiles/" & tileId)
    in
        result;
/*** End GetDashboardTileInGroup***/

/*** GetDashboardTilesInGroup***/
shared PBIRESTAPIComm.GetDashboardTilesInGroup = Value.ReplaceType(
    GetDashboardTilesInGroup,
    GetDashboardTilesInGroupType
);

GetDashboardTilesInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional dashboardId as (
        type text meta [
            Documentation.FieldCaption = "Dashboard ID",
            Documentation.FieldDescription = "The dashboard ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ) 
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDashboardTilesInGroup",
    Documentation.LongDescription = "Returns a list of tiles within the specified dashboard from the specified workspace.
                                     Supported tiles include datasets and live tiles that contain an entire report page.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDashboardTilesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-tiles-in-group#tiles"
        ]
    }
];

GetDashboardTilesInGroup = (optional groupId as text, optional dashboardId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/dashboards/" & dashboardId & "/tiles")
    in
        result;
/*** End GetDashboardTilesInGroup***/


/*****************
    Dataflows
*****************/

/*** GetDataflowInGroup***/
shared PBIRESTAPIComm.GetDataflowInGroup = Value.ReplaceType(
    GetDataflowInGroup,
    GetDataflowInGroupType
);

GetDataflowInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataflow ID",
            Documentation.FieldDescription = "The dataflow ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDataflowInGroup",
    Documentation.LongDescription = "Exports the specified dataflow definition to a JSON file.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDataflowInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Exported Json file"
        ]
    }
];

GetDataflowInGroup = (optional groupdId as text, optional dataflowId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dataflows/" & dataflowId)
    in
        result;
/*** End GetDataflowInGroup***/

/*** GetDataflowDataSourcesInGroup***/
shared PBIRESTAPIComm.GetDataflowDataSourcesInGroup = Value.ReplaceType(
    GetDataflowDataSourcesInGroup,
    GetDataflowDataSourcesInGroupType
);

GetDataflowDataSourcesInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataflow ID",
            Documentation.FieldDescription = "The dataflow ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDataflowDataSourcesInGroup",
    Documentation.LongDescription = "Returns a list of data sources for the specified dataflow.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDataflowDataSourcesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflow-data-sources#datasources"
        ]
    }
];

GetDataflowDataSourcesInGroup = (optional groupdId as text, optional dataflowId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dataflows/" & dataflowId & "/datasources")
    in
        result;
/*** End GetDataflowDataSourcesInGroup***/

/*** GetDataflowTransactionsInGroup***/
shared PBIRESTAPIComm.GetDataflowTransactionsInGroup = Value.ReplaceType(
    GetDataflowTransactionsInGroup,
    GetDataflowTransactionsInGroupType
);

GetDataflowTransactionsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataflow ID",
            Documentation.FieldDescription = "The dataflow ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDataflowTransactionsInGroup",
    Documentation.LongDescription = "Returns a list of transactions for the specified dataflow.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDataflowTransactionsInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflow-transactions#dataflowtransactions"
        ]
    }
];

GetDataflowTransactionsInGroup = (optional groupdId as text, optional dataflowId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dataflows/" & dataflowId & "/transactions")
    in
        result;
/*** End GetDataflowTransactionsInGroup***/

/*** GetDataflowsInGroup***/
shared PBIRESTAPIComm.GetDataflowsInGroup = Value.ReplaceType(
    GetDataflowsInGroup,
    GetDataflowsInGroupType
);

GetDataflowsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDataflowsInGroup",
    Documentation.LongDescription = "Returns a list of all dataflows from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDataflowsInGroup(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflows#dataflows"
        ]
    }
];

GetDataflowsInGroup = (optional groupdId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dataflows")
    in
        result;
/*** End GetDataflowsInGroup***/

/** GetUpstreamDataflowsInGroup***/
shared PBIRESTAPIComm.GetUpstreamDataflowsInGroup = Value.ReplaceType(
    GetUpstreamDataflowsInGroup,
    GetUpstreamDataflowsInGroupType
);

GetUpstreamDataflowsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataflow ID",
            Documentation.FieldDescription = "The dataflow ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetUpstreamDataflowsInGroup",
    Documentation.LongDescription = "Returns a list of upstream dataflows for the specified dataflow.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetUpstreamDataflowsInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-upstream-dataflows-in-group#dependentdataflows"
        ]
    }
];

GetUpstreamDataflowsInGroup = (optional groupdId as text, optional dataflowId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/dataflows/" & dataflowId & "/upstreamDataflows")
    in
        result;
/** End GetUpstreamDataflowsInGroup***/




/*****************
    Datasets
*****************/

/*** GetDatasetDiscoverGatewaysInGroup***/
shared PBIRESTAPIComm.GetDatasetDiscoverGatewaysInGroup = Value.ReplaceType(
    GetDatasetDiscoverGatewaysInGroup,
    GetDatasetDiscoverGatewaysInGroupType
);

GetDatasetDiscoverGatewaysInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetDiscoverGatewaysInGroup",
    Documentation.LongDescription = "Returns a list of gateways that the specified dataset from the specified workspace can be bound to. This API call is only relevant to datasets that have at least one on-premises connection. For datasets with cloud-only connections, this API call returns an empty list.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetDiscoverGatewaysInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/discover-gateways-in-group#gateways"
        ]
    }
];

GetDatasetDiscoverGatewaysInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/Default.DiscoverGateways")
    in
        result;
/*** End GetDatasetDiscoverGatewaysInGroup***/

/*** GetDatasetInGroup***/
shared PBIRESTAPIComm.GetDatasetInGroup = Value.ReplaceType(
    GetDatasetInGroup,
    GetDatasetInGroupType
);

GetDatasetInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetInGroup",
    Documentation.LongDescription = "Returns the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-datasets-in-group#datasets"
        ]
    }
];

GetDatasetInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId)
    in
        result;
/*** End GetDatasetInGroup***/

/*** GetDatasetToDataflowsLinksInGroup***/
shared PBIRESTAPIComm.GetDatasetToDataflowsLinksInGroup = Value.ReplaceType(
    GetDatasetToDataflowsLinksInGroup,
    GetDatasetToDataflowsLinksInGroupType
);

GetDatasetToDataflowsLinksInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetToDataflowsLinksInGroup",
    Documentation.LongDescription = "Returns a list of upstream dataflows for datasets from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetToDataflowsLinksInGroup(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset-to-dataflows-links-in-group#datasettodataflowlinksresponse"
        ]
    }
];

GetDatasetToDataflowsLinksInGroup = (optional groupdId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/upstreamDataflows")
    in
        result;
/*** End GetDatasetToDataflowsLinksInGroup***/

/*** GetDatasetsUsersInGroup***/
shared PBIRESTAPIComm.GetDatasetUsersInGroup = Value.ReplaceType(
    GetDatasetUsersInGroup,
    GetDatasetUsersInGroupType
);

GetDatasetUsersInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetUsersInGroup",
    Documentation.LongDescription = "Returns a list of principals that have access to the specified dataset. When user permissions to a dataset have been recently updated, the new permissions might not be immediately available through API calls.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetUsersInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset-users-in-group#datasetusersaccess"
        ]
    }
];

GetDatasetUsersInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/users")
    in
        result;
/*** End GetDatasetUsersInGroup***/

/*** GetDatasetsInGroup***/
shared PBIRESTAPIComm.GetDatasetsInGroup = Value.ReplaceType(
    GetDatasetsInGroup,
    GetDatasetsInGroupType
);

GetDatasetsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetsInGroup",
    Documentation.LongDescription = "Returns a list of datasets from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetsInGroup(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-datasets-in-group#datasets"
        ]
    }
];

GetDatasetsInGroup = (optional groupdId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets")
    in
        result;
/*** End GetDatasetsInGroup***/

/*** GetDatasetDatasourcesInGroup***/
shared PBIRESTAPIComm.GetDatasetDatasourcesInGroup = Value.ReplaceType(
    GetDatasetDatasourcesInGroup,
    GetDatasetDatasourcesInGroupType
);

GetDatasetDatasourcesInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetDatasourcesInGroup",
    Documentation.LongDescription = "Returns a list of data sources for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetDatasourcesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-datasources-in-group#datasources"
        ]
    }
];

GetDatasetDatasourcesInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/datasources")
    in
        result;
/*** End GetDatasetDatasourcesInGroup***/

/*** GetDatasetDirectQueryRefreshScheduleInGroup***/
shared PBIRESTAPIComm.GetDatasetDirectQueryRefreshScheduleInGroup = Value.ReplaceType(
    GetDatasetDirectQueryRefreshScheduleInGroup,
    GetDatasetDirectQueryRefreshScheduleInGroupType
);

GetDatasetDirectQueryRefreshScheduleInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetDirectQueryRefreshScheduleInGroup",
    Documentation.LongDescription = "Returns the refresh schedule for a specified DirectQuery or LiveConnection dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetDirectQueryRefreshScheduleInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-direct-query-refresh-schedule-in-group#directqueryrefreshschedule"
        ]
    }
];

GetDatasetDirectQueryRefreshScheduleInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/directQueryRefreshSchedule")
    in
        result;
/*** End GetDatasetDirectQueryRefreshScheduleInGroup***/

/*** GetDatasetGatewayDatasourcesInGroup***/
// Deprecated
/*** End GetDatasetGatewayDatasourcesInGroup***/

/*** GetDatasetParametersInGroup***/
shared PBIRESTAPIComm.GetDatasetParametersInGroup = Value.ReplaceType(
    GetDatasetParametersInGroup,
    GetDatasetParametersInGroupType
);

GetDatasetParametersInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetParametersInGroup",
    Documentation.LongDescription = "Returns a list of parameters for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetParametersInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-parameters-in-group#mashupparameters"
        ]
    }
];

GetDatasetParametersInGroup = (optional groupdId as text, optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/parameters")
    in
        result;
/*** End GetDatasetParametersInGroup***/

/*** GetDatasetRefreshExecutionDetailsInGroup***/
shared PBIRESTAPIComm.GetDatasetRefreshExecutionDetailsInGroup = Value.ReplaceType(
    GetDatasetRefreshExecutionDetailsInGroup,
    GetDatasetRefreshExecutionDetailsInGroupType
);

GetDatasetRefreshExecutionDetailsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional refreshId as (
        type text meta [
            Documentation.FieldCaption = "Refresh ID",
            Documentation.FieldDescription = "The Refresh ID",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    )        
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetRefreshExecutionDetailsInGroup",
    Documentation.LongDescription = "Returns execution details of an enhanced refresh operation for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetRefreshExecutionDetailsInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-execution-details-in-group#datasetrefreshdetail"
        ]
    }
];

GetDatasetRefreshExecutionDetailsInGroup = (optional groupdId as text, optional datasetId as text, optional refreshId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/datasets/" & datasetId & "/refreshes/" & refreshId)
    in
        result;
/*** End GetDatasetRefreshExecutionDetailsInGroup***/

/*** GetDatasetRefreshHistoryInGroup***/
shared PBIRESTAPIComm.GetDatasetRefreshHistoryInGroup = Value.ReplaceType(
    GetDatasetRefreshHistoryInGroup,
    GetDatasetRefreshHistoryInGroupType
);

GetDatasetRefreshHistoryInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetRefreshHistoryInGroup",
    Documentation.LongDescription = "Returns the refresh history for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetRefreshHistoryInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-history-in-group#refreshes"
        ]
    }
];

GetDatasetRefreshHistoryInGroup = (optional groupId as text , optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/datasets/" & datasetId & "/refreshes")
    in
        result;
/*** End GetDatasetRefreshHistoryInGroup***/

/*** GetDatasetRefreshScheduleInGroup***/
shared PBIRESTAPIComm.GetDatasetRefreshScheduleInGroup = Value.ReplaceType(
    GetDatasetRefreshScheduleInGroup,
    GetDatasetRefreshScheduleInGroupType
);

GetDatasetRefreshScheduleInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetRefreshScheduleInGroup",
    Documentation.LongDescription = "Returns the refresh schedule for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetRefreshScheduleInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-schedule-in-group#refreshschedule"
        ]
    }
];

GetDatasetRefreshScheduleInGroup = (optional groupId as text , optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/datasets/" & datasetId & "/refreshSchedule")
    in
        result;
/*** End GetDatasetRefreshScheduleInGroup***/

/*** GetDatasetQueryScaleOutStatusInGroup ***/
shared PBIRESTAPIComm.GetDatasetQueryScaleOutStatusInGroup = Value.ReplaceType(
    GetDatasetQueryScaleOutStatusInGroup,
    GetDatasetQueryScaleOutStatusInGroupType
);

GetDatasetQueryScaleOutStatusInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetDatasetQueryScaleOutStatusInGroup",
    Documentation.LongDescription = "Returns the query scale-out sync status for the specified dataset from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetDatasetQueryScaleOutStatusInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as: https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-query-scale-out-sync-status-in-group"
        ]
    }
];

GetDatasetQueryScaleOutStatusInGroup = (optional groupId as text , optional datasetId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/datasets/" & datasetId & "/queryScaleOut/syncStatus")
    in
        result;

/*** End GetDatasetQueryScaleOutStatusInGroup ***/

/*** ExecuteQuery ***/
shared PBIRESTAPIComm.ExecuteQuery = Value.ReplaceType(
    ExecuteQuery,
    ExecuteQueryType
);

ExecuteQueryType = type function (
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional daxQuery as (
        type text meta [
            Documentation.FieldCaption = "DAX Query",
            Documentation.FieldDescription = "A single DAX query which includes all keywords like EVALUATE or DEFINE.",
            Documentation.SampleValues = {
                "VALUES(Table[Column])"
            }
        ]
    ),
    optional impersonatedUPN as (
        type text meta [
            Documentation.FieldCaption = "The UPN of a user to be impersonated",
            Documentation.FieldDescription = "The UPN of a user to be impersonated. If the model is not RLS enabled, this will be ignored.",
            Documentation.SampleValues = {
                "example@somedomain.com"
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.ExecuteQuery",
    Documentation.LongDescription = "Executes Data Analysis Expressions (DAX) queries against the provided dataset. The dataset must reside in My workspace or another workspace.
    DAX query errors will result in:

    A response error, such as DAX query failure.
    A failure HTTP status code (400).
    A query that requests more than one table, or more than the allowed number of table rows, will result in:

    Limited data being returned.
    A response error, such as More than one result table in a query or More than {allowed number} rows in a query result.
    A successful HTTP status code (200).
    Columns that are fully qualified in the query will be returned with a fully qualified name, for example, MyTable[MyColumn]. Columns that are renamed or created in the query will be returned within square bracket, for example, [MyNewColumn].",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.ExecuteQuery(""xxx-xxxx-abcd..."",""VALUES(Table[Column])"",""example@somedomain.com"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries-in-group#datasetexecutequeriesqueryresult"
        ]
    }
];

ExecuteQuery = (optional datasetId as text, optional daxQuery as text, optional impersonatedUPN as text) =>
    let
        //Check arguments
        doArgumentsExist = if(datasetId <> null and datasetId <> "") and (daxQuery <> null and daxQuery <> "") then true else false,
        //Build results
        result = if doArgumentsExist = false then 
                    // See back message that arguments are required
                    #table( type table [response = text],{{"Please provide datasetId or daxQuery arguments"}})
                 else
                    let
                        /* Escape query to fit in JSON*/
                        escapeTable = #table(1, {{daxQuery}}),
                        escapedJson = Table.ReplaceValue(escapeTable,"""","\""",Replacer.ReplaceText,{"Column1"}),
                        escapedJsonQuery = Table.FirstValue(escapedJson),
                        /* Escape impersonate argument appropriately */
                        impersonate = if (impersonatedUPN <> null and impersonatedUPN <> "") then ", ""impersonatedUserName"": """ & impersonatedUPN & """"
                                    else "",
                        /* Build parameters to send */
                        params = [RelativePath = "v1.0/myorg/datasets/" & datasetId & "/executeQueries",
                                    Headers = [ #"Content-Type" = "application/json"],
                                    Content = Text.ToBinary("{""queries"":[{""query"": """ & escapedJsonQuery & """}],""serializerSettings"":{""includeNulls"": false}" & impersonate & "}")
                                ],
                        postResult = PostJSON(params)
                    in
                        postResult
    in
        result;
/*** End ExecuteQuery***/

/*** ExecuteQueryInGroup ***/
shared PBIRESTAPIComm.ExecuteQueryInGroup = Value.ReplaceType(
    ExecuteQueryInGroup,
    ExecuteQueryInGroupType
);

ExecuteQueryInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),    
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional daxQuery as (
        type text meta [
            Documentation.FieldCaption = "DAX Query",
            Documentation.FieldDescription = "A single DAX query which includes all keywords like EVALUATE or DEFINE.",
            Documentation.SampleValues = {
                "VALUES(Table[Column])"
            }
        ]
    ),
    optional impersonatedUPN as (
        type text meta [
            Documentation.FieldCaption = "The UPN of a user to be impersonated",
            Documentation.FieldDescription = "The UPN of a user to be impersonated. If the model is not RLS enabled, this will be ignored.",
            Documentation.SampleValues = {
                "example@somedomain.com"
            }
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.ExecuteQueryInGroup",
    Documentation.LongDescription = "Executes Data Analysis Expressions (DAX) queries against the provided dataset. The dataset must reside in My workspace or another workspace.
    DAX query errors will result in:

    A response error, such as DAX query failure.
    A failure HTTP status code (400).
    A query that requests more than one table, or more than the allowed number of table rows, will result in:

    Limited data being returned.
    A response error, such as More than one result table in a query or More than {allowed number} rows in a query result.
    A successful HTTP status code (200).
    Columns that are fully qualified in the query will be returned with a fully qualified name, for example, MyTable[MyColumn]. Columns that are renamed or created in the query will be returned within square bracket, for example, [MyNewColumn].",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.ExecuteQuery(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""VALUES(Table[Column])"",""example@somedomain.com"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries-in-group#datasetexecutequeriesqueryresult"
        ]
    }
];

ExecuteQueryInGroup = (optional groupId as text, optional datasetId as text, optional daxQuery as text, optional impersonatedUPN as text) =>
    let
        //Check arguments
        doArgumentsExist = if(groupId <> null and groupId <> "") and (datasetId <> null and datasetId <> "") and (daxQuery <> null and daxQuery <> "") then true else false,
        //Build results
        result = if doArgumentsExist = false then 
                    // See back message that arguments are required
                    #table( type table [response = text],{{"Please provide groupId, datasetId and daxQuery arguments"}})
                 else
                    let
                        /* Escape query to fit in JSON*/
                        escapeTable = #table(1, {{daxQuery}}),
                        escapedJson = Table.ReplaceValue(escapeTable,"""","\""",Replacer.ReplaceText,{"Column1"}),
                        escapedJsonQuery = Table.FirstValue(escapedJson),
                        /* Escape impersonate argument appropriately */
                        impersonate = if (impersonatedUPN <> null and impersonatedUPN <> "") then ", ""impersonatedUserName"": """ & impersonatedUPN & """"
                                    else "",
                        /* Build parameters to send */
                        params = [RelativePath = "v1.0/myorg/groups/" & groupId & "/datasets/" & datasetId & "/executeQueries",
                                    Headers = [ #"Content-Type" = "application/json"],
                                    Content = Text.ToBinary("{""queries"":[{""query"": """ & escapedJsonQuery & """}],""serializerSettings"":{""includeNulls"": false}" & impersonate & "}")
                                ],
                        postResult = PostJSON(params)
                    in
                        postResult
    in
        result;
/*** End ExecuteQueryInGroup***/

/*** ExecuteDaxQueries ***/
shared PBIRESTAPIComm.ExecuteDaxQueries = Value.ReplaceType(
    ExecuteDaxQueries,
    ExecuteDaxQueriesType
);

ExecuteDaxQueriesType = type function (
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional query as (
        type text meta [
            Documentation.FieldCaption = "DAX Query",
            Documentation.FieldDescription = "A DAX query text.",
            Documentation.SampleValues = {
                "EVALUATE VALUES('Product'[Category])"
            }
        ]
    ),
    optional applicationContext as (
        type text meta [
            Documentation.FieldCaption = "Application Context",
            Documentation.FieldDescription = "JSON structure containing additional information about an operation."
        ]
    ),
    optional culture as (
        type text meta [
            Documentation.FieldCaption = "Culture",
            Documentation.FieldDescription = "Culture code such as en-US."
        ]
    ),
    optional customData as (
        type text meta [
            Documentation.FieldCaption = "Custom Data",
            Documentation.FieldDescription = "Custom data for use in Dynamic RLS."
        ]
    ),
    optional effectiveUsername as (
        type text meta [
            Documentation.FieldCaption = "Effective Username",
            Documentation.FieldDescription = "Effective username for the query."
        ]
    ),
    optional memoryLimit as (
        type number meta [
            Documentation.FieldCaption = "Memory Limit",
            Documentation.FieldDescription = "Memory limit in KB for the query."
        ]
    ),
    optional queryTimeout as (
        type number meta [
            Documentation.FieldCaption = "Query Timeout",
            Documentation.FieldDescription = "Query timeout in seconds."
        ]
    ),
    optional resultSetRowCountLimit as (
        type number meta [
            Documentation.FieldCaption = "Result Set Row Count Limit",
            Documentation.FieldDescription = "Maximum number of rows to return."
        ]
    ),
    optional roles as (
        type list meta [
            Documentation.FieldCaption = "Roles",
            Documentation.FieldDescription = "Roles assigned to the user."
        ]
    ),
    optional schemaOnly as (
        type logical meta [
            Documentation.FieldCaption = "Schema Only",
            Documentation.FieldDescription = "Whether the query should return schema only."
        ]
    )
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.ExecuteDaxQueries",
    Documentation.LongDescription = "Executes DAX queries and returns a native table. Arrow payloads are auto-detected and parsed when supported.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.ExecuteDaxQueries(""xxx-xxxx-abcd..."",""EVALUATE VALUES('Product'[Category])"",null,""en-US"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-dax-queries"
        ]
    }
];

ExecuteDaxQueries = (
    optional datasetId as text,
    optional query as text,
    optional applicationContext as text,
    optional culture as text,
    optional customData as text,
    optional effectiveUsername as text,
    optional memoryLimit as number,
    optional queryTimeout as number,
    optional resultSetRowCountLimit as number,
    optional roles as list,
    optional schemaOnly as logical
) =>
    let
        doArgumentsExist = if(datasetId <> null and datasetId <> "") and (query <> null and query <> "") then true else false,
        result = if doArgumentsExist = false then
                    #table(type table [response = text],{{"Please provide datasetId and query arguments"}})
                 else
                    let
                        payload = BuildExecuteDaxRequestPayload(query, applicationContext, culture, customData, effectiveUsername, memoryLimit, queryTimeout, resultSetRowCountLimit, roles, schemaOnly),
                        params = [
                            RelativePath = "v1.0/myorg/datasets/" & datasetId & "/executeDaxQueries",
                            Headers = [#"Content-Type" = "application/json", Accept = "application/vnd.apache.arrow.stream, application/vnd.apache.arrow.file, application/octet-stream, application/json"],
                            Content = Json.FromValue(payload),
                            ManualStatusHandling = {200, 400}
                        ],
                        postResult = PostExecuteDax(params)
                    in
                        postResult
    in
        result;
/*** End ExecuteDaxQueries***/

/*** ExecuteDaxQueriesInGroup ***/
shared PBIRESTAPIComm.ExecuteDaxQueriesInGroup = Value.ReplaceType(
    ExecuteDaxQueriesInGroup,
    ExecuteDaxQueriesInGroupType
);

ExecuteDaxQueriesInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID."
        ]
    ),
    optional datasetId as (
        type text meta [
            Documentation.FieldCaption = "Dataset ID",
            Documentation.FieldDescription = "The Dataset ID"
        ]
    ),
    optional query as (
        type text meta [
            Documentation.FieldCaption = "DAX Query",
            Documentation.FieldDescription = "A DAX query text."
        ]
    ),
    optional applicationContext as text,
    optional culture as text,
    optional customData as text,
    optional effectiveUsername as text,
    optional memoryLimit as number,
    optional queryTimeout as number,
    optional resultSetRowCountLimit as number,
    optional roles as list,
    optional schemaOnly as logical
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.ExecuteDaxQueriesInGroup",
    Documentation.LongDescription = "Executes DAX queries in a workspace and returns a native table. Arrow payloads are auto-detected and parsed when supported.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.ExecuteDaxQueriesInGroup(""xxx-xxxx-group..."",""xxx-xxxx-dataset..."",""EVALUATE VALUES('Product'[Category])"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-dax-queries-in-group"
        ]
    }
];

ExecuteDaxQueriesInGroup = (
    optional groupId as text,
    optional datasetId as text,
    optional query as text,
    optional applicationContext as text,
    optional culture as text,
    optional customData as text,
    optional effectiveUsername as text,
    optional memoryLimit as number,
    optional queryTimeout as number,
    optional resultSetRowCountLimit as number,
    optional roles as list,
    optional schemaOnly as logical
) =>
    let
        doArgumentsExist = if(groupId <> null and groupId <> "") and (datasetId <> null and datasetId <> "") and (query <> null and query <> "") then true else false,
        result = if doArgumentsExist = false then
                    #table(type table [response = text],{{"Please provide groupId, datasetId and query arguments"}})
                 else
                    let
                        payload = BuildExecuteDaxRequestPayload(query, applicationContext, culture, customData, effectiveUsername, memoryLimit, queryTimeout, resultSetRowCountLimit, roles, schemaOnly),
                        params = [
                            RelativePath = "v1.0/myorg/groups/" & groupId & "/datasets/" & datasetId & "/executeDaxQueries",
                            Headers = [#"Content-Type" = "application/json", Accept = "application/vnd.apache.arrow.stream, application/vnd.apache.arrow.file, application/octet-stream, application/json"],
                            Content = Json.FromValue(payload),
                            ManualStatusHandling = {200, 400}
                        ],
                        postResult = PostExecuteDax(params)
                    in
                        postResult
    in
        result;
/*** End ExecuteDaxQueriesInGroup***/


/*****************
    Reports
*****************/

/*** GetPaginatedReportDatasourcesInGroup ***/
shared PBIRESTAPIComm.GetPaginatedReportDatasourcesInGroup = Value.ReplaceType(
    GetPaginatedReportDatasourcesInGroup,
    GetPaginatedReportDatasourcesInGroupType
);

GetPaginatedReportDatasourcesInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPaginatedReportDatasourcesInGroup",
    Documentation.LongDescription = "Returns a list of data sources for the specified paginated report (RDL) from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPaginatedReportDatasourcesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""ReportSection"")",
            result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-datasources-in-group"
        ]
    }
];

GetPaginatedReportDatasourcesInGroup = (optional groupId as text , optional reportId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/reports/" & reportId & "/datasources")
    in
        result;
/*** End GetPaginatedReportDatasourcesInGroup ***/

/*** GetReportExportToFileStatusInGroup ***/
/*** End GetReportExportToFileStatusInGroup ***/

/*** GetReportPageInGroup ***/
shared PBIRESTAPIComm.GetReportPageInGroup = Value.ReplaceType(
    GetReportPageInGroup,
    GetReportPageInGroupType
);

GetReportPageInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional pageName as (
        type text meta [
            Documentation.FieldCaption = "Page Name",
            Documentation.FieldDescription = "The page name.",
            Documentation.SampleValues = {
                "ReportSection"
            }
        ]
    )    
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportPageInGroup",
    Documentation.LongDescription = "Returns the specified page within the specified report from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportPageInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""ReportSection"")",
            result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-page-in-group#page"
        ]
    }
];

GetReportPageInGroup = (optional groupId as text , optional reportId as text, optional pageName as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/reports/" & reportId & "/pages/" & pageName)
    in
        result;
/*** End GetReportPageInGroup***/

/*** GetReportPagesInGroup ***/
shared PBIRESTAPIComm.GetReportPagesInGroup = Value.ReplaceType(
    GetReportPagesInGroup,
    GetReportPagesInGroupType
);

GetReportPagesInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportPagesInGroup",
    Documentation.LongDescription = "Returns a list of pages within the specified report from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportPagesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-pages-in-group#pages"
        ]
    }
];

GetReportPagesInGroup = (optional groupId as text , optional reportId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/reports/" & reportId & "/pages")
    in
        result;
/*** End GetReportPagesInGroup***/

/*** GetReportInGroup ***/
shared PBIRESTAPIComm.GetReportInGroup = Value.ReplaceType(
    GetReportInGroup,
    GetReportInGroupType
);

GetReportInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportInGroup",
    Documentation.LongDescription = "Returns the specified report from the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""ReportSection"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-report-in-group#report"
        ]
    }
];

GetReportInGroup = (optional groupId as text , optional reportId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/reports/" & reportId)
    in
        result;
/*** End GetReportInGroup***/

/*** GetReportsInGroup ***/
shared PBIRESTAPIComm.GetReportsInGroup = Value.ReplaceType(
    GetReportsInGroup,
    GetReportsInGroupType
);

GetReportsInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )  
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetReportsInGroup",
    Documentation.LongDescription = "Returns a list of reports from the specified workspace. Since paginated reports (RDL) don't have a dataset, the dataset ID value in the API response for paginated reports isn't displayed.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetReportsInGroup(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-reports-in-group#reports"
        ]
    }
];

GetReportsInGroup = (optional groupId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/reports")
    in
        result;
/*** End GetReportsInGroup***/

/*** ExportReportInGroup ***/
shared PBIRESTAPIComm.ExportReportInGroup = Value.ReplaceType(
    ExportReportInGroup,
    ExportReportInGroupType
);

ExportReportInGroupType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The Report ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional downloadType as (
        type text meta [
            Documentation.FieldCaption = "Download Type",
            Documentation.FieldDescription = "The download type.",
            Documentation.SampleValues = {
                "IncludeModel or LiveConnect"
            }
        ]
    ),
    optional preferClientRouting as (
        type text meta [
            Documentation.FieldCaption = "Prefer Client Routing",
            Documentation.FieldDescription = "Prefer Client Routing type.",
            Documentation.SampleValues = {
                "true or null"
            }
        ]
    )         
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.ExportReportInGroup",
    Documentation.LongDescription = "Exports the specified report from the specified workspace to a Power BI .pbix or .rdl file.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.ExportReportInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""IncludeModel"")",
            result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/reports/export-report-in-group#response"
        ]
    }
];

ExportReportInGroup = (optional groupId as text , optional reportId as text, optional downloadType as text, optional preferClientRouting as logical) as binary =>
    let
        //Build Query String
        downloadQS = if(downloadType <> null and downloadType <> "") then "?downloadType=" & downloadType else "?downloadType=IncludeModel",
        // Handle preferClientRouting
        preferQS = if(preferClientRouting = true) then "&preferClientRouting=true" else "&preferClientRouting=false",
        result = GetFile("v1.0/myorg/groups/" & groupId & "/reports/" & reportId & "/Export" & downloadQS & preferQS)
    in
        result;
/*** End ExportReportInGroup***/

/*****************
    GROUPS
*****************/

/*** GetGroupUsers ***/
shared PBIRESTAPIComm.GetGroupUsers = Value.ReplaceType(
    GetGroupUsers,
    GetGroupUsersType
);

GetGroupUsersType = type function (
    optional groupId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The workspace ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )  
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetGroupUsers",
    Documentation.LongDescription = "Returns a list of users that have access to the specified workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetGroupUsers(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/groups/get-group-users#groupusers"
        ]
    }
];

GetGroupUsers = (optional groupId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupId & "/users")
    in
        result;

/*** GetGroups ***/
shared PBIRESTAPIComm.GetGroups = Value.ReplaceType(
    GetGroups,
    GetGroupsType
);

GetGroupsType = type function (
    optional filter as (
        type text meta [
            Documentation.FieldCaption = "Filter",
            Documentation.FieldDescription = "Filters the results, based on a boolean condition.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional top as (
        type number meta [
            Documentation.FieldCaption = "Top",
            Documentation.FieldDescription = "Returns only the first n results.",
            Documentation.SampleValues = {
                "5"
            }
        ]
    ),
    optional skip as (
        type number meta [
            Documentation.FieldCaption = "Skip",
            Documentation.FieldDescription = "Skips the first n results.",
            Documentation.SampleValues = {
                "10"
            }
        ]
    )              
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetGroups",
    Documentation.LongDescription = "Returns a list of workspaces the user has access to.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetGroups(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/groups/get-groups#groups"
        ]
    }
];

GetGroups = (optional filter as text, optional top as number, optional skip as number) =>
    let
        //Build Query String
        filterQS = if(filter <> null and filter <> "") then "$filter=" & filter else "",
        topQS = if(top <> null) then "$top=" & Number.ToText(top) else "",
        skipQS = if(skip <> null) then "$skip=" & Number.ToText(skip) else "",
        // Figure out if we need to concatenate with ampersand
        queryString = if(filterQS <> "" and topQS <> "" and skipQS <> "") 
                        then "?" & filterQS & "&" & topQS & "&" & skipQS
                        // 110
                        else
                            if(filterQS <> "" and topQS <> "" and skipQS = "" )
                                then 
                                    "?" & filterQS & "&" & topQS
                                    // 101
                                    else 
                                        if(filterQS <> "" and topQS = "" and skipQS <> "")
                                            then "?" & filterQS & "&" & skipQS
                                                // 011
                                                else 
                                                    if(filterQS = "" and topQS <> "" and skipQS <> "")
                                                        then "?" & topQS & "&" & skipQS
                                                            //000
                                                            else 
                                                                if(filterQS = "" and topQS = "" and skipQS = "")
                                                                    then ""
                                                                    //100 or 010 or 001 so just concatenate with ampersand
                                                                    else "?" & filterQS & topQS & skipQS,

        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups" & queryString)
    in
        result;
/*** End GetGroups ***/

/*****************
    Pipelines
*****************/

/*** GetPipeline***/
shared PBIRESTAPIComm.GetPipeline = Value.ReplaceType(
    GetPipeline,
    GetPipelineType
);

GetPipelineType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional expand as (
        type text meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separate list of data types, which will be expanded inline in the response. Supports stages.",
            Documentation.SampleValues = {
                "stages"
            }
        ]
    )              
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipeline",
    Documentation.LongDescription = "Returns the specified deployment pipeline.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipeline(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline#pipeline"
        ]
    }
];

GetPipeline = (optional pipelineId as text, optional expand as text) =>
    let
        //Build Query String
        expandQS = if(expand <> null and expand <> "") then "$expand=" & expand else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines/" & pipelineId & expandQS)
    in
        result;
/*** End GetPipeline ***/

/*** GetPipelineOperation***/
shared PBIRESTAPIComm.GetPipelineOperation = Value.ReplaceType(
    GetPipelineOperation,
    GetPipelineOperationType
);

GetPipelineOperationType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional operationId as (
        type number meta [
            Documentation.FieldCaption = "Operation ID",
            Documentation.FieldDescription = "The operation ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    )              
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelineOperation",
    Documentation.LongDescription = "Returns the details of the specified deploy operation performed on the specified deployment pipeline, including the deployment execution plan.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelineOperation(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-operation#pipelineoperation"
        ]
    }
];

GetPipelineOperation = (optional pipelineId as text, optional operationId as text) =>
    let
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines/" & pipelineId & "/operations/" & operationId)
    in
        result;
/*** End GetPipelineOperation ***/

/*** GetPipelineOperations ***/
shared PBIRESTAPIComm.GetPipelineOperations = Value.ReplaceType(
    GetPipelineOperations,
    GetPipelineOperationsType
);

GetPipelineOperationsType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )              
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelineOperations",
    Documentation.LongDescription = "Returns a list of the up-to-20 most recent deploy operations performed on the specified deployment pipeline.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelineOperations(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-operations#pipelineoperations"
        ]
    }
];

GetPipelineOperations = (optional pipelineId as text) =>
    let
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines/" & pipelineId & "/operations")
    in
        result;        
/*** End GetPipelineOperations ***/

/*** GetPipelineStageArtifacts ***/
shared PBIRESTAPIComm.GetPipelineStageArtifacts = Value.ReplaceType(
    GetPipelineStageArtifacts,
    GetPipelineStageArtifactsType
);

GetPipelineStageArtifactsType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional stageOrder as (
        type number meta [
            Documentation.FieldCaption = "Stage Order",
            Documentation.FieldDescription = "The deployment pipeline stage order. Development (0), Test (1), Production (2).",
            Documentation.SampleValues = {
                "0"
            }
        ]
    )                   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelineStageArtifacts",
    Documentation.LongDescription = "Returns the supported items from the workspace assigned to the specified stage of the specified deployment pipeline.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelineStageArtifacts(""xxx-xxxx-abcd..."",""0"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-stage-artifacts#pipelinestageartifacts"
        ]
    }
];

GetPipelineStageArtifacts = (optional pipelineId as text, optional stageOrder as number) =>
    let
        // Check stage order is right number
        result = if stageOrder <> 0 and stageOrder <> 1 and stageOrder <> 2 then
            #table( type table [response = text],{{"Stage Order needs to be 0 (Development), 1 (Test), or 2 (Production)"}})
        else
            // Now query with parameters
            GetJSON("v1.0/myorg/pipelines/" & pipelineId & "/stages/" & Number.ToText(stageOrder) & "/artifacts")
    in
        result; 
/*** GetPipelineStageArtifacts ***/

/*** GetPipelineStages ***/
shared PBIRESTAPIComm.GetPipelineStages = Value.ReplaceType(
    GetPipelineStages,
    GetPipelineStagesType
);

GetPipelineStagesType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )                   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelineStages",
    Documentation.LongDescription = "Returns the stages of the specified deployment pipeline.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelineStages(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-stages#pipelinestages"
        ]
    }
];

GetPipelineStages = (optional pipelineId as text) =>
    let
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines/" & pipelineId & "/stages")
    in
        result; 
/*** End GetPipelineStages ***/

/*** GetPipelineUsers ***/
shared PBIRESTAPIComm.GetPipelineUsers = Value.ReplaceType(
    GetPipelineUsers,
    GetPipelineUsersType
);

GetPipelineUsersType = type function (
    optional pipelineId as (
        type text meta [
            Documentation.FieldCaption = "Pipeline ID",
            Documentation.FieldDescription = "The deployment pipeline ID.",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    )                   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelineUsers",
    Documentation.LongDescription = "Returns a list of users that have access to the specified deployment pipeline.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelineUsers(""xxx-xxxx-abcd..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-users#pipelineusers"
        ]
    }
];

GetPipelineUsers = (optional pipelineId as text) =>
    let
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines/" & pipelineId & "/users")
    in
        result;
/*** GetPipelineUsers ***/

/*** GetPipelines ***/
shared PBIRESTAPIComm.GetPipelines = Value.ReplaceType(
    GetPipelines,
    GetPipelinesType
);

GetPipelinesType = type function (                   
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetPipelines",
    Documentation.LongDescription = "Returns a list of deployment pipelines that the user has access to.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetPipelines()",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipelines#pipelines"
        ]
    }
];

GetPipelines = () =>
    let
        // Now query with parameters
        result = GetJSON("v1.0/myorg/pipelines")
    in
        result;
/*** End GetPipelines ***/

/*****************
    GoalValues
*****************/

/*** GetScorecardGoalValuesInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalValuesInGroup = Value.ReplaceType(
    GetScorecardGoalValuesInGroup,
    GetScorecardGoalValuesInGroupType
);

GetScorecardGoalValuesInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional goalId as (
        type text meta [
            Documentation.FieldCaption = "Goal ID",
            Documentation.FieldDescription = "The unique identifier of the goal",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    ),          
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports notes.",
            Documentation.SampleValues = {
                "notes"
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalValuesInGroup",
    Documentation.LongDescription = "Reads goal value check-ins.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalValuesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."",""notes"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goalvalues_(preview)/get#goalvalues"
        ]
    }
];

GetScorecardGoalValuesInGroup = (optional groupdId as text, optional scorecardId as text, optional goalId as text, optional expand as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(expandQS <> "") 
                        then "?" & expandQS
                        else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals(" & goalId & ")/goalValues" & queryString)
    in
        result;
/*** End GetScorecardGoalValuesInGroup ***/        

/*** GetScorecardGoalValueInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalValueInGroup = Value.ReplaceType(
    GetScorecardGoalValueInGroup,
    GetScorecardGoalValueInGroupType
);

GetScorecardGoalValueInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional goalId as (
        type text meta [
            Documentation.FieldCaption = "Goal ID",
            Documentation.FieldDescription = "The unique identifier of the goal",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    ),
    optional timestamp as (
        type text meta [
            Documentation.FieldCaption = "Timestamp",
            Documentation.FieldDescription = "The timestamp for the value of the goal",
            Documentation.SampleValues = {
                "2021-12-14T00:00:00Z"
            }
        ]
    ),               
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports notes.",
            Documentation.SampleValues = {
                "notes"
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalValueInGroup",
    Documentation.LongDescription = "Reads a goal value check-in by a UTC date timestamp.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalValueInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."",""2021-12-14T00:00:00Z"",""notes"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goalvalues_(preview)/get-by-id#goalvalue"
        ]
    }
];

GetScorecardGoalValueInGroup = (optional groupdId as text, optional scorecardId as text, optional goalId as text, optional timestamp as datetimezone, optional expand as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(expandQS <> "") 
                        then "?" & expandQS
                        else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals(" & goalId & ")/goalValues(" & DateTimeZone.ToText(timestamp,[Format="O"]) & ")" & queryString)
    in
        result;
/*****************
    Goals
*****************/

/*** GetScorecardGoalsInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalsInGroup = Value.ReplaceType(
    GetScorecardGoalsInGroup,
    GetScorecardGoalsInGroupType
);

GetScorecardGoalsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),             
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports notes.",
            Documentation.SampleValues = {
                "goals($expand=goalValues, aggregations)"
            }
        ]
    ),
    optional select as (
        type number meta [
            Documentation.FieldCaption = "Select",
            Documentation.FieldDescription = "Allows the clients to select specific properties from the server.",
            Documentation.SampleValues = {
                "name,level"
            }
        ]
    )                  
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalsInGroup",
    Documentation.LongDescription = "Returns a list of goals from a scorecard.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalsInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",,""goals($expand=goalValues, aggregations)"",""name,level"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goals_(preview)/get#goals"
        ]
    }
];

GetScorecardGoalsInGroup = (optional groupdId as text, optional scorecardId as text, optional expand as text, optional select as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        selectQS = if(select <> null) then "$select=" & Text.Clean(Text.Replace(select," ","")) else "",
        // Figure out if we need to concatenate expand and select filters        
        queryString = if(expandQS <> "" and selectQS <> "") 
                        then "?" & expandQS & "&" & selectQS
                        else
                            // 10
                            if(expandQS <> "")
                                then 
                                    "?" & expandQS
                                else
                                // 01
                                    if(selectQS <> "")
                                        then
                                            "?" & selectQS
                                        else
                                            "",        
        
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals" & queryString)
    in
        result;
/*** End GetScorecardGoalsInGroup ***/

/*** GetScorecardGoalInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalInGroup = Value.ReplaceType(
    GetScorecardGoalInGroup,
    GetScorecardGoalInGroupType
);

GetScorecardGoalInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional goalId as (
        type text meta [
            Documentation.FieldCaption = "Goal ID",
            Documentation.FieldDescription = "The unique identifier of the goal",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    ),              
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports notes.",
            Documentation.SampleValues = {
                "goals($expand=goalValues, aggregations)"
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalInGroup",
    Documentation.LongDescription = "Returns a goal by ID from a scorecard.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."",""goals($expand=goalValues, aggregations)"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goalvalues_(preview)/get-by-id#goalvalue"
        ]
    }
];

GetScorecardGoalInGroup = (optional groupdId as text, optional scorecardId as text, optional goalId as text, optional expand as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(expandQS <> "") 
                        then "?" & expandQS
                        else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals(" & goalId & ")" & queryString)
    in
        result;
/*** End GetScorecardGoalInGroup ***/

/*** GetScorecardGoalRefreshHistoryInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalRefreshHistoryInGroup = Value.ReplaceType(
    GetScorecardGoalRefreshHistoryInGroup,
    GetScorecardGoalRefreshHistoryInGroupType
);

GetScorecardGoalRefreshHistoryInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional goalId as (
        type text meta [
            Documentation.FieldCaption = "Goal ID",
            Documentation.FieldDescription = "The unique identifier of the goal",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalRefreshHistoryInGroup",
    Documentation.LongDescription = "Reads refresh history of a connected goal.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalRefreshHistoryInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goals_(preview)/get-refresh-history#goalrefreshhistories"
        ]
    }
];

GetScorecardGoalRefreshHistoryInGroup = (optional groupdId as text, optional scorecardId as text, optional goalId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals(" & goalId & ")/GetRefreshHistory()")
    in
        result;
/*** EndScorecardGoalRefreshHistoryInGroup ***/


/*****************
    GoalStatusRules
*****************/

/*** GetScorecardGoalsStatusRulesInGroup ***/
shared PBIRESTAPIComm.GetScorecardGoalsStatusRulesInGroup = Value.ReplaceType(
    GetScorecardGoalsStatusRulesInGroup,
    GetScorecardGoalsStatusRulesInGroupType
);

GetScorecardGoalsStatusRulesInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional goalId as (
        type text meta [
            Documentation.FieldCaption = "Goal ID",
            Documentation.FieldDescription = "The unique identifier of the goal",
            Documentation.SampleValues = {
                "xxx-xxxx-ijkl..."
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardGoalsStatusRulesInGroup",
    Documentation.LongDescription = "Returns status rules of a goal.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardGoalsStatusRulesInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""xxx-xxxx-ijkl..."")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/goalsstatusrules_(preview)/get#goals.rules.goalstatusrules"
        ]
    }
];

GetScorecardGoalsStatusRulesInGroup = (optional groupdId as text, optional scorecardId as text, optional goalId as text) =>
    let
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")/goals(" & goalId & ")/statusRules")
    in
        result;
/*** End GetScorecardGoalStatusInGroup ***/

/*****************
    Scorecards
*****************/

/*** GetScorecardsInGroup ***/
shared PBIRESTAPIComm.GetScorecardsInGroup = Value.ReplaceType(
    GetScorecardsInGroup,
    GetScorecardsInGroupType
);

GetScorecardsInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional top as (
        type number meta [
            Documentation.FieldCaption = "Top",
            Documentation.FieldDescription = "Returns only the first n results.",
            Documentation.SampleValues = {
                "5"
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardsInGroup",
    Documentation.LongDescription = "Returns a list of scorecards from a workspace.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardsInGroup(""xxx-xxxx-abcd..."",""5"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get#scorecards"
        ]
    }
];

GetScorecardsInGroup = (optional groupdId as text, optional top as number) =>
    let
        //Build Query String
        topQS = if(top <> null) then "$top=" & Number.ToText(top) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(topQS <> "") 
                        then "?" & topQS
                        else "",

        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards" & queryString)
    in
        result;
/*** End GetScorecardsInGroup ***/

/*** GetScorecardInGroup ***/
shared PBIRESTAPIComm.GetScorecardInGroup = Value.ReplaceType(
    GetScorecardInGroup,
    GetScorecardInGroupType
);

GetScorecardInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional scorecardId as (
        type text meta [
            Documentation.FieldCaption = "Scorecard ID",
            Documentation.FieldDescription = "The unique identifier of the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),    
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports goals, goalValues, aggregations, and notes.",
            Documentation.SampleValues = {
                "goals($expand=goalValues, aggregations)"
            }
        ]
    )             
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardInGroup",
    Documentation.LongDescription = "Returns a scorecard with ID.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""goals($expand=goalValues, aggregations)"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get-by-id#scorecard"
        ]
    }
];

GetScorecardInGroup = (optional groupdId as text, optional scorecardId as text, optional expand as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(expandQS <> "") 
                        then "?" & expandQS
                        else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards(" & scorecardId & ")" & queryString)
    in
        result;
/*** End GetScorecardInGroup ***/

/*** GetScorecardByReportIdInGroup ***/
shared PBIRESTAPIComm.GetScorecardByReportIdInGroup = Value.ReplaceType(
    GetScorecardByReportIdInGroup,
    GetScorecardByReportIdInGroupType
);

GetScorecardByReportIdInGroupType = type function (
    optional groupdId as (
        type text meta [
            Documentation.FieldCaption = "Group ID",
            Documentation.FieldDescription = "The unique identifier of the workspace",
            Documentation.SampleValues = {
                "xxx-xxxx-abcd..."
            }
        ]
    ),
    optional reportId as (
        type text meta [
            Documentation.FieldCaption = "Report ID",
            Documentation.FieldDescription = "The ID of the internal report associated with the scorecard",
            Documentation.SampleValues = {
                "xxx-xxxx-efgh..."
            }
        ]
    ),
    optional expand as (
        type number meta [
            Documentation.FieldCaption = "Expand",
            Documentation.FieldDescription = "Accepts a comma-separated list of data types, which will be expanded inline in the response. Supports goals, goalValues, aggregations, and notes.",
            Documentation.SampleValues = {
                "goals($expand=goalValues, aggregations)"
            }
        ]
    )                 
) as table meta [
    Documentation.Name = "PBIRESTAPIComm.GetScorecardByReportIdInGroup",
    Documentation.LongDescription = "Reads a scorecard associated with an internal report ID.",
    Documentation.Examples = {
        [
            Code = "=PBIRESTAPIComm.GetScorecardInGroup(""xxx-xxxx-abcd..."",""xxx-xxxx-efgh..."",""goals($expand=goalValues, aggregations)"")",
            Result = "Defined as https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get-scorecard-by-report-id#scorecard"
        ]
    }
];

GetScorecardByReportIdInGroup = (optional groupdId as text, optional reportId as text, optional expand as text) =>
    let
        //Build Query String (clean input)
        expandQS = if(expand <> null) then "$expand=" & Text.Clean(Text.Replace(expand," ","")) else "",
        // Figure out if we need to concatenate top filter
        queryString = if(expandQS <> "") 
                        then "?" & expandQS
                        else "",
        // Now query with parameters
        result = GetJSON("v1.0/myorg/groups/" & groupdId & "/scorecards/GetScorecardByReportId(reportId=" & reportId & ")" & queryString)
    in
        result;
/*** End GetScorecardByReportIdInGroup ***/

/*****************
    HELPER FUNCTIONS
*****************/
BuildExecuteDaxRequestPayload = (
    query as text,
    optional applicationContext as nullable text,
    optional culture as nullable text,
    optional customData as nullable text,
    optional effectiveUsername as nullable text,
    optional memoryLimit as nullable number,
    optional queryTimeout as nullable number,
    optional resultSetRowCountLimit as nullable number,
    optional roles as nullable list,
    optional schemaOnly as nullable logical
) as record =>
    let
        rawPayload = [
            query = query,
            applicationContext = applicationContext,
            culture = culture,
            customData = customData,
            effectiveUsername = effectiveUsername,
            memoryLimit = memoryLimit,
            queryTimeout = queryTimeout,
            resultSetRowCountLimit = resultSetRowCountLimit,
            roles = roles,
            schemaOnly = schemaOnly
        ],
        nullFieldNames = List.Select(Record.FieldNames(rawPayload), each Record.Field(rawPayload, _) = null),
        payload = if List.Count(nullFieldNames) > 0 then Record.RemoveFields(rawPayload, nullFieldNames) else rawPayload
    in
        payload;

PostExecuteDax = (params as record) as table =>
    let
        webSource = Web.Contents(
            "https://api.powerbi.com",
            params
        ),
        headers = try Value.Metadata(webSource)[Headers] otherwise [],
        buffered = Binary.Buffer(webSource),
        result = ExecuteDaxResponseAsTable(buffered, headers)
    in
        result;

ExecuteDaxJsonToTable = (response as binary) as table =>
    let
        parseTry = try Json.Document(response),
        result =
            if parseTry[HasError] then
                #table(type table [response = text], {{Text.FromBinary(response)}})
            else
                let
                    payload = parseTry[Value],
                    root = if Value.Is(payload, type record) then payload else [],
                    resultsList = if Record.HasFields(root, "results") and Value.Is(root[results], type list) then root[results] else {},
                    firstResult = if List.Count(resultsList) > 0 and Value.Is(resultsList{0}, type record) then resultsList{0} else [],
                    tablesList = if Record.HasFields(firstResult, "tables") and Value.Is(firstResult[tables], type list) then firstResult[tables] else {},
                    firstTable = if List.Count(tablesList) > 0 and Value.Is(tablesList{0}, type record) then tablesList{0} else [],
                    rowsList = if Record.HasFields(firstTable, "rows") and Value.Is(firstTable[rows], type list) then firstTable[rows] else {},
                    columnsMeta = if Record.HasFields(firstTable, "columns") and Value.Is(firstTable[columns], type list) then firstTable[columns] else {},
                    columnsRaw = List.Transform(columnsMeta, each if Value.Is(_, type record) and Record.HasFields(_, "name") then Text.From(Record.Field(_, "name")) else null),
                    columnNames = List.RemoveNulls(columnsRaw),
                    tableResult =
                        if List.Count(rowsList) > 0 and Value.Is(rowsList{0}, type record) then
                            if List.Count(columnNames) > 0
                                then Table.FromRecords(rowsList, columnNames, MissingField.UseNull)
                                else Table.FromRecords(rowsList)
                        else if List.Count(columnNames) > 0 then
                            #table(columnNames, {})
                        else
                            #table(type table [response = text], {{Text.FromBinary(response)}})
                in
                    tableResult
    in
        result;

ExecuteDaxParseArrowResponse = (response as binary) as table =>
    ArrowFromBinary(response);

ExecuteDaxParseJsonResponse = (response as binary) as table =>
    ExecuteDaxJsonToTable(response);

ExecuteDaxDetectResponseKind = (response as binary, optional headers as nullable record) as text =>
    if ArrowDetectionIsArrowResponse(response, headers) then "Arrow" else "Json";

ExecuteDaxResponseAsTable = (response as binary, optional headers as nullable record) as table =>
    let
        responseKind = ExecuteDaxDetectResponseKind(response, headers),
        result = if responseKind = "Arrow"
                    then ExecuteDaxParseArrowResponse(response)
                    else ExecuteDaxParseJsonResponse(response)
    in
        result;

ArrowDetectionContentTypes = {
    "application/vnd.apache.arrow.stream",
    "application/vnd.apache.arrow.file",
    "application/octet-stream"
};

ArrowDetectionGetContentType = (optional headers as nullable record) as nullable text =>
    let
        h = if headers = null then [] else headers,
        contentType = if Record.HasFields(h, "Content-Type") then Record.Field(h, "Content-Type")
            else if Record.HasFields(h, "content-type") then Record.Field(h, "content-type")
            else null,
        normalized = if contentType = null then null else Text.Lower(Text.BeforeDelimiter(Text.From(contentType), ";"))
    in
        normalized;

ArrowDetectionHasArrowMagic = (payload as binary) as logical =>
    let
        head = try Text.Lower(Binary.ToText(Binary.Range(payload, 0, 6), BinaryEncoding.Hex)) otherwise "",
        tailOffset = Binary.Length(payload) - 6,
        tail = if tailOffset >= 0 then (try Text.Lower(Binary.ToText(Binary.Range(payload, tailOffset, 6), BinaryEncoding.Hex)) otherwise "") else ""
    in
        head = "4152524f5731" or tail = "4152524f5731";

ArrowDetectionIsArrowContentType = (optional headers as nullable record) as logical =>
    let
        contentType = ArrowDetectionGetContentType(headers)
    in
        contentType <> null and List.Contains(ArrowDetectionContentTypes, contentType);

ArrowDetectionIsArrowResponse = (payload as binary, optional headers as nullable record) as logical =>
    ArrowDetectionHasArrowMagic(payload) or ArrowDetectionIsArrowContentType(headers);

ArrowDetectionLooksLikeLz4Frame = (payload as binary) as logical =>
    let
        frameMagicHex = try Text.Lower(Binary.ToText(Binary.Range(payload, 0, 4), BinaryEncoding.Hex)) otherwise ""
    in
        frameMagicHex = "04224d18";

ArrowError = (message as text, module as text, stage as text, optional details as nullable record) as none =>
    let
        context = if details = null then [Module = module, Stage = stage] else Record.Combine({[Module = module, Stage = stage], details})
    in
        error Error.Record("Arrow", message, context);

ArrowReadUInt8 = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.Byte(Binary.Range(binary, offset, 1))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadUInt8", [Offset = offset, RequestedBytes = 1, Length = Binary.Length(binary)]) else r[Value];

ArrowReadInt16LE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger16, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 2))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadInt16LE", [Offset = offset, RequestedBytes = 2, Length = Binary.Length(binary)]) else r[Value];

ArrowReadUInt16LE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 2))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadUInt16LE", [Offset = offset, RequestedBytes = 2, Length = Binary.Length(binary)]) else r[Value];

ArrowReadInt32LE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 4))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadInt32LE", [Offset = offset, RequestedBytes = 4, Length = Binary.Length(binary)]) else r[Value];

ArrowReadUInt32LE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 4))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadUInt32LE", [Offset = offset, RequestedBytes = 4, Length = Binary.Length(binary)]) else r[Value];

ArrowReadInt64LE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 8))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadInt64LE", [Offset = offset, RequestedBytes = 8, Length = Binary.Length(binary)]) else r[Value];

ArrowReadSingleLE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.Single, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 4))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadSingleLE", [Offset = offset, RequestedBytes = 4, Length = Binary.Length(binary)]) else r[Value];

ArrowReadDoubleLE = (binary as binary, offset as number) as number =>
    let
        r = try BinaryFormat.ByteOrder(BinaryFormat.Double, ByteOrder.LittleEndian)(Binary.Range(binary, offset, 8))
    in
        if r[HasError] then ArrowError("Truncated binary read", "Arrow.Binary", "ReadDoubleLE", [Offset = offset, RequestedBytes = 8, Length = Binary.Length(binary)]) else r[Value];

ArrowAlign8 = (offset as number) as number =>
    let
        remainder = Number.Mod(offset, 8)
    in
        if remainder = 0 then offset else offset + (8 - remainder);

ArrowFBRootTableOffset = (binary as binary) as number =>
    ArrowReadUInt32LE(binary, 0);

ArrowFBVTableOffset = (binary as binary, objectPos as nullable number) as nullable number =>
    if objectPos = null then null else objectPos - ArrowReadInt32LE(binary, objectPos);

ArrowFBGetFieldPos = (binary as binary, objectPos as nullable number, fieldIndex as number) as nullable number =>
    if objectPos = null then null
    else
        let
            length = Binary.Length(binary),
            vtablePos = ArrowFBVTableOffset(binary, objectPos),
            vtableLength = if vtablePos = null or vtablePos + 1 >= length then 0 else ArrowReadUInt16LE(binary, vtablePos),
            objectInlineSize = if vtablePos = null or vtablePos + 3 >= length then 0 else ArrowReadUInt16LE(binary, vtablePos + 2),
            slotPos = if vtablePos = null then 0 else vtablePos + 4 + (2 * fieldIndex),
            fieldOffset = if vtablePos = null or slotPos + 1 >= vtablePos + vtableLength or slotPos + 1 >= length then 0 else ArrowReadUInt16LE(binary, slotPos),
            fieldPos = if fieldOffset = 0 or fieldOffset >= objectInlineSize then null else objectPos + fieldOffset
        in
            if fieldPos = null or fieldPos < 0 or fieldPos >= length then null else fieldPos;

ArrowFBGetTable = (binary as binary, fieldPos as nullable number) as nullable number =>
    if fieldPos = null then null
    else
        let
            length = Binary.Length(binary),
            inRange = fieldPos >= 0 and fieldPos + 3 < length,
            tablePos = if not inRange then null else fieldPos + ArrowReadUInt32LE(binary, fieldPos)
        in
            if tablePos = null or tablePos < 0 or tablePos >= length then null else tablePos;

ArrowFBIsValidTableObject = (binary as binary, objectPos as nullable number) as logical =>
    if objectPos = null then false
    else
        let
            length = Binary.Length(binary),
            inRange = objectPos >= 0 and objectPos + 3 < length,
            vtableDistance = if inRange then (try ArrowReadInt32LE(binary, objectPos) otherwise -1) else -1,
            vtablePos = objectPos - vtableDistance,
            vtableHeaderInRange = vtablePos >= 0 and vtablePos + 3 < length,
            vtableSize = if vtableHeaderInRange then (try ArrowReadUInt16LE(binary, vtablePos) otherwise 0) else 0,
            objectInlineSize = if vtableHeaderInRange then (try ArrowReadUInt16LE(binary, vtablePos + 2) otherwise 0) else 0,
            // FlatBuffers uses signed vtable offsets; they can be positive or negative, but not zero.
            // Also require sane vtable/object inline sizes to avoid accepting random pointer cells as tables.
            isValid =
                inRange and
                vtableDistance <> 0 and
                vtableHeaderInRange and
                vtableSize >= 4 and
                objectInlineSize >= 4 and
                vtablePos + vtableSize <= length and
                objectPos + objectInlineSize <= length
        in
            isValid;

ArrowFBNormalizeTableObject = (binary as binary, objectPos as nullable number) as nullable number =>
    if objectPos = null then null
    else if ArrowFBIsValidTableObject(binary, objectPos) then objectPos
    else null;

ArrowFBReadString = (binary as binary, fieldPos as nullable number) as nullable text =>
    if fieldPos = null then null
    else
        let
            stringPos = fieldPos + ArrowReadUInt32LE(binary, fieldPos),
            length = ArrowReadInt32LE(binary, stringPos),
            value = if length <= 0 then "" else Text.FromBinary(Binary.Range(binary, stringPos + 4, length), TextEncoding.Utf8)
        in
            value;

ArrowFBReadScalarInt16 = (binary as binary, objectPos as nullable number, fieldIndex as number, defaultValue as number) as number =>
    if objectPos = null then defaultValue
    else
        let
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex)
        in
            if fieldPos = null then defaultValue else ArrowReadInt16LE(binary, fieldPos);

ArrowFBReadScalarUInt8 = (binary as binary, objectPos as nullable number, fieldIndex as number, defaultValue as number) as number =>
    if objectPos = null then defaultValue
    else
        let
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex)
        in
            if fieldPos = null then defaultValue else ArrowReadUInt8(binary, fieldPos);

ArrowFBReadScalarInt32 = (binary as binary, objectPos as nullable number, fieldIndex as number, defaultValue as number) as number =>
    if objectPos = null then defaultValue
    else
        let
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex)
        in
            if fieldPos = null then defaultValue else ArrowReadInt32LE(binary, fieldPos);

ArrowFBReadScalarInt64 = (binary as binary, objectPos as nullable number, fieldIndex as number, defaultValue as number) as number =>
    if objectPos = null then defaultValue
    else
        let
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex)
        in
            if fieldPos = null then defaultValue
            else
                let
                    readTry = try ArrowReadInt64LE(binary, fieldPos)
                in
                    if readTry[HasError]
                        then ArrowError(
                            "Failed to read Int64 scalar",
                            "Arrow.Flatbuffers",
                            "ReadScalarInt64",
                            [
                                ObjectPos = objectPos,
                                FieldIndex = fieldIndex,
                                FieldPos = fieldPos,
                                BinaryLength = Binary.Length(binary),
                                ErrorReason = try readTry[Error][Reason] otherwise null,
                                ErrorMessage = try readTry[Error][Message] otherwise ""
                            ]
                        )
                        else readTry[Value];

ArrowFBReadScalarBool = (binary as binary, objectPos as nullable number, fieldIndex as number, defaultValue as logical) as logical =>
    if objectPos = null then defaultValue
    else
        let
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex)
        in
            if fieldPos = null then defaultValue else ArrowReadUInt8(binary, fieldPos) <> 0;

ArrowFBGetVector = (binary as binary, objectPos as nullable number, fieldIndex as number) as record =>
    if objectPos = null then [Count = 0, ValuesPos = null]
    else
        let
            length = Binary.Length(binary),
            fieldPos = ArrowFBGetFieldPos(binary, objectPos, fieldIndex),
            vectorPos = if fieldPos = null or fieldPos + 3 >= length then null else fieldPos + ArrowReadUInt32LE(binary, fieldPos),
            vectorHeaderInRange = vectorPos <> null and vectorPos >= 0 and vectorPos + 3 < length,
            count = if not vectorHeaderInRange then 0 else ArrowReadInt32LE(binary, vectorPos),
            valuesPos = if not vectorHeaderInRange then null else vectorPos + 4
        in
            [Count = count, ValuesPos = valuesPos];

ArrowFBVectorTableObject = (binary as binary, vectorValuesPos as nullable number, index as number) as nullable number =>
    if vectorValuesPos = null then null
    else
        let
            elementPos = vectorValuesPos + (index * 4)
        in
            elementPos + ArrowReadUInt32LE(binary, elementPos);

ArrowParseType = (metadata as binary, typeType as number, typeObj as nullable number) as record =>
    let
        // Force evaluation by computing all values first
        kind = if typeType = 2 then "Int"
            else if typeType = 3 then "FloatingPoint"
            else if typeType = 4 then "Binary"
            else if typeType = 5 then "Utf8"
            else if typeType = 6 then "Bool"
            else if typeType = 8 then "Date"
            else if typeType = 10 then "Timestamp"
            else null,
        result = if kind = null then ArrowError("Unsupported Arrow type", "Arrow.Schema", "Type", [TypeId = typeType])
            else if kind = "Int" then
                Record.FromList({kind, if typeObj = null then 32 else ArrowFBReadScalarInt32(metadata, typeObj, 0, 32), if typeObj = null then true else ArrowFBReadScalarBool(metadata, typeObj, 1, true)}, {"Kind", "BitWidth", "IsSigned"})
            else if kind = "FloatingPoint" then
                Record.FromList({kind, if typeObj = null then 2 else ArrowFBReadScalarUInt8(metadata, typeObj, 0, 2)}, {"Kind", "Precision"})
            else if kind = "Binary" or kind = "Utf8" or kind = "Bool" then
                Record.FromList({kind}, {"Kind"})
            else if kind = "Date" then
                Record.FromList({kind, if typeObj = null then 0 else ArrowFBReadScalarInt16(metadata, typeObj, 0, 0)}, {"Kind", "Unit"})
            else // Timestamp
                Record.FromList({kind, if typeObj = null then 1 else ArrowFBReadScalarInt16(metadata, typeObj, 0, 1), if typeObj = null then null else ArrowFBReadString(metadata, ArrowFBGetFieldPos(metadata, typeObj, 1))}, {"Kind", "Unit", "Timezone"})
    in
        result;

ArrowParseField = (metadata as binary, fieldObj as nullable number) as record =>
    if fieldObj = null then ArrowError("Field object position is null", "Arrow.Schema", "FieldObj")
    else
        let
            parseTry = try
                let
                    name = ArrowFBReadString(metadata, ArrowFBGetFieldPos(metadata, fieldObj, 0)),
                    typeType = ArrowFBReadScalarUInt8(metadata, fieldObj, 2, 0),
                    typeObj = ArrowFBGetTable(metadata, ArrowFBGetFieldPos(metadata, fieldObj, 3)),
                    dictionaryObj = ArrowFBGetTable(metadata, ArrowFBGetFieldPos(metadata, fieldObj, 4)),
                    parsedType = ArrowParseType(metadata, typeType, typeObj),
                    // Force dictionary evaluation
                    dictId = if dictionaryObj = null then null else ArrowFBReadScalarInt64(metadata, dictionaryObj, 0, 0),
                    dictIndexTypeObj = if dictionaryObj = null then null else ArrowFBGetTable(metadata, ArrowFBGetFieldPos(metadata, dictionaryObj, 1)),
                    dictIndexType = if dictionaryObj = null then null else ArrowParseType(metadata, 2, dictIndexTypeObj),
                    dictionary = if dictionaryObj = null then null
                        else Record.FromList({dictId, dictIndexType}, {"Id", "IndexType"}),
                    childrenVector = ArrowFBGetVector(metadata, fieldObj, 5),
                    _childrenCheck = if childrenVector[Count] > 0 and childrenVector[ValuesPos] = null
                        then ArrowError("Children vector has count but null ValuesPos", "Arrow.Schema", "ChildrenVector", [Count = childrenVector[Count], FieldName = name])
                        else true,
                    children = if childrenVector[Count] = 0
                        then {}
                        else List.Transform({0..childrenVector[Count]-1}, each @ArrowParseField(metadata, ArrowFBVectorTableObject(metadata, childrenVector[ValuesPos], _))),
                    // Force evaluation by using Record.FromList
                    fieldRecord = Record.FromList({if name = null then "Column" else name, parsedType, dictionary, children}, {"Name", "Type", "Dictionary", "Children"})
                in
                    if List.Count(children) > 0
                        then ArrowError("Nested Arrow fields are not supported", "Arrow.Schema", "Field", [Field = name])
                        else fieldRecord
        in
            if parseTry[HasError]
                then ArrowError("Field parsing failed", "Arrow.Schema", "FieldParse", [FieldObj = fieldObj, ErrorReason = try parseTry[Error][Reason] otherwise null, ErrorMessage = try parseTry[Error][Message] otherwise ""])
                else parseTry[Value];

ArrowParseSchema = (metadata as binary, schemaObj as nullable number) as list =>
    if schemaObj = null then error Error.Record("Expression.Error", "Schema object position is null")
    else
        let
            step1 = try ArrowFBGetVector(metadata, schemaObj, 1),
            _step1Check = if step1[HasError] then error Error.Record("Expression.Error", "Schema step1 failed", step1[Error]) else null,
            fieldsVector = step1[Value],
            step2Count = try fieldsVector[Count],
            _step2Check = if step2Count[HasError] then error Error.Record("Expression.Error", "Schema step2 Count failed", step2Count[Error]) else null,
            step2ValuesPos = try fieldsVector[ValuesPos],
            _step2VPCheck = if step2ValuesPos[HasError] then error Error.Record("Expression.Error", "Schema step2 ValuesPos failed", step2ValuesPos[Error]) else null,
            _vectorCheck = if step2Count[Value] > 0 and step2ValuesPos[Value] = null
                then ArrowError("Schema fields vector has count but null ValuesPos", "Arrow.Schema", "FieldsVector", [Count = step2Count[Value]])
                else true,
            // Parse each field with index for error tracking
            parseFieldAt = (index as number) =>
                let
                    fieldObjTry = try ArrowFBVectorTableObject(metadata, fieldsVector[ValuesPos], index),
                    fieldObj = if fieldObjTry[HasError]
                        then ArrowError("Field object lookup failed", "Arrow.Schema", "FieldLookup", [Index = index, ErrorMessage = try fieldObjTry[Error][Message] otherwise ""])
                        else fieldObjTry[Value],
                    fieldTry = try ArrowParseField(metadata, fieldObj),
                    field = if fieldTry[HasError]
                        then ArrowError("Field parse failed at index", "Arrow.Schema", "FieldIndex", [Index = index, FieldObj = fieldObj, ErrorMessage = try fieldTry[Error][Message] otherwise ""])
                        else fieldTry[Value]
                in
                    field,
            step3CountMinus1 = try (step2Count[Value] - 1),
            _step3Check = if step3CountMinus1[HasError] then error Error.Record("Expression.Error", "Schema step3 Count-1 failed: " & (try Text.From(step2Count[Value]) otherwise "NULL"), step3CountMinus1[Error]) else null,
            fields = if step2Count[Value] = 0
                then {}
                else List.Buffer(List.Transform({0..step3CountMinus1[Value]}, each parseFieldAt(_)))
        in
            fields;

ArrowParseFieldNode = (metadata as binary, nodeObj as number) as record =>
    [Length = ArrowReadInt64LE(metadata, nodeObj), NullCount = ArrowReadInt64LE(metadata, nodeObj + 8)];

ArrowParseBuffer = (metadata as binary, bufferObj as number) as record =>
    [Offset = ArrowReadInt64LE(metadata, bufferObj), Length = ArrowReadInt64LE(metadata, bufferObj + 8)];

ArrowParseRecordBatch = (metadata as binary, recordBatchObj as number) as record =>
    let
        metadataLength = Binary.Length(metadata),
        compressionObj = ArrowFBGetTable(metadata, ArrowFBGetFieldPos(metadata, recordBatchObj, 3)),
        _compressionCheck = if compressionObj <> null then ArrowError("Compressed Arrow bodies are not supported", "Arrow.RecordBatch", "Compression") else true,
        lengthFieldPos = ArrowFBGetFieldPos(metadata, recordBatchObj, 0),
        lengthValue =
            if lengthFieldPos = null then 0
            else if lengthFieldPos < 0 or lengthFieldPos + 7 >= metadataLength
                then ArrowError(
                    "RecordBatch length field is out of range",
                    "Arrow.RecordBatch",
                    "LengthField",
                    [
                        RecordBatchObj = recordBatchObj,
                        LengthFieldPos = lengthFieldPos,
                        MetadataLength = metadataLength,
                        VTablePos = try ArrowFBVTableOffset(metadata, recordBatchObj) otherwise null,
                        VTableSize = try ArrowReadUInt16LE(metadata, ArrowFBVTableOffset(metadata, recordBatchObj)) otherwise null,
                        ObjectInlineSize = try ArrowReadUInt16LE(metadata, ArrowFBVTableOffset(metadata, recordBatchObj) + 2) otherwise null
                    ]
                )
                else ArrowReadInt64LE(metadata, lengthFieldPos),
        nodeVector = ArrowFBGetVector(metadata, recordBatchObj, 1),
        bufferVector = ArrowFBGetVector(metadata, recordBatchObj, 2),
        _nodeVectorCheck = if nodeVector[Count] > 0 and nodeVector[ValuesPos] = null
            then ArrowError("Node vector has count but null ValuesPos", "Arrow.RecordBatch", "NodeVector", [Count = nodeVector[Count]])
            else true,
        _bufferVectorCheck = if bufferVector[Count] > 0 and bufferVector[ValuesPos] = null
            then ArrowError("Buffer vector has count but null ValuesPos", "Arrow.RecordBatch", "BufferVector", [Count = bufferVector[Count]])
            else true,
        nodes = if nodeVector[Count] = 0 then {} else List.Transform({0..nodeVector[Count]-1}, each ArrowParseFieldNode(metadata, nodeVector[ValuesPos] + (_ * 16))),
        buffers = if bufferVector[Count] = 0 then {} else List.Transform({0..bufferVector[Count]-1}, each ArrowParseBuffer(metadata, bufferVector[ValuesPos] + (_ * 16))),
        result = [Length = lengthValue, Nodes = nodes, Buffers = buffers]
    in
        result;

// Diagnostic function - returns raw values without throwing, for debugging null issues
// Uses ONLY primitive Binary operations - no helper functions
ArrowDiagnoseRecordBatch = (metadata as binary, recordBatchObj as number) as record =>
    let
        metaLen = Binary.Length(metadata),
        objPos = recordBatchObj,
        objInBounds = objPos + 4 <= metaLen,
        // Manually read the recordBatch vtable offset (int32 at recordBatchObj)
        vtableDistanceBytes = if not objInBounds then null else try Binary.Range(metadata, objPos, 4) otherwise null,
        vtableDistance = if vtableDistanceBytes = null then "BYTES_NULL" else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian)(vtableDistanceBytes) otherwise "FORMAT_ERROR",
        vtableDistanceIsNum = (try Value.Type(vtableDistance) = type number otherwise false),
        vtablePos = if not vtableDistanceIsNum then "CALC_ERROR" else objPos - vtableDistance,
        vtablePosIsNum = (try Value.Type(vtablePos) = type number otherwise false),
        // Read vtable: size(2) + inlineSize(2) + field offsets
        vtableSizeBytes = if not vtablePosIsNum then null else try Binary.Range(metadata, vtablePos, 2) otherwise null,
        vtableSize = if vtableSizeBytes = null then "BYTES_NULL" else try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian)(vtableSizeBytes) otherwise "FORMAT_ERROR",
        // Field 1 offset (nodes vector) - at vtablePos + 4 + 2*1 = vtablePos + 6
        nodesSlotPos = if not vtablePosIsNum then "CALC_ERROR" else vtablePos + 6,
        nodesOffsetBytes = if nodesSlotPos = "CALC_ERROR" then null else try Binary.Range(metadata, nodesSlotPos, 2) otherwise null,
        nodesOffset = if nodesOffsetBytes = null then "BYTES_NULL" else try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian)(nodesOffsetBytes) otherwise "FORMAT_ERROR",
        nodesOffsetIsNum = (try Value.Type(nodesOffset) = type number otherwise false),
        nodesFieldPos = if not nodesOffsetIsNum or nodesOffset = 0 then null else objPos + nodesOffset,
        // Read vector pointer at nodesFieldPos (uint32)
        nodesPtrBytes = if nodesFieldPos = null then null else try Binary.Range(metadata, nodesFieldPos, 4) otherwise null,
        nodesPtr = if nodesPtrBytes = null then "BYTES_NULL" else try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian)(nodesPtrBytes) otherwise "FORMAT_ERROR",
        nodesPtrIsNum = (try Value.Type(nodesPtr) = type number otherwise false),
        nodesVectorPos = if not nodesPtrIsNum or nodesFieldPos = null then null else nodesFieldPos + nodesPtr,
        // Read nodes count (int32 at nodesVectorPos)
        nodesCountBytes = if nodesVectorPos = null then null else try Binary.Range(metadata, nodesVectorPos, 4) otherwise null,
        nodesCount = if nodesCountBytes = null then "BYTES_NULL" else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian)(nodesCountBytes) otherwise "FORMAT_ERROR",
        nodesCountIsNum = (try Value.Type(nodesCount) = type number otherwise false),
        nodesValuesPos = if nodesVectorPos = null then null else nodesVectorPos + 4,
        // Sample first node (16 bytes)
        firstNodeBytes = if nodesValuesPos = null or not nodesCountIsNum or nodesCount <= 0 then null 
            else try Binary.Range(metadata, nodesValuesPos, 16) otherwise null,
        firstNodeHex = if firstNodeBytes = null then "NO_DATA" else try Binary.ToText(firstNodeBytes, BinaryEncoding.Hex) otherwise "HEX_ERROR",
        // Parse first node's Length and NullCount as Int64
        firstNodeLength = if firstNodeBytes = null then "NO_DATA" 
            else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64, ByteOrder.LittleEndian)(Binary.Range(firstNodeBytes, 0, 8)) otherwise "FORMAT_ERROR",
        firstNodeNullCount = if firstNodeBytes = null then "NO_DATA"
            else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64, ByteOrder.LittleEndian)(Binary.Range(firstNodeBytes, 8, 8)) otherwise "FORMAT_ERROR"
    in
        [
            MetadataLength = metaLen,
            RecordBatchObj = objPos,
            VTablePos = vtablePos,
            VTableSize = vtableSize,
            NodesSlotPos = nodesSlotPos,
            NodesOffset = nodesOffset,
            NodesFieldPos = nodesFieldPos,
            NodesPtr = nodesPtr,
            NodesVectorPos = nodesVectorPos,
            NodesCount = nodesCount,
            NodesValuesPos = nodesValuesPos,
            FirstNodeHex = firstNodeHex,
            FirstNodeLength = firstNodeLength,
            FirstNodeNullCount = firstNodeNullCount
        ];

// Diagnostic for schema - to check field types
ArrowDiagnoseSchema = (schema) as record =>
    let
        mainTry = try
            let
                // First, try just getting the count without evaluating any items
                countTry = try List.Count(schema) otherwise -1,
                // Try to get each item's Name field one at a time - force evaluation with Text.From
                item0Name = if countTry <= 0 then "NO_ITEMS" else try Text.From(schema{0}[Name]) otherwise "ITEM0_FAILED",
                item1Name = if countTry <= 1 then "NO_ITEM1" else try Text.From(schema{1}[Name]) otherwise "ITEM1_FAILED",
                item2Name = if countTry <= 2 then "NO_ITEM2" else try Text.From(schema{2}[Name]) otherwise "ITEM2_FAILED",
                item3Name = if countTry <= 3 then "NO_ITEM3" else try Text.From(schema{3}[Name]) otherwise "ITEM3_FAILED",
                item4Name = if countTry <= 4 then "NO_ITEM4" else try Text.From(schema{4}[Name]) otherwise "ITEM4_FAILED"
            in
                [
                    SchemaCount = countTry,
                    Item0Name = item0Name,
                    Item1Name = item1Name,
                    Item2Name = item2Name,
                    Item3Name = item3Name,
                    Item4Name = item4Name
                ]
    in
        if mainTry[HasError]
            then [SchemaMainError = try mainTry[Error][Message] otherwise "unknown", SchemaErrorReason = try mainTry[Error][Reason] otherwise "unknown"]
            else mainTry[Value];

// Diagnostic for buffers - separate to avoid JSON size issues
ArrowDiagnoseBuffers = (metadata as binary, recordBatchObj as number) as record =>
    let
        metaLen = Binary.Length(metadata),
        objPos = recordBatchObj,
        // Read vtable
        vtableDistanceBytes = try Binary.Range(metadata, objPos, 4) otherwise null,
        vtableDistance = if vtableDistanceBytes = null then 0 else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian)(vtableDistanceBytes) otherwise 0,
        vtablePos = objPos - vtableDistance,
        // Field 2 offset (buffers vector) - at vtablePos + 4 + 2*2 = vtablePos + 8
        buffersSlotPos = vtablePos + 8,
        buffersOffsetBytes = try Binary.Range(metadata, buffersSlotPos, 2) otherwise null,
        buffersOffset = if buffersOffsetBytes = null then 0 else try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian)(buffersOffsetBytes) otherwise 0,
        buffersFieldPos = if buffersOffset = 0 then null else objPos + buffersOffset,
        // Read vector pointer at buffersFieldPos (uint32)
        buffersPtrBytes = if buffersFieldPos = null then null else try Binary.Range(metadata, buffersFieldPos, 4) otherwise null,
        buffersPtr = if buffersPtrBytes = null then 0 else try BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian)(buffersPtrBytes) otherwise 0,
        buffersVectorPos = if buffersFieldPos = null then null else buffersFieldPos + buffersPtr,
        // Read buffers count (int32 at buffersVectorPos)
        buffersCountBytes = if buffersVectorPos = null then null else try Binary.Range(metadata, buffersVectorPos, 4) otherwise null,
        buffersCount = if buffersCountBytes = null then 0 else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian)(buffersCountBytes) otherwise 0,
        buffersValuesPos = if buffersVectorPos = null then null else buffersVectorPos + 4,
        // Sample first few buffers (16 bytes each: offset int64 + length int64)
        firstBufferBytes = if buffersValuesPos = null or buffersCount <= 0 then null 
            else try Binary.Range(metadata, buffersValuesPos, 16) otherwise null,
        firstBufferOffset = if firstBufferBytes = null then "NO_DATA"
            else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64, ByteOrder.LittleEndian)(Binary.Range(firstBufferBytes, 0, 8)) otherwise "FORMAT_ERROR",
        firstBufferLength = if firstBufferBytes = null then "NO_DATA"
            else try BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64, ByteOrder.LittleEndian)(Binary.Range(firstBufferBytes, 8, 8)) otherwise "FORMAT_ERROR"
    in
        [
            BuffersSlotPos = buffersSlotPos,
            BuffersOffset = buffersOffset,
            BuffersFieldPos = buffersFieldPos,
            BuffersPtr = buffersPtr,
            BuffersVectorPos = buffersVectorPos,
            BuffersCount = buffersCount,
            BuffersValuesPos = buffersValuesPos,
            FirstBufferOffset = firstBufferOffset,
            FirstBufferLength = firstBufferLength
        ];

ArrowBitmapIsSet = (bitmap as binary, index as number) as logical =>
    let
        byteIndex = Number.IntegerDivide(index, 8),
        bitIndex = Number.Mod(index, 8),
        byteValue = ArrowReadUInt8(bitmap, byteIndex),
        mask = Number.Power(2, bitIndex)
    in
        Number.BitwiseAnd(byteValue, mask) <> 0;

ArrowGetBufferSlice = (body as binary, buffers as list, bufferIndex as number) as binary =>
    let
        b = buffers{bufferIndex},
        _lengthCheck = if b[Length] = null then ArrowError("Buffer length is null", "Arrow.RecordBatch", "Buffer", [BufferIndex = bufferIndex]) else true,
        _offsetCheck = if b[Offset] = null then ArrowError("Buffer offset is null", "Arrow.RecordBatch", "Buffer", [BufferIndex = bufferIndex]) else true,
        len = Number.From(b[Length]),
        off = Number.From(b[Offset])
    in
        if len <= 0 then #binary({}) else Binary.Range(body, off, len);

ArrowEpochDate = #date(1970, 1, 1);
ArrowEpochDateTime = #datetime(1970, 1, 1, 0, 0, 0);

ArrowDecodePrimitiveValue = (data as binary, valueIndex as number, fieldType as record) as any =>
    let
        kind = if fieldType[Kind] = null then ArrowError("PrimitiveValue fieldType[Kind] is null", "Arrow.Arrays", "Primitive") else fieldType[Kind],
        value =
            if kind = "Int" then
                let
                    bitWidth = if fieldType[BitWidth] = null then 32 else fieldType[BitWidth],
                    isSigned = if fieldType[IsSigned] = null then true else fieldType[IsSigned],
                    offset = if bitWidth = 8 then valueIndex else valueIndex * Number.IntegerDivide(bitWidth, 8)
                in
                    if bitWidth = 8 then
                        let
                            b = ArrowReadUInt8(data, offset)
                        in
                            if isSigned and b >= 128 then b - 256 else b
                    else if bitWidth = 16 then
                        if isSigned then ArrowReadInt16LE(data, offset)
                        else ArrowReadUInt16LE(data, offset)
                    else if bitWidth = 32 then
                        if isSigned then ArrowReadInt32LE(data, offset)
                        else ArrowReadUInt32LE(data, offset)
                    else if bitWidth = 64 then
                        ArrowReadInt64LE(data, offset)
                    else ArrowError("Unsupported integer bit width", "Arrow.Arrays", "Int", [BitWidth = bitWidth])
            else if kind = "FloatingPoint" then
                let
                    precision = if fieldType[Precision] = null then 2 else fieldType[Precision],
                    offset = if precision = 1 then valueIndex * 4 else valueIndex * 8
                in
                    if precision = 1 then ArrowReadSingleLE(data, offset)
                    else if precision = 2 then ArrowReadDoubleLE(data, offset)
                    else ArrowError("Unsupported floating point precision", "Arrow.Arrays", "FloatingPoint", [Precision = precision])
            else if kind = "Date" then
                let
                    unit = if fieldType[Unit] = null then 0 else fieldType[Unit],
                    offset = valueIndex * 4,
                    raw = ArrowReadInt32LE(data, offset)
                in
                    if unit = 0 then Date.AddDays(ArrowEpochDate, raw)
                    else DateTime.From(ArrowEpochDateTime + #duration(0, 0, 0, Number.From(raw) / 1000.0))
            else if kind = "Timestamp" then
                let
                    unit = if fieldType[Unit] = null then 0 else fieldType[Unit],
                    raw = ArrowReadInt64LE(data, valueIndex * 8),
                    seconds = if unit = 0 then Number.From(raw)
                        else if unit = 1 then Number.From(raw) / 1000.0
                        else if unit = 2 then Number.From(raw) / 1000000.0
                        else Number.From(raw) / 1000000000.0
                in
                    DateTime.From(ArrowEpochDateTime + #duration(0, 0, 0, seconds))
            else
                ArrowError("Unsupported primitive Arrow type", "Arrow.Arrays", "Primitive", [Kind = kind])
    in
        value;

ArrowDictionaryKey = (dictionaryId as number) as text =>
    Text.From(dictionaryId);

ArrowDictionaryGet = (dictionaries as record, dictionaryId as number) as list =>
    let
        key = ArrowDictionaryKey(dictionaryId)
    in
        if Record.HasFields(dictionaries, key)
            then Record.Field(dictionaries, key)
            else ArrowError("Missing dictionary for encoded field", "Arrow.Stream", "DictionaryLookup", [DictionaryId = dictionaryId]);

ArrowDictionaryTryGet = (dictionaries as record, dictionaryId as number) as nullable list =>
    let
        key = ArrowDictionaryKey(dictionaryId)
    in
        if Record.HasFields(dictionaries, key)
            then Record.Field(dictionaries, key)
            else null;

ArrowDictionarySet = (dictionaries as record, dictionaryId as number, values as list) as record =>
    let
        key = ArrowDictionaryKey(dictionaryId)
    in
        if Record.HasFields(dictionaries, key)
            then Record.AddField(Record.RemoveFields(dictionaries, {key}), key, values)
            else Record.AddField(dictionaries, key, values);

ArrowValidateDictionaryBatch = (dictionaryBatch as any) as record =>
    let
        _recordCheck = if Value.Is(dictionaryBatch, type record)
            then true
            else ArrowError("DictionaryBatch payload must be a record", "Arrow.Stream", "DictionaryBatchValidation", [ActualType = Value.Type(dictionaryBatch)]),
        _idCheck = if Record.HasFields(dictionaryBatch, "Id") and Value.Is(dictionaryBatch[Id], Number.Type)
            then true
            else ArrowError("DictionaryBatch Id is missing or invalid", "Arrow.Stream", "DictionaryBatchValidation", [DictionaryBatch = dictionaryBatch]),
        _dataCheck = if Record.HasFields(dictionaryBatch, "Data") and Value.Is(dictionaryBatch[Data], Number.Type)
            then true
            else ArrowError("DictionaryBatch Data pointer is missing or invalid", "Arrow.Stream", "DictionaryBatchValidation", [DictionaryBatch = dictionaryBatch]),
        _deltaCheck = if Record.HasFields(dictionaryBatch, "IsDelta") and Value.Is(dictionaryBatch[IsDelta], Logical.Type)
            then true
            else ArrowError("DictionaryBatch IsDelta flag is missing or invalid", "Arrow.Stream", "DictionaryBatchValidation", [DictionaryBatch = dictionaryBatch])
    in
        [
            Id = Number.From(dictionaryBatch[Id]),
            Data = Number.From(dictionaryBatch[Data]),
            IsDelta = dictionaryBatch[IsDelta]
        ];

ArrowMergeDictionaryValues = (dictionaries as record, dictionaryId as number, isDelta as logical, dictionaryValues as list) as record =>
    let
        previousValues = if isDelta and Record.HasFields(dictionaries, ArrowDictionaryKey(dictionaryId))
            then ArrowDictionaryGet(dictionaries, dictionaryId)
            else {},
        mergedValues = if isDelta then previousValues & dictionaryValues else dictionaryValues
    in
        ArrowDictionarySet(dictionaries, dictionaryId, mergedValues);

ArrowFindDictionaryField = (schema as list, dictionaryId as number) as record =>
    let
        matches = List.Select(schema, each Record.HasFields(_, "Dictionary") and _[Dictionary] <> null and _[Dictionary][Id] = dictionaryId)
    in
        if List.Count(matches) = 0
            then ArrowError("Dictionary id not found in schema", "Arrow.Schema", "Dictionary", [DictionaryId = dictionaryId])
            else matches{0};

ArrowDecodeColumn = (body as binary, field as record, node as record, buffers as list, nodeIndex as number, bufferIndex as number, dictionaries as record) as record =>
    let
        _fieldTypeCheck = if field[Type] = null then ArrowError("Field type is null", "Arrow.RecordBatch", "FieldType", [Field = field[Name], NodeIndex = nodeIndex]) else true,
        _fieldKindCheck = if field[Type][Kind] = null then ArrowError("Field type kind is null", "Arrow.RecordBatch", "FieldType", [Field = field[Name], NodeIndex = nodeIndex]) else true,
        _nodeLengthCheck = if node[Length] = null then ArrowError("Field node length is null", "Arrow.RecordBatch", "FieldNodes", [Field = field[Name], NodeIndex = nodeIndex]) else true,
        rowCount = Number.From(node[Length]),
        rowIndexes = if rowCount <= 0 then {} else {0..rowCount-1},
        validity = ArrowGetBufferSlice(body, buffers, bufferIndex),
        hasValidity = Binary.Length(validity) > 0,
        base = [NextNodeIndex = nodeIndex + 1, NextBufferIndex = bufferIndex + 2, Name = field[Name]],
        kind = field[Type][Kind],
        dictionaryMeta = if Record.HasFields(field, "Dictionary") then field[Dictionary] else null,
        decoded =
            if dictionaryMeta <> null then
                let
                    _indexTypeCheck = if dictionaryMeta[IndexType] = null
                        then ArrowError("Dictionary IndexType is null", "Arrow.Arrays", "DictionaryIndex", [Field = field[Name]])
                        else true,
                    _dictionaryIdCheck = if dictionaryMeta[Id] = null
                        then ArrowError("Dictionary Id is null", "Arrow.Arrays", "DictionaryIndex", [Field = field[Name]])
                        else true,
                    dataBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 1),
                    bitWidth = if dictionaryMeta[IndexType][BitWidth] = null then 32 else dictionaryMeta[IndexType][BitWidth],
                    minBytes = if bitWidth = 8 then rowCount else rowCount * Number.IntegerDivide(bitWidth, 8),
                    _sizeCheck = if Binary.Length(dataBuffer) < minBytes
                        then ArrowError("Dictionary index buffer too small", "Arrow.Arrays", "DictionaryIndex", [Field = field[Name], ExpectedBytes = minBytes, ActualBytes = Binary.Length(dataBuffer), RowCount = rowCount])
                        else true,
                    dictionaryValues = ArrowDictionaryTryGet(dictionaries, dictionaryMeta[Id]),
                    hasDictionary = dictionaryValues <> null,
                    _dictionaryPresenceCheck = if hasDictionary
                        then true
                        else ArrowError("Dictionary values were not loaded", "Arrow.Arrays", "DictionaryIndex", [Field = field[Name], DictionaryId = dictionaryMeta[Id]]),
                    dictionaryCount = if hasDictionary then List.Count(dictionaryValues) else 0,
                    indexValues =
                        if _sizeCheck = true and _dictionaryPresenceCheck = true then
                            List.Transform(rowIndexes, (i) =>
                                let
                                    isValid = if hasValidity then ArrowBitmapIsSet(validity, i) else true
                                in
                                    if not isValid then null else Number.RoundTowardZero(Number.From(ArrowDecodePrimitiveValue(dataBuffer, i, dictionaryMeta[IndexType])))
                            )
                        else {},
                    nonNullIndexes = List.RemoveNulls(indexValues),
                    _indexDomainCheck = if List.AllTrue(List.Transform(nonNullIndexes, each _ >= 0 and _ <= dictionaryCount))
                        then true
                        else ArrowError("Dictionary index domain check failed", "Arrow.Arrays", "DictionaryIndex", [DictionaryId = dictionaryMeta[Id], DictionaryCount = dictionaryCount]),
                    values =
                        if _sizeCheck = true and _dictionaryPresenceCheck = true then
                            List.Transform(rowIndexes, (i) =>
                                let
                                    indexValue = indexValues{i},
                                    mapped =
                                        if indexValue = null then null
                                        else
                                            let
                                                indexInt = indexValue,
                                                adjustedIndex =
                                                    if indexInt >= 0 and indexInt < dictionaryCount then indexInt
                                                    else if indexInt >= 1 and indexInt <= dictionaryCount then indexInt - 1
                                                    else -1
                                            in
                                                if adjustedIndex >= 0 and adjustedIndex < dictionaryCount
                                                    then dictionaryValues{adjustedIndex}
                                                    else ArrowError("Dictionary index out of range", "Arrow.Arrays", "DictionaryIndex", [Index = indexInt, DictionaryId = dictionaryMeta[Id], DictionaryCount = dictionaryCount])
                                in
                                    mapped
                            )
                        else {}
                in
                    [Values = values, NextBufferIndex = bufferIndex + 2]
            else if kind = "Utf8" then
                let
                    offsetsBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 1),
                    dataBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 2),
                    _offsetCheck = if Binary.Length(offsetsBuffer) < (rowCount + 1) * 4
                        then ArrowError("Utf8 offsets buffer too small", "Arrow.Arrays", "Utf8", [Field = field[Name], ExpectedBytes = (rowCount + 1) * 4, ActualBytes = Binary.Length(offsetsBuffer), RowCount = rowCount])
                        else true,
                    values = List.Transform(rowIndexes, (i) =>
                        let
                            isValid = if hasValidity then ArrowBitmapIsSet(validity, i) else true,
                            startOffset = ArrowReadInt32LE(offsetsBuffer, i * 4),
                            endOffset = ArrowReadInt32LE(offsetsBuffer, (i + 1) * 4),
                            length = endOffset - startOffset,
                            textValue = if length <= 0 then "" else Text.FromBinary(Binary.Range(dataBuffer, startOffset, length), TextEncoding.Utf8)
                        in
                            if isValid then textValue else null
                    )
                in
                    [Values = values, NextBufferIndex = bufferIndex + 3]
            else if kind = "Binary" then
                let
                    offsetsBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 1),
                    dataBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 2),
                    _offsetCheck = if Binary.Length(offsetsBuffer) < (rowCount + 1) * 4
                        then ArrowError("Binary offsets buffer too small", "Arrow.Arrays", "Binary", [Field = field[Name], ExpectedBytes = (rowCount + 1) * 4, ActualBytes = Binary.Length(offsetsBuffer), RowCount = rowCount])
                        else true,
                    values = List.Transform(rowIndexes, (i) =>
                        let
                            isValid = if hasValidity then ArrowBitmapIsSet(validity, i) else true,
                            startOffset = ArrowReadInt32LE(offsetsBuffer, i * 4),
                            endOffset = ArrowReadInt32LE(offsetsBuffer, (i + 1) * 4),
                            length = endOffset - startOffset,
                            binValue = if length <= 0 then #binary({}) else Binary.Range(dataBuffer, startOffset, length)
                        in
                            if isValid then binValue else null
                    )
                in
                    [Values = values, NextBufferIndex = bufferIndex + 3]
            else if kind = "Bool" then
                let
                    dataBitmap = ArrowGetBufferSlice(body, buffers, bufferIndex + 1),
                    _bitmapCheck = if Binary.Length(dataBitmap) < Number.IntegerDivide(rowCount + 7, 8)
                        then ArrowError("Bool bitmap buffer too small", "Arrow.Arrays", "Bool", [Field = field[Name], ExpectedBytes = Number.IntegerDivide(rowCount + 7, 8), ActualBytes = Binary.Length(dataBitmap), RowCount = rowCount])
                        else true,
                    values = List.Transform(rowIndexes, (i) =>
                        let
                            isValid = if hasValidity then ArrowBitmapIsSet(validity, i) else true,
                            value = ArrowBitmapIsSet(dataBitmap, i)
                        in
                            if isValid then value else null
                    )
                in
                    [Values = values, NextBufferIndex = bufferIndex + 2]
            else if kind = "Int" or kind = "FloatingPoint" or kind = "Date" or kind = "Timestamp" then
                let
                    dataBuffer = ArrowGetBufferSlice(body, buffers, bufferIndex + 1),
                    width = if kind = "Int" then Number.IntegerDivide(if field[Type][BitWidth] = null then 32 else field[Type][BitWidth], 8)
                        else if kind = "FloatingPoint" then (if (field[Type][Precision] = null or field[Type][Precision] = 1) then 4 else 8)
                        else if kind = "Date" then 4
                        else 8,
                    expectedBytes = rowCount * width,
                    _sizeCheck = if Binary.Length(dataBuffer) < expectedBytes
                        then ArrowError("Primitive data buffer too small", "Arrow.Arrays", "Primitive", [Field = field[Name], Kind = kind, ExpectedBytes = expectedBytes, ActualBytes = Binary.Length(dataBuffer), RowCount = rowCount])
                        else true,
                    values =
                        if _sizeCheck = true then
                            List.Transform(rowIndexes, (i) =>
                                let
                                    isValid = if hasValidity then ArrowBitmapIsSet(validity, i) else true
                                in
                                    if isValid then ArrowDecodePrimitiveValue(dataBuffer, i, field[Type]) else null
                            )
                        else {}
                in
                    [Values = values, NextBufferIndex = bufferIndex + 2]
            else ArrowError("Unsupported Arrow column encoding", "Arrow.Arrays", "Column", [Kind = kind, Field = field[Name]])
    in
        Record.Combine({base, decoded});

ArrowRecordBatchToTable = (schema as list, recordBatch as record, body as binary, dictionaries as record) as table =>
    let
        nodesTry = try recordBatch[Nodes],
        nodes = if nodesTry[HasError]
            then ArrowError("Failed to access RecordBatch Nodes", "Arrow.RecordBatch", "Access", [ErrorReason = try nodesTry[Error][Reason] otherwise null, ErrorMessage = try nodesTry[Error][Message] otherwise ""])
            else nodesTry[Value],
        buffersTry = try recordBatch[Buffers],
        buffers = if buffersTry[HasError]
            then ArrowError("Failed to access RecordBatch Buffers", "Arrow.RecordBatch", "Access", [ErrorReason = try buffersTry[Error][Reason] otherwise null, ErrorMessage = try buffersTry[Error][Message] otherwise ""])
            else buffersTry[Value],
        _schemaCountCheck = if List.Count(schema) = 0 
            then ArrowError("Schema has no fields", "Arrow.RecordBatch", "Schema", [NodeCount = List.Count(nodes), BufferCount = List.Count(buffers)])
            else true,
        _nodesCheck = if List.Count(nodes) < List.Count(schema)
            then ArrowError("Not enough nodes for schema fields", "Arrow.RecordBatch", "NodeMismatch", [SchemaFieldCount = List.Count(schema), NodeCount = List.Count(nodes)])
            else true,
        stateTry = try List.Accumulate(
            schema,
            [NodeIndex = 0, BufferIndex = 0, Columns = {}, Names = {}, LastField = null],
            (s, field) =>
                let
                    innerTry = try
                        let
                            nodeIdx = s[NodeIndex],
                            _nodeCheck = if nodeIdx >= List.Count(nodes)
                                then ArrowError("Arrow field/node mismatch", "Arrow.RecordBatch", "FieldNodes", [Field = field[Name], NodeIndex = nodeIdx])
                                else true,
                            decodedTry = try ArrowDecodeColumn(body, field, nodes{nodeIdx}, buffers, nodeIdx, s[BufferIndex], dictionaries),
                            decoded = if decodedTry[HasError]
                                then ArrowError(
                                    "Column decode failed",
                                    "Arrow.RecordBatch",
                                    "Column",
                                    [
                                        Field = field[Name],
                                        NodeIndex = nodeIdx,
                                        BufferIndex = s[BufferIndex],
                                        ErrorReason = try decodedTry[Error][Reason] otherwise null,
                                        ErrorMessage = try decodedTry[Error][Message] otherwise "",
                                        ErrorDetail = try Text.FromBinary(Json.FromValue(decodedTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                                    ]
                                )
                                else decodedTry[Value],
                            nextNodeIdx = if decoded[NextNodeIndex] = null then nodeIdx + 1 else decoded[NextNodeIndex],
                            nextBufferIdx = if decoded[NextBufferIndex] = null then s[BufferIndex] + 2 else decoded[NextBufferIndex]
                        in
                            [
                                NodeIndex = nextNodeIdx,
                                BufferIndex = nextBufferIdx,
                                Columns = s[Columns] & {List.Buffer(decoded[Values])},
                                Names = s[Names] & {decoded[Name]},
                                LastField = field[Name]
                            ],
                    result = if innerTry[HasError]
                        then ArrowError(
                            "Field accumulation failed",
                            "Arrow.RecordBatch",
                            "FieldAccumulate",
                            [
                                Field = field[Name],
                                NodeIndex = s[NodeIndex],
                                BufferIndex = s[BufferIndex],
                                ErrorReason = try innerTry[Error][Reason] otherwise null,
                                ErrorMessage = try innerTry[Error][Message] otherwise "",
                                ErrorDetail = try Text.FromBinary(Json.FromValue(innerTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                            ]
                        )
                        else innerTry[Value]
                in
                    result
        ),
        state = if stateTry[HasError]
            then ArrowError(
                "RecordBatch accumulation failed",
                "Arrow.RecordBatch",
                "Accumulate",
                [
                    ErrorReason = try stateTry[Error][Reason] otherwise null,
                    ErrorMessage = try stateTry[Error][Message] otherwise "",
                    ErrorDetail = try Text.FromBinary(Json.FromValue(stateTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                ]
            )
            else stateTry[Value],
        columnsEval = try List.Transform(state[Columns], each List.Buffer(_)),
        _columnsCheck = if columnsEval[HasError]
            then ArrowError(
                "RecordBatch column evaluation failed",
                "Arrow.RecordBatch",
                "Columns",
                [
                    ErrorReason = try columnsEval[Error][Reason] otherwise null,
                    ErrorMessage = try columnsEval[Error][Message] otherwise "",
                    ErrorDetail = try Text.FromBinary(Json.FromValue(columnsEval[Error][Detail]), TextEncoding.Utf8) otherwise ""
                ]
            )
            else true,
        bufferedColumns = columnsEval[Value],
        tableTry = try Table.FromColumns(bufferedColumns, state[Names]),
        table = if tableTry[HasError]
            then ArrowError(
                "RecordBatch table construction failed",
                "Arrow.RecordBatch",
                "ToTable",
                [
                    ErrorReason = try tableTry[Error][Reason] otherwise null,
                    ErrorMessage = try tableTry[Error][Message] otherwise "",
                    ErrorDetail = try Text.FromBinary(Json.FromValue(tableTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                ]
            )
            else tableTry[Value]
    in
        table;

ArrowParseMessage = (metadata as binary) as record =>
    let
        root = ArrowFBRootTableOffset(metadata),
        headerType = ArrowFBReadScalarUInt8(metadata, root, 1, 0),
        // Direct flatbuffers chain (without helpers) for debugging union header pointer
        rootVTablePos = root - ArrowReadInt32LE(metadata, root),
        rootVTableLength = ArrowReadUInt16LE(metadata, rootVTablePos),
        headerSlotPos = rootVTablePos + 8,
        headerSlotOffset = if headerSlotPos + 1 < rootVTablePos + rootVTableLength then ArrowReadUInt16LE(metadata, headerSlotPos) else 0,
        headerFieldPosDirect = if headerSlotOffset = 0 then null else root + headerSlotOffset,
        headerUOffsetDirect = if headerFieldPosDirect = null then null else ArrowReadUInt32LE(metadata, headerFieldPosDirect),
        headerObjRawDirect = if headerFieldPosDirect = null or headerUOffsetDirect = null then null else headerFieldPosDirect + headerUOffsetDirect,
        headerFieldPos = ArrowFBGetFieldPos(metadata, root, 2),
        headerObjRaw = ArrowFBGetTable(metadata, headerFieldPos),
        headerFieldBytesHex = if headerFieldPos = null or headerFieldPos + 3 >= Binary.Length(metadata)
            then null
            else Binary.ToText(Binary.Range(metadata, headerFieldPos, 4), BinaryEncoding.Hex),
        headerObjRawBytesHex = if headerObjRaw = null or headerObjRaw + 7 >= Binary.Length(metadata)
            then null
            else Binary.ToText(Binary.Range(metadata, headerObjRaw, 8), BinaryEncoding.Hex),
        headerObjRawVTableDistance = if headerObjRaw = null then null else (try ArrowReadInt32LE(metadata, headerObjRaw) otherwise null),
        headerObjRawVTablePos = if headerObjRaw = null or headerObjRawVTableDistance = null then null else headerObjRaw - headerObjRawVTableDistance,
        headerObj = ArrowFBNormalizeTableObject(metadata, headerObjRaw),
        // Must check headerObj before returning - force error immediately if null  
        checkedHeaderObj = if headerObj = null and headerType <> 0
            then ArrowError("Invalid Message header object pointer", "Arrow.Flatbuffers", "MessageHeader", [
                HeaderType = headerType, 
                RootPos = root, 
                RootVTablePos = rootVTablePos,
                RootVTableLength = rootVTableLength,
                HeaderSlotPos = headerSlotPos,
                HeaderSlotOffset = headerSlotOffset,
                HeaderFieldPosDirect = headerFieldPosDirect,
                HeaderUOffsetDirect = headerUOffsetDirect,
                HeaderObjectRawDirect = headerObjRawDirect,
                HeaderFieldPos = headerFieldPos, 
                HeaderObjectRaw = headerObjRaw,
                HeaderFieldBytesHex = headerFieldBytesHex,
                HeaderObjectRawBytesHex = headerObjRawBytesHex,
                HeaderObjectRawVTableDistance = headerObjRawVTableDistance,
                HeaderObjectRawVTablePos = headerObjRawVTablePos,
                HeaderFieldPosMatchesDirect = headerFieldPos = headerFieldPosDirect,
                HeaderObjectRawMatchesDirect = headerObjRaw = headerObjRawDirect,
                IsValidRaw = ArrowFBIsValidTableObject(metadata, headerObjRaw),
                IsValidRawDirect = ArrowFBIsValidTableObject(metadata, headerObjRawDirect),
                MetadataLength = Binary.Length(metadata)
            ])
            else headerObj,
        bodyLength = ArrowFBReadScalarInt64(metadata, root, 3, 0)
    in
        [HeaderType = headerType, Header = checkedHeaderObj, BodyLength = bodyLength];

ArrowParseDictionaryBatch = (metadata as binary, dictionaryBatchObj as number) as record =>
    let
        dataRaw = ArrowFBGetTable(metadata, ArrowFBGetFieldPos(metadata, dictionaryBatchObj, 1)),
        dataObj = ArrowFBNormalizeTableObject(metadata, dataRaw),
        _dataCheck = if dataObj = null
            then ArrowError("Invalid DictionaryBatch Data pointer", "Arrow.Flatbuffers", "DictionaryBatchData", [DictionaryBatchObj = dictionaryBatchObj, DataRaw = dataRaw, MetadataLength = Binary.Length(metadata)])
            else true
    in
        [
            Id = ArrowFBReadScalarInt64(metadata, dictionaryBatchObj, 0, 0),
            Data = dataObj,
            IsDelta = ArrowFBReadScalarBool(metadata, dictionaryBatchObj, 2, false)
        ];

ArrowTryMaterializeDictionaryBatch = (entry as record, schema as list, dictionaries as record) as record =>
    let
        parseTry = try
            let
                dictionaryBatchRaw = ArrowParseDictionaryBatch(entry[Metadata], entry[HeaderObject]),
                dictionaryBatch = ArrowValidateDictionaryBatch(dictionaryBatchRaw),
                dictionaryField = ArrowFindDictionaryField(schema, dictionaryBatch[Id]),
                dictionaryValueField = Record.Combine({dictionaryField, [Dictionary = null]}),
                dictionaryRecordBatch = ArrowParseRecordBatch(entry[Metadata], dictionaryBatch[Data]),
                dictionaryTableTry = try ArrowRecordBatchToTable({dictionaryValueField}, dictionaryRecordBatch, entry[Body], dictionaries),
                dictionaryTable =
                    if dictionaryTableTry[HasError] and entry[BodyStart] <> entry[BodyStartUnaligned]
                        then
                            let
                                fallbackTry = try ArrowRecordBatchToTable({dictionaryValueField}, dictionaryRecordBatch, entry[BodyUnaligned], dictionaries)
                            in
                                if fallbackTry[HasError] then error dictionaryTableTry[Error] else fallbackTry[Value]
                        else if dictionaryTableTry[HasError]
                            then error dictionaryTableTry[Error]
                            else dictionaryTableTry[Value],
                dictionaryValuesRaw = if Table.RowCount(dictionaryTable) = 0 then {} else Table.Column(dictionaryTable, dictionaryValueField[Name]),
                dictionaryValues = List.Buffer(dictionaryValuesRaw)
            in
                ArrowMergeDictionaryValues(dictionaries, dictionaryBatch[Id], dictionaryBatch[IsDelta], dictionaryValues)
    in
        if parseTry[HasError]
            then
                [
                    Succeeded = false,
                    Dictionaries = dictionaries,
                    ErrorReason = try parseTry[Error][Reason] otherwise null,
                    ErrorMessage = try parseTry[Error][Message] otherwise "",
                    ErrorDetail = try Text.FromBinary(Json.FromValue(parseTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                ]
            else
                [
                    Succeeded = true,
                    Dictionaries = parseTry[Value],
                    ErrorReason = null,
                    ErrorMessage = null,
                    ErrorDetail = null
                ];

ArrowResolvePendingDictionaryBatches = (schema as list, pending as list, dictionaries as record) as record =>
    let
        initial = [Pending = pending, Dictionaries = dictionaries, MadeProgress = true],
        final = List.Last(
            List.Generate(
                () => initial,
                each [MadeProgress] and List.Count([Pending]) > 0,
                each
                    let
                        pass = List.Accumulate(
                            [Pending],
                            [Pending = {}, Dictionaries = [Dictionaries], MadeProgress = false],
                            (state, entry) =>
                                let
                                    attempt = ArrowTryMaterializeDictionaryBatch(entry, schema, state[Dictionaries]),
                                    updatedEntry =
                                        if attempt[Succeeded]
                                            then entry
                                            else Record.Combine({entry, [LastErrorReason = attempt[ErrorReason], LastErrorMessage = attempt[ErrorMessage], LastErrorDetail = attempt[ErrorDetail]]})
                                in
                                    if attempt[Succeeded]
                                        then [Pending = state[Pending], Dictionaries = attempt[Dictionaries], MadeProgress = true or state[MadeProgress]]
                                        else [Pending = state[Pending] & {updatedEntry}, Dictionaries = state[Dictionaries], MadeProgress = state[MadeProgress]]
                        )
                    in
                        [Pending = pass[Pending], Dictionaries = pass[Dictionaries], MadeProgress = pass[MadeProgress]],
                each _
            )
        )
    in
        [Pending = final[Pending], Dictionaries = final[Dictionaries]];

ArrowParseStream = (payload as binary) as table =>
    let
        length = Binary.Length(payload),
        initial = [Offset = 0, Schema = null, Dictionaries = [], PendingDictionaryBatches = {}, Tables = {}],
        final = List.Last(
            List.Generate(
                () => initial,
                each [Offset] < length,
                each
                    let
                        offset = [Offset],
                        remaining = length - offset,
                        _headerCheck = if remaining < 4 then null else true,
                        prefix = if _headerCheck = null then 0 else ArrowReadInt32LE(payload, offset),
                        isContinuation = _headerCheck <> null and prefix = -1,
                        _continuationRequired = if _headerCheck <> null and (not isContinuation)
                            then ArrowError("Unexpected Arrow frame prefix", "Arrow.Stream", "Framing", [Offset = offset, Prefix = prefix])
                            else true,
                        _continuationCheck = if isContinuation and remaining < 8
                            then ArrowError("Truncated Arrow continuation header", "Arrow.Stream", "Framing", [Offset = offset, Remaining = remaining])
                            else true,
                        metadataLength = if _headerCheck = null then 0 else ArrowReadInt32LE(payload, offset + 4),
                        metadataStart = if _headerCheck = null then length else offset + 8,
                        isEnd = metadataLength = 0,
                        _metadataCheck = if metadataLength < 0
                            then ArrowError("Negative Arrow metadata length", "Arrow.Stream", "Framing", [Offset = offset, MetadataLength = metadataLength])
                            else true,
                        _metadataRangeCheck = if (not isEnd) and (metadataStart + metadataLength > length)
                            then ArrowError("Arrow metadata exceeds payload length", "Arrow.Stream", "Framing", [Offset = offset, MetadataStart = metadataStart, MetadataLength = metadataLength, PayloadLength = length])
                            else true,
                        metadata = if isEnd then #binary({}) else Binary.Range(payload, metadataStart, metadataLength),
                        bodyStartUnaligned = if isEnd then metadataStart else metadataStart + metadataLength,
                        bodyStart = if isEnd then metadataStart else ArrowAlign8(bodyStartUnaligned),
                        parsed = if isEnd then [HeaderType = 0, Header = null, BodyLength = 0] else ArrowParseMessage(metadata),
                        _bodyLengthCheck = if parsed[BodyLength] = null
                            then ArrowError("Message BodyLength is null", "Arrow.Stream", "Message", [Offset = offset])
                            else true,
                        bodyLength = Number.From(parsed[BodyLength]),
                        _bodyRangeCheck = if (not isEnd) and bodyLength > 0 and (bodyStart + bodyLength > length)
                            then ArrowError("Arrow body exceeds payload length", "Arrow.Stream", "Framing", [Offset = offset, BodyStart = bodyStart, BodyLength = bodyLength, PayloadLength = length])
                            else true,
                        _bodyRangeCheckUnaligned = if (not isEnd) and bodyLength > 0 and (bodyStartUnaligned + bodyLength > length)
                            then ArrowError("Arrow unaligned body exceeds payload length", "Arrow.Stream", "Framing", [Offset = offset, BodyStart = bodyStartUnaligned, BodyLength = bodyLength, PayloadLength = length])
                            else true,
                        body = if isEnd or bodyLength <= 0 then #binary({}) else Binary.Range(payload, bodyStart, bodyLength),
                        bodyUnaligned = if isEnd or bodyLength <= 0 then #binary({}) else Binary.Range(payload, bodyStartUnaligned, bodyLength),
                        nextOffset = if _headerCheck = null then length else if isEnd then length else ArrowAlign8(bodyStart + bodyLength),
                        nextSchema = if parsed[HeaderType] = 1
                            then
                                let
                                    schemaTry = try ArrowParseSchema(metadata, parsed[Header])
                                in
                                    if schemaTry[HasError]
                                        then ArrowError(
                                            "Schema parsing failed",
                                            "Arrow.Schema",
                                            "Parse",
                                            [
                                                Offset = offset,
                                                ErrorReason = try schemaTry[Error][Reason] otherwise null,
                                                ErrorMessage = try schemaTry[Error][Message] otherwise "",
                                                ErrorDetail = try Text.FromBinary(Json.FromValue(schemaTry[Error][Detail]), TextEncoding.Utf8) otherwise ""
                                            ]
                                        )
                                        else schemaTry[Value]
                            else [Schema],
                        pendingWithCurrent = if parsed[HeaderType] = 2
                            then
                                let
                                    _schemaCheck = if nextSchema = null then ArrowError("DictionaryBatch arrived before Schema", "Arrow.Stream", "MessageOrder") else true,
                                    dictionaryEntry = [
                                        Offset = offset,
                                        MetadataLength = metadataLength,
                                        HeaderObject = parsed[Header],
                                        Metadata = metadata,
                                        Body = body,
                                        BodyUnaligned = bodyUnaligned,
                                        BodyStart = bodyStart,
                                        BodyStartUnaligned = bodyStartUnaligned
                                    ]
                                in
                                    [PendingDictionaryBatches] & {dictionaryEntry}
                            else [PendingDictionaryBatches],
                        resolvedDictionaries = if nextSchema = null
                            then [Pending = pendingWithCurrent, Dictionaries = [Dictionaries]]
                            else ArrowResolvePendingDictionaryBatches(nextSchema, pendingWithCurrent, [Dictionaries]),
                        nextDictionaries = resolvedDictionaries[Dictionaries],
                        nextPendingDictionaryBatches = resolvedDictionaries[Pending],
                        nextTables = if parsed[HeaderType] = 3
                            then
                                let
                                    _pendingDictionaryCheck = if List.Count(nextPendingDictionaryBatches) > 0
                                        then
                                            let
                                                firstPending = nextPendingDictionaryBatches{0}
                                            in
                                                ArrowError(
                                                    "Unresolved dictionary batches remain before RecordBatch",
                                                    "Arrow.Stream",
                                                    "DictionaryBatchResolution",
                                                    [
                                                        PendingCount = List.Count(nextPendingDictionaryBatches),
                                                        FirstPendingOffset = try firstPending[Offset] otherwise null,
                                                        FirstPendingErrorReason = try firstPending[LastErrorReason] otherwise null,
                                                        FirstPendingErrorMessage = try firstPending[LastErrorMessage] otherwise "",
                                                        FirstPendingErrorDetail = try firstPending[LastErrorDetail] otherwise ""
                                                    ]
                                                )
                                        else true,
                                    _schemaCheck = if nextSchema = null then ArrowError("RecordBatch arrived before Schema", "Arrow.Stream", "MessageOrder") else true,
                                    rbTry = try ArrowParseRecordBatch(metadata, parsed[Header]),
                                    rbRaw = if rbTry[HasError]
                                        then ArrowError(
                                            "RecordBatch metadata parse failed",
                                            "Arrow.Stream",
                                            "RecordBatch",
                                            [
                                                Offset = offset,
                                                MetadataLength = metadataLength,
                                                HeaderType = parsed[HeaderType],
                                                HeaderObject = parsed[Header],
                                                ErrorReason = try rbTry[Error][Reason] otherwise null,
                                                ErrorMessage = try rbTry[Error][Message] otherwise ""
                                            ]
                                        )
                                        else rbTry[Value],
                                    rbEvalTry = try [Length = rbRaw[Length], Nodes = List.Buffer(rbRaw[Nodes]), Buffers = List.Buffer(rbRaw[Buffers])],
                                    // Run diagnostics when evaluation fails
                                    evalDiagJson = if rbEvalTry[HasError]
                                        then 
                                            let 
                                                diagTry = try Record.Combine({ArrowDiagnoseRecordBatch(metadata, parsed[Header]), ArrowDiagnoseBuffers(metadata, parsed[Header])})
                                            in
                                                if diagTry[HasError] 
                                                    then "DIAG_FAILED:" & (try diagTry[Error][Message] otherwise "unknown")
                                                    else try Text.FromBinary(Json.FromValue(diagTry[Value]), TextEncoding.Utf8) otherwise "DIAG_SERIALIZE_FAILED"
                                        else "",
                                    rb = if rbEvalTry[HasError]
                                        then ArrowError(
                                            "RecordBatch metadata evaluation failed",
                                            "Arrow.Stream",
                                            "RecordBatch",
                                            [
                                                Offset = offset,
                                                MetadataLength = metadataLength,
                                                HeaderType = parsed[HeaderType],
                                                HeaderObject = parsed[Header],
                                                BodyLength = parsed[BodyLength],
                                                ErrorReason = try rbEvalTry[Error][Reason] otherwise null,
                                                ErrorMessage = try rbEvalTry[Error][Message] otherwise "",
                                                ErrorDetail = try Text.FromBinary(Json.FromValue(rbEvalTry[Error][Detail]), TextEncoding.Utf8) otherwise "",
                                                Diagnostics = evalDiagJson
                                            ]
                                        )
                                        else rbEvalTry[Value],
                                    _rbSchemaCheck = if nextSchema = null 
                                        then ArrowError("Schema is null when processing RecordBatch", "Arrow.Stream", "RecordBatch", [Offset = offset])
                                        else true,
                                    tTry =
                                        let
                                            primaryTry = try ArrowRecordBatchToTable(nextSchema, rb, body, nextDictionaries)
                                        in
                                            if primaryTry[HasError] and bodyStart <> bodyStartUnaligned
                                                then
                                                    let
                                                        fallbackTry = try ArrowRecordBatchToTable(nextSchema, rb, bodyUnaligned, nextDictionaries)
                                                    in
                                                        if fallbackTry[HasError] then primaryTry else fallbackTry
                                                else primaryTry,
                                    // Run diagnostics when materialization fails
                                    diagJson = if tTry[HasError]
                                        then 
                                            let 
                                                diagTry = try Record.Combine({ArrowDiagnoseRecordBatch(metadata, parsed[Header]), ArrowDiagnoseBuffers(metadata, parsed[Header])})
                                            in
                                                if diagTry[HasError] 
                                                    then "DIAG_FAILED:" & (try diagTry[Error][Message] otherwise "unknown")
                                                    else try Text.FromBinary(Json.FromValue(diagTry[Value]), TextEncoding.Utf8) otherwise "DIAG_SERIALIZE_FAILED"
                                        else "",
                                    t = if tTry[HasError]
                                        then ArrowError(
                                            "RecordBatch table materialization failed",
                                            "Arrow.Stream",
                                            "RecordBatch",
                                            [
                                                Offset = offset,
                                                MetadataLength = metadataLength,
                                                HeaderType = parsed[HeaderType],
                                                HeaderObject = parsed[Header],
                                                BodyLength = parsed[BodyLength],
                                                ErrorReason = try tTry[Error][Reason] otherwise null,
                                                ErrorMessage = try tTry[Error][Message] otherwise "",
                                                ErrorDetail = try Text.FromBinary(Json.FromValue(tTry[Error][Detail]), TextEncoding.Utf8) otherwise "",
                                                Diagnostics = diagJson
                                            ]
                                        )
                                        else tTry[Value]
                                in
                                    [Tables] & {t}
                            else [Tables]
                    in
                        [Offset = nextOffset, Schema = nextSchema, Dictionaries = nextDictionaries, PendingDictionaryBatches = nextPendingDictionaryBatches, Tables = nextTables],
                each _
            )
        ),
        result = if List.Count(final[Tables]) = 0
            then #table(type table [], {})
            else if List.Count(final[Tables]) = 1 then final[Tables]{0}
            else Table.Combine(final[Tables])
    in
        result;

ArrowFromBinary = (payload as binary) as table =>
    let
        buffered = Binary.Buffer(payload),
        length = Binary.Length(buffered),
        sampleLength = if length < 24 then length else 24,
        headHex = try Text.Lower(Binary.ToText(Binary.Range(buffered, 0, sampleLength), BinaryEncoding.Hex)) otherwise "",
        tailStart = if length > sampleLength then length - sampleLength else 0,
        tailHex = try Text.Lower(Binary.ToText(Binary.Range(buffered, tailStart, sampleLength), BinaryEncoding.Hex)) otherwise "",
        _isArrowPayload = if ArrowDetectionHasArrowMagic(buffered) or ArrowReadInt32LE(buffered, 0) = -1
            then true
            else ArrowError("Unsupported Arrow payload framing", "Arrow.Detection", "Framing"),
        _compressionCheck = if ArrowDetectionLooksLikeLz4Frame(buffered)
            then ArrowError("Unsupported compression", "Arrow.RecordBatch", "Compression", [Compression = "LZ4_FRAME"])
            else true,
        parsed = try ArrowParseStream(buffered),
        result = if parsed[HasError]
            then
                let
                    innerReason = try parsed[Error][Reason] otherwise null,
                    innerMessage = try parsed[Error][Message] otherwise "Arrow parse failed",
                    innerDetail = try Text.FromBinary(Json.FromValue(parsed[Error][Detail]), TextEncoding.Utf8) otherwise ""
                in
                    ArrowError("Arrow parse failed", "Arrow.Stream", "Parse", [Length = length, HeadHex = headHex, TailHex = tailHex, InnerReason = innerReason, InnerMessage = innerMessage, InnerDetail = innerDetail])
            else parsed[Value]
    in
        result;

Arrow = [
    FromBinary = ArrowFromBinary,
    Detection = [
        IsArrowResponse = ArrowDetectionIsArrowResponse,
        HasArrowMagic = ArrowDetectionHasArrowMagic,
        IsArrowContentType = ArrowDetectionIsArrowContentType,
        GetContentType = ArrowDetectionGetContentType
    ],
    BinaryEx = [
        Buffer = (binary as binary) as binary => Binary.Buffer(binary),
        Slice = (binary as binary, offset as number, length as number) as binary => Binary.Range(binary, offset, length),
        Length = (binary as binary) as number => Binary.Length(binary)
    ],
    Flatbuffers = [
        ReadRoot = (binary as binary) as number => ArrowFBRootTableOffset(binary)
    ],
    Schema = [
        Read = (binary as binary) as list =>
            let
                message = ArrowParseMessage(binary)
            in
                if message[HeaderType] = 1 then ArrowParseSchema(binary, message[Header]) else {}
    ],
    Arrays = [
        Read = (binary as binary) as table => ArrowParseStream(binary)
    ],
    RecordBatch = [
        Read = (binary as binary) as table => ArrowParseStream(binary)
    ],
    Materialization = [
        ToTable = (columns as list) as table => Table.FromColumns(columns)
    ]
];

GetFile = (optional relPath as text) =>
    let
        params = [Headers=[Accept="application/octet-stream"], RelativePath = relPath],
        //Get Pages
        //Hard-coded Base URL because Power BI Service won't recognize parameter despite numerous attempts
        webSource = Web.Contents(
            "https://api.powerbi.com",
            params
        ),
        //Convert to Json
        result = webSource
    in
        result;

GetJSON = (optional relPath as text) =>
    let
        params = [Headers = [#"Content-Type" = "application/json"], RelativePath = relPath],
        //Get Pages
        //Hard-coded Base URL because Power BI Service won't recognize parameter despite numerous attempts
        webSource = Web.Contents(
            "https://api.powerbi.com",
            params
        ),
        //Convert to Json
        result = Text.FromBinary(webSource)
    in
        result;

PostJSON = (optional params as record) =>
    let
        //Post
        //Hard-coded Base URL because Power BI Service won't recognize parameter despite numerous attempts
        webSource = Web.Contents(
            "https://api.powerbi.com",
            params
        ),
        //Convert to Json
        result = Text.FromBinary(webSource)
    in
        result;

// Data Source Kind description
PBIRESTAPIComm = [
    TestConnection = (dataSourcePath) =>  { "PBIRESTAPIComm.FunctionCatalog"},
    Authentication = [
        AAD = [
            AuthorizationUri = "https://login.windows.net/common/oauth2/authorize",
            Resource = "https://analysis.windows.net/powerbi/api"
        ]
    ]
];

// Data Source UI publishing description
PBIRESTAPIComm.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {
        Extension.LoadString(
            "ButtonTitle"
        ),
        Extension.LoadString(
            "ButtonHelp"
        )
    },
    LearnMoreUrl = "https://github.com/kerski/powerquery-connector-pbi-rest-api-commercial/blob/main/README.md#functions-implemented",
    SourceImage = PBIRESTAPIComm.Icons,
    SourceTypeImage = PBIRESTAPIComm.Icons
];

PBIRESTAPIComm.Icons = [
    Icon16 = {
        Extension.Contents(
            "PBIRESTAPIComm16.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm20.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm24.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm32.png"
        )
    },
    Icon32 = {
        Extension.Contents(
            "PBIRESTAPIComm32.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm40.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm48.png"
        ),
        Extension.Contents(
            "PBIRESTAPIComm64.png"
        )
    }
];

//To Navigation Table
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(
            table
        ),
        newTableType = Type.AddTableKey(
            tableType,
            keyColumns,
            true
        ) meta [
            NavigationTable.NameColumn = nameColumn,
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn,
            Preview.DelayColumn = itemNameColumn,
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(
            table,
            newTableType
        )
    in
        navigationTable;

// Force Navigation Table
Table.ForceToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(
            table
        ),
        newTableType = Type.AddTableKey(
            tableType,
            keyColumns,
            true
        ) meta [
            NavigationTable.NameColumn = nameColumn,
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn,
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(
            table,
            newTableType
        )
    in
        navigationTable;