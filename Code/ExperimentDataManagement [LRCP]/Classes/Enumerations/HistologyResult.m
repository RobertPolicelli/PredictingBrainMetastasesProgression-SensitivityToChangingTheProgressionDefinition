classdef HistologyResult
    %HistologyResult
    
    properties
        chResultName
        chDatabaseLabel
    end
    
    enumeration
        adenocarcinoma('Adenocarcinoma', 'adeno')
        nonSmallCellLungCarcinoma('Non-Small Cell Lung Carcinoma', 'nsclc')
        squamousCarcinoma('Squamous Call Carcinoma','squamous')
        melanoma('Melanoma','melanoma')
        urothelialCarcinoma('Urothelial Carcinoma','urotheel')
        renal('Renal','grawitz')
        papillary('Papillary','papilair')
        smallCell('Small Cell Lung Carcinoma','smallcel')
        sarcoma('Sarcoma','sarcoom');
    end
    
    methods
        function enum = HistologyResult(chResultName, chDatabaseLabel)
            enum.chResultName = chResultName;
            enum.chDatabaseLabel = chDatabaseLabel;
        end
        
        function chString = getString(enum)
            chString = enum.chResultName;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseLabel(label)
            switch label
                case HistologyResult.adenocarcinoma.databaseLabel
                    enum = HistologyResult.adenocarcinoma;
                case HistologyResult.nonSmallCellLungCarcinoma.databaseLabel
                    enum = HistologyResult.nonSmallCellLungCarcinoma;
                case HistologyResult.squamousCarcinoma.databaseLabel
                    enum = HistologyResult.squamousCarcinoma;
                case HistologyResult.melanoma.databaseLabel
                    enum = HistologyResult.melanoma;
                case HistologyResult.urothelialCarcinoma.databaseLabel
                    enum = HistologyResult.urothelialCarcinoma;
                case HistologyResult.renal.databaseLabel
                    enum = HistologyResult.renal;
                case HistologyResult.papillary.databaseLabel
                    enum = HistologyResult.papillary;
                case HistologyResult.smallCell.databaseLabel
                    enum = HistologyResult.smallCell;
                case HistologyResult.sarcoma.databaseLabel
                    enum = HistologyResult.sarcoma;
                otherwise
                    error(['Invalid database Histology Result label: ', label]);
            end
        end
    end
end

