# Power Query Custom Data Connector for Power BI REST APIs (Commercial)

This Custom Data Connector wraps many of the "Get" endpoints in the Power BI API (with the exception of the /executeQueries endpoint), so that OAuth can be used to authenticate to the service.  This connector serves as a way to have a library of Power Query functions to build datasets based on the Power BI APIs without the need for storing client secrets or passwords in the dataset.  

Each function returns a JSON body and not a table of data.  This decision was made to provide flexibility in converting the JSON body to tabular data when 1) the API responses are changed by Microsoft or 2) the API responses differ between commercial and sovereign clouds (e.g., GCC, DoD, etc.). 

## Table of Contents

1. [Installation](#installation)
    1. [Desktop](#desktop)
    1. [Using Functions](#using-functions)
    1. [Functions Implemented](#functions-implemented)
    1. [On-Premises Gateway](#on-premises-gateway)
1. [Building Connector](#building-connector)
    1. [Testing Connector](#testing-connector)


## Installation

### Desktop
1. Open Power BI Desktop and navigate to File -> Options and Settings -> Options.
2. Navigate to GLOBAL -> Security and under "Data Extensions" choose "Allow any extension..."

![Allow extension](./documentation/images/options-update.png)

Because this is a custom data connector you have to choose this option in order to use it in Power BI Desktop.

3. Close all Power BI Desktop instances on your local machine.  You are often prompted to do so by Power BI Desktop.
4. Copy the [.mez file](https://github.com/kerski/powerquery-connector-pbi-rest-api-commercial/releases/download/v1.1.0-beta/powerquery-connector-pbi-rest-api-commercial.mez) to your folder "Documents\Power BI Desktop\Custom Connectors".  If the folder does not exist, create it first.
5. Open Power BI Desktop.
6. Select Get Data option.
7. Navigate to the "Other" section and you should see the "Connect to Power BI REST API" connector.

![Other->PBIRESTAPIGCC](./documentation/images/pbi-other-connect.png)

8. Select the connector and press the "Connect" button.
9. You may be prompted with the pop-up below. Choose "Continue".

![Connector Popup](./documentation/images/connector-pop-up.png)

10. If this is your first time using the custom data connector you will be prompted to sign into Office 365. Please follow the instructions to sign in and then choose the "Connect" button.

![Sign in prompt](./documentation/images/sign-in.png)

10. The Navigator prompt will appear (example below).

![Navigator prompt](./documentation/images/navigator.png)

11. Choose the "GetApps" option and you should see a json response (see example below).

![GetApps](./documentation/images/get-apps.png)

12. Then choose the "Transform Data" button.  This should open the Power Query Editor.

![GetApps in Power Query Editor](./documentation/images/get-apps-pq.png)

13. Under "Applied Steps", remove the steps "Invoked FunctionGetApps1" and "Navigation".

![Remove Steps](./documentation/images/remove-steps.png)

14. You now will see a catalog of the Power BI REST APIs to leverage.  I suggest you rename the Query "GetApps" to "Function Catalog".

![Function Catalog](./documentation/images/function-catalog.png)

15. I suggest you also uncheck "Enable Load" for the Function Catalog so it doesn't appear in the data model. When disabled the Function Catalog will appear italicized.

![Disable Function Catalog Load](./documentation/images/disable-load.png)

### Using Functions

With the Function Catalog created, please follow these steps to leverage the functions:

1. Identify the name of the function you wish to use. Right-click on the "Function" value located for the appropriate row and select "Add as New Query".

![Add as New Query](./documentation/images/add-as-new-query.png)

2. The function will be created and it can now be used to query the Power BI service.

![New Function](./documentation/images/new-function.png)

### Functions Implemented

Not all functions from the Power BI REST API have been implemented.  Here are the endpoints available at the moment.

### Apps
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetApp                        | Returns the specified installed app.  | [Apps - Get App](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-app) |
| GetApps                       | Returns a list of installed apps.  | [Apps - Get Apps](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-apps) |
| GetDashboardInApp             | Returns the specified dashboard from the specified app.  | [Apps - Get Dashboard](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-dashboard) |
| GetDashboardsInApp            | Returns a list of dashboards from the specified app.  | [Apps - Get Dashboards](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-dashboards) |
| GetReportInApp                | Returns the specified report from the specified app.  | [Apps - Get Reports](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-report) |
| GetReportsInApp               | Returns a list of reports from the specified app.  | [Apps - Get Reports](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-reports) |
| GetTileInApp           | Returns the specified tile within the specified dashboard from the specified app. Supported tiles include datasets and live tiles that contain an entire report page.   | [Apps - Get Tile](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-tile)
| GetTilesInApp               | Returns a list of tiles within the specified dashboard from the specified app.  | [Apps - Get Tiles](https://learn.microsoft.com/en-us/rest/api/power-bi/apps/get-tiles) |

### Dashboards
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetDashboardInGroup                  | Returns the specified dashboard from the specified workspace.  | [Dashboards - Get Dashboard In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-dashboard-in-group) |
| GetDashboardsInGroup                  | Returns a list of dashboards from the specified workspace.  | [Dashboards - Get Dashboards In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-dashboards-in-group) |
| GetDashboardTileInGroup                  |Returns the specified tile within the specified dashboard from the specified workspace. Supported tiles include datasets and live tiles that contain an entire report page.  | [Dashboards - Get Dashboard Tile In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-tile-in-group) |
| GetDashboardTilesInGroup                  |Returns a list of tiles within the specified dashboard from the specified workspace. Supported tiles include datasets and live tiles that contain an entire report page.  | [Dashboards - Get Dashboard Tiles In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/dashboards/get-tiles-in-group) |

### Dataflows
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetDataflowInGroup                  | Exports the specified dataflow definition to a JSON file.  | [Dataflows - Get Dataflow](https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflow) |
| GetDataflowDataSourcesInGroup                 | Returns a list of data sources for the specified dataflow.  | [Dataflows - Get Dataflow Data Sources](https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflow-data-sources) |
| GetDataflowTransactionsInGroup                 | Returns a list of transactions for the specified dataflow.  | [Dataflows - Get Dataflow Transactions](https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflow-transactions) |
| GetDataflowsInGroup                 | Returns a list of all dataflows from the specified workspace.  | [Dataflows - Get Dataflows](https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-dataflows) |
| GetUpstreamDataflowsInGroup                 | Returns a list of upstream dataflows for the specified dataflow.  | [Dataflows - Get Upstream Dataflows In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/dataflows/get-upstream-dataflows-in-group) |


### Datasets
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetDatasetDiscoverGatewaysInGroup                  | Returns a list of gateways that the specified dataset from the specified workspace can be bound to.  | [Datasets - Discover Gateways In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/discover-gateways-in-group#gateways) |
| ExecuteQuery                  | Executes a single Data Analysis Expressions (DAX) query against a dataset.  | [Dataset - Execute Queries](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries) |
| ExecuteQueryInGroup                 | Executes a single Data Analysis Expressions (DAX) query against a dataset within a workspace. | [Dataset - Execute Queries In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries-in-group) |
| GetDatasetInGroup             | Returns the specified dataset from the specified workspace.  | [Datasets - Get Dataset In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset-in-group) |
| GetDatasetToDataflowsLinksInGroup             | Returns a list of upstream dataflows for datasets from the specified workspace.  | [Datasets - Get Dataset To Dataflows Links In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset-to-dataflows-links-in-group) |
| GetDatasetUsersInGroup            | Returns a list of principals that have access to the specified dataset.  | [Datasets - Get Dataset Users In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-dataset-users-in-group) |
| GetDatasetsInGroup            | Returns a list of datasets from the specified workspace.  | [Datasets - Get Datasets In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-datasets-in-group) |
| GetDatasetDatasourcesInGroup             | Returns a list of data sources for the specified dataset from the specified workspace.  | [Datasets - Get Datasources In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-datasources-in-group) |
| GetDatasetDirectQueryRefreshScheduleInGroup             | Returns the refresh schedule for a specified DirectQuery or LiveConnection dataset from the specified workspace.  | [Datasets - Get Direct Query Refresh Schedule In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-direct-query-refresh-schedule-in-group) |
| GetDatasetParametersInGroup             | Returns a list of parameters for the specified dataset from the specified workspace.  | [Datasets - Get Parameters In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-parameters-in-group) |
| GetDatasetRefreshExecutionDetailsInGroup             | Returns execution details of an enhanced refresh operation for the specified dataset from the specified workspace.  | [Datasets - Get Refresh Execution Details In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-execution-details-in-group) |
| GetDatasetRefreshHistoryInGroup| Returns the refresh history for the specified dataset from the specified workspace.  | [Datasets - Get Refresh History](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-history-in-group) |
| GetDatasetRefreshScheduleInGroup|      Description  | [Datasets - Get Refresh Schedule In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/get-refresh-schedule-in-group) |

### GoalValues (Preview)
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetScorecardGoalValuesInGroup                 | Reads goal value check-ins.  | [GoalValues - Get](https://learn.microsoft.com/en-us/rest/api/power-bi/goalvalues_(preview)/get) |
| GetScorecardGoalValueInGroup                 | Reads a goal value check-in by a UTC date timestamp.  | [GoalValues - Get By ID](https://learn.microsoft.com/en-us/rest/api/power-bi/goalvalues_(preview)/get-by-id) |

### Goals (Preview)
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetScorecardGoalsInGroup                 | Returns a list of goals from a scorecard.  | [Goals - Get](https://learn.microsoft.com/en-us/rest/api/power-bi/goals_(preview)/get) |
| GetScorecardGoalInGroup                 | Returns a goal by ID from a scorecard.  | [Goals - Get By ID](https://learn.microsoft.com/en-us/rest/api/power-bi/goals_(preview)/get-by-id) |
| GetScorecardGoalRefreshHistoryInGroup   | Reads refresh history of a connected goal.  | [Goals - Get Refresh History](https://learn.microsoft.com/en-us/rest/api/power-bi/goals_(preview)/get-refresh-history) |

### Goals Status Rules (Preview)
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetScorecardGoalsStatusRulesInGroup                 | Returns status rules of a goal.  | [GoalsStatusRules - Get](https://learn.microsoft.com/en-us/rest/api/power-bi/goalsstatusrules_(preview)/get) |


### Groups
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetGroupUsers                 | Returns a list of users that have access to the specified workspace.  | [Groups - Get Group Users](https://learn.microsoft.com/en-us/rest/api/power-bi/groups/get-group-users) |
| GetGroups                     | Returns a list of workspaces the user has access to.  | [Groups - Get Groups](https://learn.microsoft.com/en-us/rest/api/power-bi/groups/get-groups) |

### Pipelines
| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
 GetPipeline             | Returns the specified deployment pipeline.  | [Pipelines - Get Pipeline](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline) |
GetPipelineOperation            | Returns the details of the specified deploy operation performed on the specified deployment pipeline, including the deployment execution plan.  | [Pipelines - Get Pipeline Operation](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-operation) |
GetPipelineOperations             | Returns a list of the up-to-20 most recent deploy operations performed on the specified deployment pipeline.  | [Pipelines - Get Pipeline Operations](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-operations) |
GetPipelineStageArtifacts             | Returns the supported items from the workspace assigned to the specified stage of the specified deployment pipeline.  | [Pipelines - Get Pipeline Stage Artifacts](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-stage-artifacts) |
GetPipelineStages            | Returns the stages of the specified deployment pipeline.  | [Pipelines - Get Pipeline Stages](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-stages) |
GetPipelineUsers            | Returns a list of users that have access to the specified deployment pipeline.  | [Pipelines - Get Pipeline Users](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipeline-users) |
GetPipelines           | Returns a list of deployment pipelines that the user has access to.  | [Pipelines - Get Pipelines](https://learn.microsoft.com/en-us/rest/api/power-bi/pipelines/get-pipelines) |

### Reports

| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetPageInGroup         | Returns the specified page within the specified report from the specified workspace.  | [Reports - Get Page In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-page-in-group) |
| GetPagesInGroup          | Returns a list of pages within the specified report from the specified workspace.  | [Reports - Get Pages In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-pages-in-group) |
| GetReportInGroup          | Returns the specified report from the specified workspace.  | [Reports - Get Report In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-report-in-group) |
| GetReportsInGroup         | Returns a list of reports from the specified workspace.  | [Reports - Get Reports In Group](https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-reports-in-group) |

### Scorecards (Preview)

| End Point                      | Description  | MSDN Documentation |
|:-----------------------------|:-------------|:------------------|
| GetScorecardsInGroup         | Returns a list of scorecards from a workspace.  | [Scorecards - Get](https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get) |
| GetScorecardInGroup         | Returns a scorecard with ID.  | [Scorecards - Get By ID](https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get-by-id) |
| GetScorecardByReportIdInGroup         | Reads a scorecard associated with an internal report ID.  | [Scorecards - Get Scorecard By Report Id](https://learn.microsoft.com/en-us/rest/api/power-bi/scorecards_(preview)/get-scorecard-by-report-id) |

### On-Premises Gateway

The custom data connector will need to be installed in the a Power BI Gateway in order to refresh datasets leveraging this custom connector.  For more information on installing a custom data connector with a gateway please see: https://learn.microsoft.com/en-us/power-bi/connect-data/service-gateway-custom-connectors.

## Building Connector

### Prerequisites 

1. Install Visual Studio code: https://code.visualstudio.com/download.
1. Install Power Query SDK for Visual Studio Code: https://github.com/microsoft/vscode-powerquery-sdk
1. Clone this repo to your local machine.

## Compile

In order to the compile the custom data connector to the .mez file, please follow these instructions:

1. Using your keyboard, use the shortcut Ctrl+Shift+B.  Visual Studio will prompt you within the command palette to choose a build task. Select the "build: Build connector project using MakePQX".

![Build](./documentation/images/build-mez.png)

2. If the build succeeds the .mez file will update in the folder "bin\AnyCPU\Debug".

3. If the build fails the Power Query SDK often presents a notification (see example below).

![Failed Build](./documentation/images/failed-build.png)

### Testing Connector

In order to test the custom data connector, please follow these instructions:

1. Choose the "Set Credential" option within the Power Query SDK. Select AAD and follow the prompts to log into Microsoft 365.

![Set Credential](./documentation/images/set-credential.png)

2. The .query.pq file is used to test the custom data connector, please update the section labeled "TEST VARIABLES" for your own environment.

![Test Variables](./documentation/images/test-variables.png)

3. When you are ready to test, use the "Evaluate current file" option in the Power Query SDK in the "Explorer" tab.

![Evaluate](./documentation/images/evaluate-test-file.png)

4. When the testing completes, a new tab will be present any failed results or if all the tests passed (example below).

![Test Results](./documentation/images/test-results.png)