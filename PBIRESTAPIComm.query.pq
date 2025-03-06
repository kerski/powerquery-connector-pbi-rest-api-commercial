section UnitTestingUnitTests;

shared MyExtension.UnitTest =
[
    // Put any common variables here if you only want them to be evaluated once
    Source = PBIRESTAPIComm.FunctionCatalog(),
    
    /*Variables*/ 
    AppTestID = Environment.FeatureSwitch("AppTestID"),
    AppDashboardTestID = Environment.FeatureSwitch("AppDashboardTestID"),
    AppDashboardTileTestID = Environment.FeatureSwitch("AppDashboardTileTestID"),
    AppReportTestID = Environment.FeatureSwitch("AppReportTestID"),
    GroupTestID = Environment.FeatureSwitch("GroupTestID"),
    GroupNameFilter = Environment.FeatureSwitch("GroupNameFilter"),
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),
    ReportTestID = Environment.FeatureSwitch("ReportTestID"),
    ReportTestName = Environment.FeatureSwitch("ReportTestName"),
    
    PipelineTestID = Environment.FeatureSwitch("PipelineTestID"),
    // Convert rest here to figure out what's wrong
    EnhancedRefreshTestID = Environment.FeatureSwitch("EnhancedRefreshTestID"),
    DashboardTestID = Environment.FeatureSwitch("DashboardTestID"),
    DashboardTileTestID = Environment.FeatureSwitch("DashboardTileTestID"),
    DataflowTestID = Environment.FeatureSwitch("DataflowTestID"),
    DownstreamDataflowTestID = Environment.FeatureSwitch("DownstreamDataflowTestID"),
    ScorecardOneTestID = Environment.FeatureSwitch("ScorecardOneTestID"),
    ScorecardOneGoalTestID = Environment.FeatureSwitch("ScorecardOneGoalTestID"), 
    ScorecardOneGoalWithRefreshTestID = Environment.FeatureSwitch("ScorecardOneGoalWithRefreshTestID"),   
    ScorecardTwoTestID = Environment.FeatureSwitch("ScorecardTwoTestID"),
    ScorecardInternalReportId = Environment.FeatureSwitch("ScorecardInternalReportId"),
    ScorecardOneGoalTimestampID = Expression.Evaluate(Environment.FeatureSwitch("ScorecardOneGoalTimestampID")),
    // Sync Status Workspace ID
    ScaleOutWorkspaceID = Environment.FeatureSwitch("ScaleOutWorkspaceID"),
    ScaleOutDatasetID = Environment.FeatureSwitch("ScaleOutDatasetID"),
    // Export Report or Paginated Report variables
    ExportWorkspaceID = Environment.FeatureSwitch("ExportWorkspaceID"),
    ExportReportID = Environment.FeatureSwitch("ExportReportID"),
    ExportPaginatedReportID = Environment.FeatureSwitch("ExportPaginatedReportID"),

    // Extracts Function from group
    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key=_func_key]}[Data] otherwise "Not a function"
        in
            Result,
    // Define functions
    /* App */
    GetApp  = _GetFunction("GetApp"),
    GetApps = _GetFunction("GetApps"),
    GetDashboardInApp = _GetFunction("GetDashboardInApp"),
    GetDashboardsInApp = _GetFunction("GetDashboardsInApp"),
    GetReportInApp = _GetFunction("GetReportInApp"),
    GetReportsInApp = _GetFunction("GetReportsInApp"),
    GetDashboardTileInApp = _GetFunction("GetDashboardTileInApp"),
    GetDashboardTilesInApp = _GetFunction("GetDashboardTilesInApp"),
    /* Dashboards */
    GetDashboardInGroup = _GetFunction("GetDashboardInGroup"),
    GetDashboardsInGroup = _GetFunction("GetDashboardsInGroup"),
    GetDashboardTileInGroup = _GetFunction("GetDashboardTileInGroup"),
    GetDashboardTilesInGroup = _GetFunction("GetDashboardTilesInGroup"),
    /* Dataflows*/
    GetDataflowDataSourcesInGroup = _GetFunction("GetDataflowDataSourcesInGroup"),
    GetDataflowInGroup = _GetFunction("GetDataflowInGroup"),
    GetDataflowTransactionsInGroup = _GetFunction("GetDataflowTransactionsInGroup"),    
    GetDataflowsInGroup = _GetFunction("GetDataflowsInGroup"),
    GetUpstreamDataflowsInGroup = _GetFunction("GetUpstreamDataflowsInGroup"),
    /* Datasets*/
    GetDatasetDiscoverGatewaysInGroup = _GetFunction("GetDatasetDiscoverGatewaysInGroup"),
    GetDatasetInGroup = _GetFunction("GetDatasetInGroup"),
    GetDatasetToDataflowsLinksInGroup = _GetFunction("GetDatasetToDataflowsLinksInGroup"),
    GetDatasetUsersInGroup = _GetFunction("GetDatasetUsersInGroup"),
    GetDatasetsInGroup = _GetFunction("GetDatasetsInGroup"),
    GetDatasetDatasourcesInGroup = _GetFunction("GetDatasetDatasourcesInGroup"),
    GetDatasetDirectQueryRefreshScheduleInGroup = _GetFunction("GetDatasetDirectQueryRefreshScheduleInGroup"),
    GetDatasetQueryScaleOutStatusInGroup = _GetFunction("GetDatasetQueryScaleOutStatusInGroup"),
    GetDatasetParametersInGroup = _GetFunction("GetDatasetParametersInGroup"),
    GetDatasetRefreshExecutionDetailsInGroup = _GetFunction("GetDatasetRefreshExecutionDetailsInGroup"),
    GetDatasetRefreshHistoryInGroup = _GetFunction("GetDatasetRefreshHistoryInGroup"),
    GetDatasetRefreshScheduleInGroup = _GetFunction("GetDatasetRefreshScheduleInGroup"),
    ExecuteQuery = _GetFunction("ExecuteQuery"),
    ExecuteQueryInGroup = _GetFunction("ExecuteQueryInGroup"),
    /* Reports */
    GetPaginatedReportDatasourcesInGroup = _GetFunction("GetPaginatedReportDatasourcesInGroup"),
    GetReportPageInGroup = _GetFunction("GetReportPageInGroup"),
    GetReportPagesInGroup = _GetFunction("GetReportPagesInGroup"),
    GetReportInGroup = _GetFunction("GetReportInGroup"),
    GetReportsInGroup = _GetFunction("GetReportsInGroup"),
    ExportReportInGroup = _GetFunction("ExportReportInGroup"),
    /* GoalValues */
    GetScorecardGoalValuesInGroup = _GetFunction("GetScorecardGoalValuesInGroup"),
    GetScorecardGoalValueInGroup = _GetFunction("GetScorecardGoalValueInGroup"),
    /* Goals */
    GetScorecardGoalsInGroup = _GetFunction("GetScorecardGoalsInGroup"),
    GetScorecardGoalInGroup = _GetFunction("GetScorecardGoalInGroup"),
    GetScorecardGoalRefreshHistoryInGroup = _GetFunction("GetScorecardGoalRefreshHistoryInGroup"),
    /* GoalsStatusRules */
    GetScorecardGoalsStatusRulesInGroup = _GetFunction("GetScorecardGoalsStatusRulesInGroup"),
    /* Groups */
    GetGroupUsers = _GetFunction("GetGroupUsers"),
    GetGroups = _GetFunction("GetGroups"),
    /* Pipelines */
    GetPipeline = _GetFunction("GetPipeline"),
    GetPipelineOperation = _GetFunction("GetPipelineOperation"),
    GetPipelineOperations = _GetFunction("GetPipelineOperations"),
    GetPipelineStageArtifacts = _GetFunction("GetPipelineStageArtifacts"),    
    GetPipelineStages = _GetFunction("GetPipelineStages"),
    GetPipelineUsers = _GetFunction("GetPipelineUsers"),
    GetPipelines = _GetFunction("GetPipelines"),
    /* Scorecards */
    GetScorecardsInGroup = _GetFunction("GetScorecardsInGroup"),
    GetScorecardInGroup = _GetFunction("GetScorecardInGroup"),
    GetScorecardByReportIdInGroup = _GetFunction("GetScorecardByReportIdInGroup"),

    // Fact(<Name of the Test>, <Expected Value>, <Actual Value>)
    // <Expected Value> and <Actual Value> can be a literal or let statement   
    facts =
    {        
     /*****************
     APPS
     *****************/
        
        /* GetApps */        
        Fact("GetApps Should Be a Function",
             true,
             Value.Is(GetApps,Function.Type)
        ),
        Fact("GetApps Should Return Correct Metadata",
             "apps",
             Text.AfterDelimiter(Json.Document(GetApps())[#"@odata.context"],"#")
        ),
        Fact("GetApps Should Return More Than One Record",
             true,
             List.Count(Json.Document(GetApps())[value]) > 0
        ),
        /* GetDashboardInApp */
        Fact("GetDashboardInApp Should Be a Function",
             true,
             Value.Is(GetDashboardInApp,Function.Type)
        ),
        Fact("GetDashboardInApp Should Return Correct Metadata",
             "dashboards/$entity",
             Text.AfterDelimiter(Json.Document(GetDashboardInApp(AppTestID,AppDashboardTestID))[#"@odata.context"],"#")
        ),        
        /* GetDashboardsInApp */
        Fact("GetDashboardsInApp Should Be a Function",
             true,
             Value.Is(GetDashboardsInApp,Function.Type)
        ),
        Fact("GetDashboardsInApp Should Return Correct Metadata",
             "dashboards",
             Text.AfterDelimiter(Json.Document(GetDashboardsInApp(AppTestID))[#"@odata.context"],"#")
        ),                 
        /* GetReportInApp */
        Fact("GetReportInApp Should Be a Function",
             true,
             Value.Is(GetReportInApp,Function.Type)
        ),
        Fact("GetReportInApp Should Return Correct Metadata",
             "reports/$entity",
             Text.AfterDelimiter(Json.Document(GetReportInApp(AppTestID,AppReportTestID))[#"@odata.context"],"#")
        ),        
        /* GetReportsInApp */
        Fact("GetReportsInApp Should Be a Function",
             true,
             Value.Is(GetReportsInApp,Function.Type)
        ),
        Fact("GetReportsInApp Should Return Correct Metadata",
             "reports",
             Text.AfterDelimiter(Json.Document(GetReportsInApp(AppTestID))[#"@odata.context"],"#")
        ),  
        /* GetDashboardTileInApp */
        Fact("GetDashboardTileInApp Should Be a Function",
             true,
             Value.Is(GetDashboardTileInApp,Function.Type)
        ),    
        Fact("GetDashboardTileInGApp Should Return Correct Metadata",
             "tiles/$entity",
             Text.AfterDelimiter(Json.Document(GetDashboardTileInApp(AppTestID,AppDashboardTestID,AppDashboardTileTestID))[#"@odata.context"],"#")
        ),
        /* GetDashboardTilesInApp */
        Fact("GetDashboardTilesInApp Should Be a Function",
             true,
             Value.Is(GetDashboardTilesInApp,Function.Type)
        ),    
        Fact("GetDashboardTilesInApp Should Return Correct Metadata",
             "tiles",
             Text.AfterDelimiter(Json.Document(GetDashboardTilesInApp(AppTestID,AppDashboardTestID))[#"@odata.context"],"#")
        ),     
     /*****************
     DASHBOARDS
     *****************/           
        /* GetDashboardInGroup*/
        Fact("GetDashboardInGroup Should Be a Function",
             true,
             Value.Is(GetDashboardInGroup,Function.Type)
        ),    
        Fact("GetDashboardInGroup Should Return Correct Metadata",
             "dashboards/$entity",
             Text.AfterDelimiter(Json.Document(GetDashboardInGroup(GroupTestID,DashboardTestID))[#"@odata.context"],"#")
        ),
        /* GetDashboardsInGroup */
        Fact("GetDashboardsInGroup Should Be a Function",
             true,
             Value.Is(GetDashboardsInGroup,Function.Type)
        ),    
        Fact("GetDashboardsInGroup Should Return Correct Metadata",
             "dashboards",
             Text.AfterDelimiter(Json.Document(GetDashboardsInGroup(GroupTestID))[#"@odata.context"],"#")
        ),
        /* GetDashboardTileInGroup */
        Fact("GetDashboardTileInGroup Should Be a Function",
             true,
             Value.Is(GetDashboardTileInGroup,Function.Type)
        ),    
        Fact("GetDashboardTileInGroup Should Return Correct Metadata",
             "tiles/$entity",
             Text.AfterDelimiter(Json.Document(GetDashboardTileInGroup(GroupTestID,DashboardTestID,DashboardTileTestID))[#"@odata.context"],"#")
        ),
        /* GetDashboardTilesInGroup */
        Fact("GetDashboardTilesInGroup Should Be a Function",
             true,
             Value.Is(GetDashboardTilesInGroup,Function.Type)
        ),    
        Fact("GetDashboardTilesInGroup Should Return Correct Metadata",
             "tiles",
             Text.AfterDelimiter(Json.Document(GetDashboardTilesInGroup(GroupTestID,DashboardTestID))[#"@odata.context"],"#")
        ),
     /*****************
     DATAFLOWS
     *****************/        
        /* GetDataflowInGroup */
        Fact("GetDataflowInGroup Should Be a Function",
             true,
             Value.Is(GetDataflowInGroup,Function.Type)
        ),    
        Fact("GetDataflowInGroup Should Return Json with name property RawSourceExample",
             "RawSourceExample",
             Json.Document(GetDataflowInGroup(GroupTestID,DataflowTestID))[name]
        ), 
        /* GetDataflowDataSourcesInGroup */
        Fact("GetDataflowDataSourcesInGroup Should Be a Function",
             true,
             Value.Is(GetDataflowDataSourcesInGroup,Function.Type)
        ),    
        Fact("GetDataflowDataSourcesInGroup Should Return Correct Metadata",
             "datasources",
             Text.AfterDelimiter(Json.Document(GetDataflowDataSourcesInGroup(GroupTestID,DataflowTestID))[#"@odata.context"],"#")
        ),
        /* GetDataflowTransactionsInGroup */
        Fact("GetDataflowDataSourcesInGroup Should Be a Function",
             true,
             Value.Is(GetDataflowTransactionsInGroup,Function.Type)
        ),    
        Fact("GetDataflowTransactionsInGroup Should Return Correct Metadata",
             "transactions",
             Text.AfterDelimiter(Json.Document(GetDataflowTransactionsInGroup(GroupTestID,DataflowTestID))[#"@odata.context"],"#")
        ),         
        /* GetDataflowsInGroup */
        Fact("GetDataflowsInGroup Should Be a Function",
             true,
             Value.Is(GetDataflowsInGroup,Function.Type)
        ),    
        Fact("GetDataflowsInGroup Should Be Correct Metadata",
             "dataflows",
             Text.AfterDelimiter(Json.Document(GetDataflowsInGroup(GroupTestID))[#"@odata.context"],"#")
        ),
        /* GetUpstreamDataflowsInGroup */
        Fact("GetUpstreamDataflowsInGroup Should Be a Function",
             true,
             Value.Is(GetUpstreamDataflowsInGroup,Function.Type)
        ),    
        Fact("GetUpstreamDataflowsInGroup Should Be Correct Metadata",
             "upstreamDataflows",
             Text.AfterDelimiter(Json.Document(GetUpstreamDataflowsInGroup(GroupTestID,DownstreamDataflowTestID ))[#"@odata.context"],"#")
        ),   
     /*****************
     DATASETS
     *****************/                      
        /* GetDatasetDiscoverGatewaysInGroup */
        Fact("GetDatasetDiscoverGatewaysInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetDiscoverGatewaysInGroup,Function.Type)
        ),
        Fact("GetDatasetDiscoverGatewaysInGroup Should Be Correct Metadata",
             "gateways",
             Text.AfterDelimiter(Json.Document(GetDatasetDiscoverGatewaysInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ),        
        /* GetDatasetInGroup */
        Fact("GetDatasetInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetInGroup,Function.Type)
        ),
        Fact("GetDatasetInGroup Should Be Correct Metadata",
             "datasets/$entity",
             Text.AfterDelimiter(Json.Document(GetDatasetInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ),        
        /* GetDatasetToDataflowsLinksInGroup */
        Fact("GetDatasetToDataflowsLinksInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetToDataflowsLinksInGroup,Function.Type)
        ),
        Fact("GetDatasetToDataflowsLinksInGroup Should Be Correct Metadata",
             "Collection(Microsoft.PowerBI.ServiceContracts.Api.DatasetToDataflowLinkResponse)",
             Text.AfterDelimiter(Json.Document(GetDatasetToDataflowsLinksInGroup(GroupTestID))[#"@odata.context"],"#")
        ),
        /* GetDatasetUsersInGroup*/
        Fact("GetDatasetUsersInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetUsersInGroup,Function.Type)
        ),
        Fact("GetDatasetUsersInGroup Should Be Correct Metadata",
             "Collection(Microsoft.PowerBI.ServiceContracts.Api.Access.DatasetUser)",
             Text.AfterDelimiter(Json.Document(GetDatasetUsersInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ), 
        Fact("GetDatasetUsersInGroup Should at least 1 user",
             true,
             List.Count(Json.Document(GetDatasetUsersInGroup(GroupTestID,DatasetTestID))[value]) > 0
        ),         
        /* GetDatasetsInGroup */
        Fact("GetDatasetsInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetsInGroup,Function.Type)
        ),
        Fact("GetDatasetsInGroup Should Be Correct Metadata",
             "datasets",
             Text.AfterDelimiter(Json.Document(GetDatasetsInGroup(GroupTestID))[#"@odata.context"],"#")
        ),          
        /* GetDatasetDatasourcesInGroup */
        Fact("GetDatasetDatasourcesInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetDatasourcesInGroup,Function.Type)
        ),
        Fact("GetDatasetDatasourcesInGroup Should Be Correct Metadata",
             "datasources",
             Text.AfterDelimiter(Json.Document(GetDatasetDatasourcesInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ),
        /* GetDatasetDirectQueryRefreshScheduleInGroup */
        Fact("GetDatasetDirectQueryRefreshScheduleInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetDirectQueryRefreshScheduleInGroup,Function.Type)
        ),
        /* GetDatasetQueryScaleOutStatusInGroup 
        Fact("GetDatasetQueryScaleOutStatusInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetQueryScaleOutStatusInGroup,Function.Type)
        ), 
        Fact("GetDatasetQueryScaleOutStatusInGroup Should Have a CommitVersion Property and Value",
             true,
             Text.Length(Number.ToText(Json.Document(GetDatasetQueryScaleOutStatusInGroup(ScaleOutWorkspaceID,ScaleOutDatasetID))[#"commitVersion"])) > 0
        ),*/                
        /*
        Fact("GetDatasetDirectQueryRefreshScheduleInGroup Should Be Correct Metadata",
             "datasources",
             Text.AfterDelimiter(Json.Document(GetDatasetDirectQueryRefreshScheduleInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ),*/
        /* GetDatasetParametersInGroup */
        Fact("GetDatasetParametersInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetParametersInGroup,Function.Type)
        ),
        Fact("GetDatasetParametersInGroup Should Be Correct Metadata",
             "parameters",
             Text.AfterDelimiter(Json.Document(GetDatasetParametersInGroup(GroupTestID,DatasetTestID))[#"@odata.context"],"#")
        ),                
        /* GetDatasetRefreshExecutionDetailsInGroup */
        Fact("GetDatasetRefreshExecutionDetailsInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetRefreshExecutionDetailsInGroup,Function.Type)
        ),  
        /* Assumes a refresh exists that was enhanced for this dataset */
        Fact("GetDatasetRefreshExecutionDetailsInGroup Should Have One Object Return with Completed Status",
             "Completed",
             Json.Document(GetDatasetRefreshExecutionDetailsInGroup(GroupTestID, DatasetTestID, EnhancedRefreshTestID))[extendedStatus]
        ),         
        /* GetDatasetRefreshHistoryInGroup*/  
        Fact("GetDatasetRefreshHistoryInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetRefreshHistoryInGroup,Function.Type)
        ),  
        Fact("GetDatasetRefreshHistoryInGroup Should Be Correct Metadata",
             "refreshes",
             Text.AfterDelimiter(Json.Document(GetDatasetRefreshHistoryInGroup(GroupTestID, DatasetTestID))[#"@odata.context"],"#")
        ),             
        /* GetDatasetRefreshScheduleInGroup */            
        Fact("GetDatasetRefreshScheduleInGroup Should Be a Function",
             true,
             Value.Is(GetDatasetRefreshScheduleInGroup,Function.Type)
        ),
        Fact("GetDatasetRefreshScheduleInGroup Should Be Correct Metadata",
             "Microsoft.PowerBI.ServiceContracts.Api.V1.RefreshSchedule",
             Text.AfterDelimiter(Json.Document(GetDatasetRefreshScheduleInGroup(GroupTestID, DatasetTestID))[#"@odata.context"],"#")
        ),        
        /* ExecuteQuery */            
        Fact("ExecuteQuery Should Be a Function",
             true,
             Value.Is(ExecuteQuery,Function.Type)
        ),
        /* ExecuteQueryInGroup */            
        Fact("ExecuteQueryInGroup Should Be a Function",
             true,
             Value.Is(ExecuteQueryInGroup,Function.Type)
        ),
     /*****************
     REPORTS
     *****************/    
        /* GetPaginatedReportDatasourcesInGroup */
        Fact("GetPaginatedReportDatasourcesInGroup Should Be a Function",
             true,
             Value.Is(GetPaginatedReportDatasourcesInGroup,Function.Type)
        ),        
        /* GetReportPageInGroup */            
        Fact("GetReportPageInGroup Should Be a Function",
             true,
             Value.Is(GetReportPageInGroup,Function.Type)
        ),
        Fact("GetReportPageInGroup Should Be Correct Metadata",
             "pages/$entity",
             Text.AfterDelimiter(Json.Document(GetReportPageInGroup(GroupTestID,ReportTestID,"ReportSection"))[#"@odata.context"],"#")
        ),
        /* GetReportPagesInGroup */            
        Fact("GetReportPagesInGroup Should Be a Function",
             true,
             Value.Is(GetReportPagesInGroup,Function.Type)
        ),
        Fact("GetReportPagesInGroup Should Be Correct Metadata",
             "pages",
             Text.AfterDelimiter(Json.Document(GetReportPagesInGroup(GroupTestID,ReportTestID))[#"@odata.context"],"#")
        ),
        Fact("GetReportPagesInGroup Should Have 2 Pages",
             2,
             List.Count(Json.Document(GetReportPagesInGroup(GroupTestID,ReportTestID))[value])
        ),                 
        /* GetReportInGroup */            
        Fact("GetReportInGroup Should Be a Function",
             true,
             Value.Is(GetReportInGroup,Function.Type)
        ),
        Fact("GetReportInGroup Should Be Correct Metadata",
             "reports/$entity",
             Text.AfterDelimiter(Json.Document(GetReportInGroup(GroupTestID,ReportTestID))[#"@odata.context"],"#")
        ),
        Fact("GetReportInGroup Should Have More Than 0 Reports",
             ReportTestName,
             Json.Document(GetReportInGroup(GroupTestID,ReportTestID))[name]
        ), 
        /* GetReportsInGroup */            
        Fact("GetReportsInGroup Should Be a Function",
             true,
             Value.Is(GetReportsInGroup,Function.Type)
        ),
        Fact("GetReportsInGroup Should Be Correct Metadata",
             "reports",
             Text.AfterDelimiter(Json.Document(GetReportsInGroup(GroupTestID))[#"@odata.context"],"#")
        ),
        Fact("GetReportsInGroup Should Have More Than 0 Reports",
             true,
             List.Count(Json.Document(GetReportsInGroup(GroupTestID))[value]) > 0
        ), 
        /* ExportReportInGroup */
        Fact("ExportReportInGroup Should Be a Function",
             true,
             Value.Is(ExportReportInGroup,Function.Type)
        ),
        Fact("ExportReportInGroup Should Return Binary When LiveConnect",
             true,
             Value.Is(ExportReportInGroup(ExportWorkspaceID,ExportReportID,"LiveConnect",false),Binary.Type)
        ),
        Fact("ExportReportInGroup Should Return When IncludeModel",
             true,
             Value.Is(ExportReportInGroup(ExportWorkspaceID,ExportReportID,"IncludeModel",false),Binary.Type)
        ),  
        Fact("ExportReportInGroup Should Return When IncludeModel (Paginated Report)",
             true,
             Value.Is(ExportReportInGroup(ExportWorkspaceID,ExportPaginatedReportID,"IncludeModel",false),Binary.Type)
        ),

     /*****************
     GOAL VALUES
     *****************/
        /* GetScorecardGoalValuesInGroup */
        Fact("GetScorecardGoalValuesInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalValuesInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalValuesInGroup Should Be Correct Metadata",
             true,
             Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalValuesInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID))[#"@odata.context"],"#"),"/metricValues")
        ),       
        Fact("GetScorecardGoalValuesInGroup Should Have Notes",
             true,
             Record.Field(List.First(Json.Document(GetScorecardGoalValuesInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID,"notes"))[#"value"]),"notes") <> null
        ),
        /* GetScorecardGoalValueInGroup */
        Fact("GetScorecardGoalValueInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalValueInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalValueInGroup Should Be Correct Metadata",
             true,
             Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalValueInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID,ScorecardOneGoalTimestampID))[#"@odata.context"],"#"),"/metricValues/$entity")
        ),
        Fact("GetScorecardGoalValueInGroup Should Contain Notes",
             true,
             Json.Document(GetScorecardGoalValueInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID,ScorecardOneGoalTimestampID,"notes"))[#"notes"] <> null
        ),
     /*****************
     GOALS
     *****************/  
        /* GetScorecardGoalsInGroup */
        Fact("GetScorecardGoalsInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalsInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalsInGroup Should Be Correct Metadata",
             "scorecards(" & ScorecardOneTestID & ")/metrics",
             Text.AfterDelimiter(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID))[#"@odata.context"],"#")
        ),
        Fact("GetScorecardGoalsInGroup Should Return Goal With Expected Scorecard Id",
             ScorecardOneTestID,
             Record.Field(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID))[#"value"]),"scorecardId")
        ),
        Fact("GetScorecardGoalsInGroup Should Return Goal Values When Expanded",
             true,
             Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID,"goalValues",null))[#"value"]),"goalValues")
        ),         
        Fact("GetScorecardGoalsInGroup Should Return Aggregations When Expanded",
             true,
             Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID,"goalValues,aggregations",null))[#"value"]),"aggregations")
        ),         
        Fact("GetScorecardGoalsInGroup Should Not Return Scorecard Id Field When Only Name And Level Selected.",
             false,
             Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID,null,"name,level"))[#"value"]),{"scorecardId"})
        ),           
        Fact("GetScorecardGoalsInGroup Should Return Name and Level Fields",
             true,
             Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID,ScorecardOneTestID,null,"name,level"))[#"value"]),{"name","level"})
        ),                         
        /* GetScorecardGoalInGroup */
        Fact("GetScorecardGoalInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalInGroup Should Be Correct Metadata",
             true,
             Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID))[#"@odata.context"],"#"),"/metrics/$entity")
        ),     
        /* GetScorecardGoalRefreshHistoryInGroup */
        Fact("GetScorecardGoalRefreshHistoryInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalRefreshHistoryInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalRefreshHistoryInGroup Should Be Correct Metadata",
            true,
            Text.Contains(Text.AfterDelimiter(Json.Document(GetScorecardGoalRefreshHistoryInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalWithRefreshTestID))[#"@odata.context"],"#"),"Collection(Microsoft.PowerBI.ServiceContracts.Api.GoalRefreshHistory")
        ), 
     /*****************
     GOALS STATUS RULES
     *****************/               
          /* GetScorecardGoalsStatusRulesInGroup */
        Fact("GetScorecardGoalsStatusRulesInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardGoalsStatusRulesInGroup,Function.Type)
        ),
        Fact("GetScorecardGoalsStatusRulesInGroup Should Be Correct Metadata",
            "scorecards(" & ScorecardOneTestID & ")/metrics(" & ScorecardOneGoalTestID & ")/statusRules",
            Text.AfterDelimiter(Json.Document(GetScorecardGoalsStatusRulesInGroup(GroupTestID,ScorecardOneTestID,ScorecardOneGoalTestID))[#"@odata.context"],"#")
        ),  
     /*****************
     GROUPS
     *****************/             
        /* GetGroupUsers */            
        Fact("GetGroupUsers Should Be a Function",
             true,
             Value.Is(GetGroupUsers,Function.Type)
        ),
        Fact("GetGroupUsers Should Be Correct Metadata",
             "users",
             Text.AfterDelimiter(Json.Document(GetGroupUsers(GroupTestID))[#"@odata.context"],"#")
        ),
        Fact("GetGroupUsers Should Have More Than 0 Users",
             true,
             List.Count(Json.Document(GetGroupUsers(GroupTestID))[value]) > 0
        ),                 
        /* GetGroups */            
        Fact("GetGroups Should Be a Function",
             true,
             Value.Is(GetGroups,Function.Type)
        ),
        Fact("GetGroups Should Be Correct Metadata",
             "groups",
             Text.AfterDelimiter(Json.Document(GetGroups())[#"@odata.context"],"#")
        ),
        Fact("GetGroups with filter should return the right workspace",
             GroupTestID,
             Json.Document(GetGroups(GroupNameFilter))[value]{0}[id]
        ),
     /*****************
     PIPELINES
     *****************/        
        /* GetPipeline */
        Fact("GetPipeline Should Be a Function",
             true,
             Value.Is(GetPipeline,Function.Type)
        ),
        Fact("GetPipeline Should Be Correct Metadata",
             "pipelines/$entity",
             Text.AfterDelimiter(Json.Document(GetPipeline(PipelineTestID))[#"@odata.context"],"#")
        ),
        /* GetPipelineOperation */
        Fact("GetPipelineOperation Should Be a Function",
             true,
             Value.Is(GetPipelineOperation,Function.Type)
        ),
        /* GetPipelineOperations */
        Fact("GetPipelineOperations Should Be a Function",
             true,
             Value.Is(GetPipelineOperations,Function.Type)
        ),
        Fact("GetPipelineOperations Should Be Correct Metadata",
             "operations",
             Text.AfterDelimiter(Json.Document(GetPipelineOperations(PipelineTestID))[#"@odata.context"],"#")
        ),
        /* GetPipelineStageArtifacts */
        Fact("GetPipelineStageArtifacts Should Be a Function",
             true,
             Value.Is(GetPipelineStageArtifacts,Function.Type)
        ),
        Fact("GetPipelineStageArtifacts Should Be Correct Metadata",
             "Microsoft.PowerBI.ServiceContracts.Api.PipelineStageArtifacts",
             Text.AfterDelimiter(Json.Document(GetPipelineStageArtifacts(PipelineTestID,0))[#"@odata.context"],"#")
        ),
        Fact("GetPipelineStageArtifacts Should Error if Stage Order Not 0, 1, or 2",
             true,
             /* If table and not json, we know the error message is returned */
             Value.Is(GetPipelineStageArtifacts(PipelineTestID,3),Table.Type)
        ),
        /* GetPipelineStages */
        Fact("GetPipelineStages Should Be a Function",
             true,
             Value.Is(GetPipelineStages,Function.Type)
        ),
        Fact("GetPipelineStages Should Be Correct Metadata",
             "Collection(Microsoft.PowerBI.ServiceContracts.Api.PipelineStage)",
             Text.AfterDelimiter(Json.Document(GetPipelineStages(PipelineTestID))[#"@odata.context"],"#")
        ),
        /* GetPipelineUsers */
        Fact("GetPipelineUsers Should Be a Function",
             true,
             Value.Is(GetPipelineUsers,Function.Type)
        ),
        Fact("GetPipelineUsers Should Be Correct Metadata",
             "Collection(Microsoft.PowerBI.ServiceContracts.Api.PipelineAccessRightEntry)",
             Text.AfterDelimiter(Json.Document(GetPipelineUsers(PipelineTestID))[#"@odata.context"],"#")
        ),
        Fact("GetPipelineUsers Should Have At Least 1 User",
             true,
             List.Count(Json.Document(GetPipelineUsers(PipelineTestID))[value]) > 0
        ),
        /* GetPipelines */
        Fact("GetPipelines Should Be a Function",
             true,
             Value.Is(GetPipelines,Function.Type)
        ),
        Fact("GetPipelines Should Be Correct Metadata",
             "pipelines",
             Text.AfterDelimiter(Json.Document(GetPipelines())[#"@odata.context"],"#")
        ),
     /*****************
     SCORECARDS
     *****************/        
        /* GetScorecardsInGroup */
        Fact("GetScorecardsInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardsInGroup,Function.Type)
        ),
        Fact("GetScorecardsInGroup Should Be Correct Metadata",
             "scorecards",
             Text.AfterDelimiter(Json.Document(GetScorecardsInGroup(GroupTestID))[#"@odata.context"],"#")
        ),
        Fact("GetScorecardsInGroup Should Return Two Scorecards",
             2,
             Json.Document(GetScorecardsInGroup(GroupTestID))[#"@odata.count"]
        ),
        Fact("GetScorecardsInGroup Should Return One Scorecards When Top 1 provided",
             1,
             Json.Document(GetScorecardsInGroup(GroupTestID,1))[#"@odata.count"]
        ),
        /* GetScorecardInGroup */
        Fact("GetScorecardInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardInGroup,Function.Type)
        ),
        /*
        Disable after odatacontext dissappeared
        Fact("GetScorecardInGroup Should Be Correct Metadata",
             "scorecards/$entity",
             Text.AfterDelimiter(Json.Document(GetScorecardInGroup(GroupTestID,ScorecardOneTestID))[#"@odata.context"],"#")
        ),*/
        Fact("GetScorecardInGroup Should Return a goals property",
             true,
             List.Count(Json.Document(GetScorecardInGroup(GroupTestID,ScorecardOneTestID,"goals($expand=goalValues)"))[#"goals"]) > 0
        ),
        Fact("GetScorecardInGroup Should Return a goal values property",
             true,
             Record.Field(List.First(Json.Document(GetScorecardInGroup(GroupTestID,ScorecardOneTestID,"goals($expand=goalValues)"))[#"goals"]),"goalValues") <> null
        ),
        /* GetScorecardByReportIdInGroup */
        Fact("GetScorecardByReportIdInGroup Should Be a Function",
             true,
             Value.Is(GetScorecardByReportIdInGroup,Function.Type)
        ),
        Fact("GetScorecardByReportIdInGroup Should Be Correct Metadata",
             "scorecards/$entity",
             Text.AfterDelimiter(Json.Document(GetScorecardByReportIdInGroup(GroupTestID,ScorecardInternalReportId))[#"@odata.context"],"#")
        ),
        Fact("GetScorecardByReportIdInGroup Should Return a goals property",
             true,
             List.Count(Json.Document(GetScorecardByReportIdInGroup(GroupTestID,ScorecardInternalReportId,"goals($expand=goalValues)"))[#"goals"]) > 0
        ),
        Fact("GetScorecardByReportIdInGroup Should Return a goal values property",
             true,
             Record.Field(List.First(Json.Document(GetScorecardByReportIdInGroup(GroupTestID,ScorecardInternalReportId,"goals($expand=goalValues)"))[#"goals"]),"goalValues") <> null
        )                           
    },
    results = Table.ReverseRows(Table.FromRecords(facts)),
    // Only return failed tests
    results2 = Table.SelectRows(results, each Text.StartsWith([Result],"F"))
][results2];

/// COMMON UNIT TESTING CODE 
Fact = (_subject as text, _expected, _actual) as record =>
[   expected = try _expected,
    safeExpected = if expected[HasError] then "Expected : "& @ValueToText(expected[Error]) else expected[Value],
    actual = try _actual,
    safeActual = if actual[HasError] then "Actual : "& @ValueToText(actual[Error]) else actual[Value],
    attempt = try safeExpected = safeActual,
    result = if attempt[HasError] or not attempt[Value] then "Failure ⛔" else "Success ✓",
    resultOp = if result = "Success ✓" then " = " else " <> ",
    addendumEvalAttempt = if attempt[HasError] then @ValueToText(attempt[Error]) else "",
    addendumEvalExpected = try @ValueToText(safeExpected) otherwise "...",
    addendumEvalActual = try @ValueToText (safeActual) otherwise "...",
    fact =
    [   Result = result &" "& addendumEvalAttempt,
        Notes =_subject,
        Details = " ("& addendumEvalExpected & resultOp & addendumEvalActual &")"
    ]
][fact];

Facts = (_subject as text, _predicates as list) => List.Transform(_predicates, each Fact(_subject,_{0},_{1}));

Facts.Summarize = (_facts as list) as table =>
[   Fact.CountSuccesses = (count, i) =>
    [   result = try i[Result],
        sum = if result[HasError] or not Text.StartsWith(result[Value], "Success") then count else count + 1
    ][sum],
    passed = List.Accumulate(_facts, 0, Fact.CountSuccesses),
    total = List.Count(_facts),
    format = if passed = total then "All #{0} Passed !!! ✓" else "#{0} Passed ☺  #{1} Failed ☹",
    result = if passed = total then "Success" else "⛔",
    rate = Number.IntegerDivide(100*passed, total),
    header =
    [   Result = result,
        Notes = Text.Format(format, {passed, total-passed}),
        Details = Text.Format("#{0}% success rate", {rate})
    ],
    report = Table.FromRecords(List.Combine({{header},_facts}))
][report];

ValueToText = (value, optional depth) =>
    let
        List.TransformAndCombine = (list, transform, separator) => Text.Combine(List.Transform(list, transform), separator),

        Serialize.Binary =      (x) => "#binary(" & Serialize(Binary.ToList(x)) & ") ",

        Serialize.Function =    (x) => _serialize_function_param_type(
                                          Type.FunctionParameters(Value.Type(x)),
                                          Type.FunctionRequiredParameters(Value.Type(x)) ) &
                                       " as " &
                                       _serialize_function_return_type(Value.Type(x)) &
                                       " => (...) ",

        Serialize.List =        (x) => "{" & List.TransformAndCombine(x, Serialize, ", ") & "} ",

        Serialize.Record =      (x) => "[ " &
                                       List.TransformAndCombine(
                                            Record.FieldNames(x), 
                                            (item) => Serialize.Identifier(item) & " = " & Serialize(Record.Field(x, item)),
                                            ", ") &
                                       " ] ",

        Serialize.Table =       (x) => "#table( type " &
                                        _serialize_table_type(Value.Type(x)) &
                                        ", " &
                                        Serialize(Table.ToRows(x)) &
                                        ") ",
                                    
        Serialize.Identifier =  Expression.Identifier,

        Serialize.Type =        (x) => "type " & _serialize_typename(x),
                                    
                             
        _serialize_typename =    (x, optional funtype as logical) =>                        /* Optional parameter: Is this being used as part of a function signature? */
                                    let
                                        isFunctionType = (x as type) => try if Type.FunctionReturn(x) is type then true else false otherwise false,
                                        isTableType = (x as type) =>  try if Type.TableSchema(x) is table then true else false otherwise false,
                                        isRecordType = (x as type) => try if Type.ClosedRecord(x) is type then true else false otherwise false,
                                        isListType = (x as type) => try if Type.ListItem(x) is type then true else false otherwise false
                                    in
                                
                                        if funtype=null and isTableType(x) then _serialize_table_type(x) else
                                        if funtype=null and isListType(x) then "{ " & @_serialize_typename( Type.ListItem(x) ) & " }" else
                                        if funtype=null and isFunctionType(x) then "function " & _serialize_function_type(x) else
                                        if funtype=null and isRecordType(x) then _serialize_record_type(x) else
                                    
                                        if x = type any then "any" else
                                        let base = Type.NonNullable(x) in
                                          (if Type.IsNullable(x) then "nullable " else "") &       
                                          (if base = type anynonnull then "anynonnull" else                
                                          if base = type binary then "binary" else                
                                          if base = type date   then "date"   else
                                          if base = type datetime then "datetime" else
                                          if base = type datetimezone then "datetimezone" else
                                          if base = type duration then "duration" else
                                          if base = type logical then "logical" else
                                          if base = type none then "none" else
                                          if base = type null then "null" else
                                          if base = type number then "number" else
                                          if base = type text then "text" else 
                                          if base = type time then "time" else 
                                          if base = type type then "type" else 
                                      
                                          /* Abstract types: */
                                          if base = type function then "function" else
                                          if base = type table then "table" else
                                          if base = type record then "record" else
                                          if base = type list then "list" else
                                      
                                          "any /*Actually unknown type*/"),

        _serialize_table_type =     (x) => 
                                           let 
                                             schema = Type.TableSchema(x)
                                           in
                                             "table " &
                                             (if Table.IsEmpty(schema) then "" else 
                                                 "[" & List.TransformAndCombine(
                                                     Table.ToRecords(Table.Sort(schema,"Position")),
                                                     each Serialize.Identifier(_[Name]) & " = " & _[Kind],
                                                     ", ") &
                                                 "] "),

        _serialize_record_type =    (x) => 
                                            let flds = Type.RecordFields(x)
                                            in
                                                if Record.FieldCount(flds)=0 then "record" else
                                                    "[" & List.TransformAndCombine(
                                                        Record.FieldNames(flds),
                                                        (item) => Serialize.Identifier(item) & "=" & _serialize_typename(Record.Field(flds,item)[Type]),
                                                        ", ") & 
                                                    (if Type.IsOpenRecord(x) then ", ..." else "") &
                                                    "]",

        _serialize_function_type =  (x) => _serialize_function_param_type(
                                              Type.FunctionParameters(x),
                                              Type.FunctionRequiredParameters(x) ) &
                                            " as " &
                                            _serialize_function_return_type(x),
    
        _serialize_function_param_type = (t,n) => 
                                let
                                    funsig = Table.ToRecords(
                                        Table.TransformColumns(
                                            Table.AddIndexColumn( Record.ToTable( t ), "isOptional", 1 ),
                                            { "isOptional", (x)=> x>n } ) )
                                in
                                    "(" & 
                                    List.TransformAndCombine(
                                        funsig,
                                        (item)=>
                                            (if item[isOptional] then "optional " else "") &
                                            Serialize.Identifier(item[Name]) & " as " & _serialize_typename(item[Value], true),
                                        ", ") &
                                     ")",

        _serialize_function_return_type = (x) => _serialize_typename(Type.FunctionReturn(x), true), 

        Serialize = (x) as text => 
                           if x is binary       then try Serialize.Binary(x) otherwise "null /*serialize failed*/"        else 
                           if x is date         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is datetime     then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is datetimezone then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is duration     then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is function     then try Serialize.Function(x) otherwise "null /*serialize failed*/"      else 
                           if x is list         then try Serialize.List(x) otherwise "null /*serialize failed*/"          else 
                           if x is logical      then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                           if x is null         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                           if x is number       then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else
                           if x is record       then try Serialize.Record(x) otherwise "null /*serialize failed*/"        else 
                           if x is table        then try Serialize.Table(x) otherwise "null /*serialize failed*/"         else 
                           if x is text         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is time         then try Expression.Constant(x) otherwise "null /*serialize failed*/"     else 
                           if x is type         then try Serialize.Type(x) otherwise "null /*serialize failed*/"          else 
                           "[#_unable_to_serialize_#]"                     
    in
        try Serialize(value) otherwise "<serialization failed>";