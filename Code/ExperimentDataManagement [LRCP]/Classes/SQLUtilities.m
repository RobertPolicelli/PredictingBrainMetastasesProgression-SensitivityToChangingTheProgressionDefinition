classdef SQLUtilities
    %SQLUtilities
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = SQLUtilities()        
        end
    end
    
    
    methods (Access = public, Static)
        
        function oSQLDB = ConnectToMySQLDatabase()
            
            [sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword] = FileIOUtils.LoadMatFile(...
                Experiment.GetDataPath('MySQLConnectionSettings'),...
                'sMySQLDataSourceName', 'sMySQLServerUsername', 'sMySQLServerPassword');
            
            oSQLDB = database(sMySQLDataSourceName, sMySQLServerUsername, sMySQLServerPassword);
            oSQLDB.AutoCommit = 'off'; % so bad, why would this not be default
        end
        
        function [dIDOfInsertedRow, sQuery] = InsertIntoDatabase(oSQLDB, sTable, vsSQLColumnsToInsert, c1xSQLValuesToInsert)
            arguments
                oSQLDB (1,1) database.odbc.connection
                sTable (1,1) string
                vsSQLColumnsToInsert (1,:) string
                c1xSQLValuesToInsert (1,:) cell
            end
                        
            sColumns = strjoin(vsSQLColumnsToInsert, ", ");
            
            dNumValues = length(c1xSQLValuesToInsert);
            vsValues = strings(1, dNumValues);
            
            for dValueIndex=1:dNumValues
                vsValues(dValueIndex) = SQLUtilities.ConvertDataToStringForQuery(c1xSQLValuesToInsert{dValueIndex});
            end
                        
            sValues = strjoin(vsValues, ", ");
            
            sQuery = "INSERT INTO " + sTable + " (" + sColumns + ") VALUES (" + sValues + ")";
            
            oSQLDB.execute(sQuery);
            
            tOutput = oSQLDB.select('SELECT LAST_INSERT_ID()');
            dIDOfInsertedRow = double(tOutput.LAST_INSERT_ID__);
        end
        
        function sQuery = UpdateDatabase(oSQLDB, sTable, vsSQLColumnsToUpdate, c1xSQLValuesToUpdate, sWhereQuery)
            arguments
                oSQLDB (1,1) database.odbc.connection
                sTable (1,1) string
                vsSQLColumnsToUpdate (1,:) string
                c1xSQLValuesToUpdate (1,:) cell
                sWhereQuery (1,1) string
            end
                                
            sWhereQuery = strrep(sWhereQuery, "WHERE", "");
            
            dNumValues = length(c1xSQLValuesToUpdate);
            vsValues = strings(1, dNumValues);
            
            for dValueIndex=1:dNumValues
                vsValues(dValueIndex) = SQLUtilities.ConvertDataToStringForQuery(c1xSQLValuesToUpdate{dValueIndex});
            end
                        
            sValues = strjoin(vsSQLColumnsToUpdate + " = " + vsValues, ", ");
            
            sQuery = "UPDATE " + sTable + " SET " + sValues + " WHERE " + sWhereQuery;
            oSQLDB.execute(sQuery);
        end
        
        function tOutput = SelectFromDatabase(oSQLDB, sTableOrJoinStatement, vsSQLColumnsToInclude, sWhereQuery, sOrderByQuery)
            arguments
                oSQLDB
                sTableOrJoinStatement (1,1) string
                vsSQLColumnsToInclude (1,:)
                sWhereQuery (1,1) string = ""
                sOrderByQuery (1,1) string = ""
            end
                        
            if isempty(vsSQLColumnsToInclude)
                sColumns = "*";
            else
                sColumns = strjoin(vsSQLColumnsToInclude, ", ");
            end
            
            tOutput = oSQLDB.fetch("SELECT " + sColumns + " FROM " + sTableOrJoinStatement + " " + sWhereQuery + " " + sOrderByQuery);
            
            % set all numeric columns returned to be cell arrays and set
            % all NULL (e.g. "missing") values to be []
            if ~isempty(tOutput)
                vsColumnNames = string(tOutput.Properties.VariableNames);
                
                for dColIndex=1:length(vsColumnNames)
                    sColName = vsColumnNames(dColIndex);
                    
                    if iscell(tOutput.(sColName)(1)) % is a char so convert to string, nulls set to string.empty
                        tOutput.(sColName) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(string(tOutput.(sColName)));
                        
                        vbIsEmpty = false(size(tOutput.(sColName)));
                        
                        for dRowIndex=1:length(tOutput.(sColName))
                            if strcmp(tOutput.(sColName){dRowIndex}, '')
                                tOutput.(sColName)(dRowIndex) = {string.empty};
                                vbIsEmpty(dRowIndex) = true;
                            end
                        end
                        
                        dFirstNonEmptyRow = find(~vbIsEmpty,1);
                        
                        if ~isempty(dFirstNonEmptyRow)
                            sValue = tOutput.(sColName){dFirstNonEmptyRow};
                            
                            try
                                if sValue.strlength == 10
                                    chDatetimeFormat = "yyyy-MM-dd";
                                else
                                    chDatetimeFormat = "yyyy-MM-dd HH:mm:ss";
                                end
                                    
                                dtDatetime = datetime(sValue,'InputFormat',chDatetimeFormat);
                                
                                % if doesn't fail, its a datetime
                                vsInput = tOutput.(sColName);
                                vsInput(vbIsEmpty) = {""};
                                
                                vdtDatetimes = datetime(cellstr(vsInput),'InputFormat',chDatetimeFormat);
                                
                                vbIsNaT = isnat(vdtDatetimes);
                                
                                tOutput.(sColName) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdtDatetimes);
                                tOutput.(sColName)(vbIsNaT) = {datetime.empty};
                            catch e
                            end
                        end
                    else % is double
                        vbIsMissing = isnan(tOutput.(sColName));
                        tOutput.(sColName) = CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(tOutput.(sColName));
                        tOutput.(sColName)(vbIsMissing) = {[]};
                    end
                end
            end
        end
        
        function sQuery = DeleteFromDatabase(oSQLDB, sTable, sWhereQuery)
            arguments
                oSQLDB (1,1) database.odbc.connection
                sTable (1,1) string
                sWhereQuery (1,1) string
            end
            
            sWhereQuery = strrep(sWhereQuery, "WHERE", "");
            
            sQuery = "DELETE FROM " + sTable + " WHERE " + sWhereQuery;
            
            oSQLDB.execute(sQuery);
        end
        
        function sWhereQuery = CreateWhereStatementForEqualityOnAllColumnValues(vsColumnNames, c1xColumnValues)
            dNumValues = length(c1xColumnValues);
            vsValues = strings(1, dNumValues);
            
            for dValueIndex=1:dNumValues
                vsValues(dValueIndex) = SQLUtilities.ConvertDataToStringForQuery(c1xColumnValues{dValueIndex});
            end
            
            sWhereQuery = "WHERE " + strjoin(vsColumnNames + " = " + vsValues, " AND ");
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function sValue = ConvertDataToStringForQuery(xValue)
              
            if isempty(xValue)
                sValue = "NULL";
            elseif islogical(xValue)
                if xValue
                    sValue = "TRUE";
                else
                    sValue = "FALSE";
                end
            elseif isnumeric(xValue)
                sValue = string(xValue);
            elseif ischar(xValue)
                sValue = string(xValue);
                
                sValue = strrep(sValue, "\", "\\");
                sValue = strrep(sValue, "'", "''");
                
                sValue = "'" + sValue + "'";  
            elseif isstring(xValue)
                if xValue == ""
                    sValue = "NULL";
                else                
                    sValue = strrep(xValue, "\", "\\");
                    sValue = strrep(sValue, "'", "''");
                    
                    sValue = "'" + sValue + "'";                
                end
            elseif isdatetime(xValue)
                if length(xValue.Format) == 10
                    sValue = string(datestr(xValue, "'yyyy-mm-dd'"));
                else
                    sValue = string(datestr(xValue, "'yyyy-mm-dd HH:MM:SS'"));
                end
            elseif isenum(xValue)
                sValue = "'" + xValue.GetMySQLEnumValue() + "'";
            else
                error(...
                    'SQLUtilities:InsertIntoDatabase:InvalidValueType',...
                    'Value datatype not supported.');
            end
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

