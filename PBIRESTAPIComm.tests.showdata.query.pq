section UnitTestingUnitTests;

shared MyExtension.UnitTest =
[
    Source = PBIRESTAPIComm.FunctionCatalog(),
    
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),
    
    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,
    
    ExecuteQuery = _GetFunction("ExecuteQuery"),
    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    
    DateDimQuery = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    
    // Get JSON baseline results
    ExecuteQueryResult = Json.Document(ExecuteQuery(DatasetTestID, DateDimQuery)),
    ExecuteQueryRows = ExecuteQueryResult[results]{0}[tables]{0}[rows],
    ExecuteQueryTable = Table.FromRecords(ExecuteQueryRows),
    
    // Get Arrow candidate results
    ExecuteDaxQueriesTable = ExecuteDaxQueries(DatasetTestID, DateDimQuery),
    
    // Create side-by-side comparison
    OutputRecord = [
        Query = DateDimQuery,
        #"ExecuteQuery (JSON Baseline)" = ExecuteQueryTable,
        #"ExecuteDaxQueries (Arrow IPC)" = ExecuteDaxQueriesTable,
        #"Row Count Match" = Table.RowCount(ExecuteQueryTable) = Table.RowCount(ExecuteDaxQueriesTable),
        #"Column Count Match" = Table.ColumnCount(ExecuteQueryTable) = Table.ColumnCount(ExecuteDaxQueriesTable),
        #"Column Names Match" = Table.ColumnNames(ExecuteQueryTable) = Table.ColumnNames(ExecuteDaxQueriesTable)
    ],
    
    results = Table.FromRecords({OutputRecord})
][results];
