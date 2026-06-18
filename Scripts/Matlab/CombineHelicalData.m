function CombineHelicalData(masterFolder, outputCSV)
% combineHelicalData - Automated ETL pipeline for biophysical parameter aggregation.
% Recursively scans nested directory structures for workspace variables (.mat),
% extracts polymorphic feature records, applies data cleaning transformations, 
% and exports a unified master analytics dataset (.csv).
%
% This workflow replaces manual, error-prone spreadsheets with programmatic 
% data consolidation, standardizing features for downstream machine learning.

    % Recursively locate all nested data source components
    files = dir(fullfile(masterFolder, '**', '*.mat'));

    if isempty(files)
        error('Execution halted: No valid data sources (.mat) detected.');
    end

    masterTable = table();

    for k = 1:length(files)

        filePath = fullfile(files(k).folder, files(k).name);
        fprintf('Processing structural profile: %s\n', filePath);

        S = load(filePath);
        varNames = fieldnames(S);
        data = S.(varNames{1});   % Target primary workspace entity

        if ~isstruct(data)
            warning('Structural anomaly: Skipping non-struct file: %s', filePath);
            continue;
        end

        % Extract EMDB identifier from parent node string architecture
        [~, emdbEntry] = fileparts(files(k).folder);

        % ---------------------------------------------------------
        % Transform & Clean Features into Standard Matrix Format
        % ---------------------------------------------------------
        T = table();

        T.EMDB_entry = string(emdbEntry);

        T.Rise_nm   = safeGetField(data, {'Rise','Rise_nm','Rise (nm)'});
        T.Twist_deg = safeGetField(data, {'Twist','Twist_deg','Twist (°)'});
        T.Symmetry  = safeGetField(data, {'Symmetry'});

        pitchVal = safeGetField(data, {'Pitch','Pitch_nm','Pitch (nm)'});
        codVal   = safeGetField(data, {'COD','Cod','COD (nm)'});

        T.Pitch_nm = pitchVal;
        T.COD_minus_Pitch = codVal - pitchVal;

        T.DPF = safeGetField(data, {'DPF'});
        T.CsaEM = safeGetField(data, {'CsaEM','csaEM','CSAEM'});

        % Extract vertical boundary measurements
        h_min  = safeGetField(data, {'h_min'});
        h_max  = safeGetField(data, {'h_max'});
        h_mean = safeGetField(data, {'h_mean'});

        T.Min_Height_nm  = h_min;
        T.Max_Height_nm  = h_max;
        T.Mean_Height_nm = h_mean;

        % ---------------------------------------------------------
        % Feature Engineering: Calculate Roundness Metric
        % ---------------------------------------------------------
        if ~isnan(h_min) && ~isnan(h_max) && h_max ~= 0
            T.Roundness_Index = h_min / h_max;
        else
            T.Roundness_Index = NaN;
        end

        % Append clean row to the structural master matrix
        masterTable = [masterTable; T];
    end

    % Load matrix arrays into a single comma-separated values file
    writetable(masterTable, outputCSV);

    fprintf('\nETL Complete. Consolidated %d profiles into target file:\n%s\n', length(files), outputCSV);
end


% =========================================================================
% Helper Function: Robust Scalar Field Feature Extractor
% =========================================================================
function val = safeGetField(S, possibleNames)
% Standardizes varying field name nomenclature to prevent extraction faults

    fields = fieldnames(S);
    val = NaN;

    for i = 1:length(possibleNames)

        idx = find(strcmpi(fields, possibleNames{i}), 1);

        if ~isempty(idx)
            raw = S.(fields{idx});

            if isnumeric(raw) && isscalar(raw)
                val = raw;
                return
            end
        end
    end
end
