function [mapfv, map_x, map_y, map_z, map_v] = ImportEMDBv2(entry);
% ImportEMDBv2 - Robustly retrieves and processes EMDB structural entries.
% Modifies legacy Trace_y function by migrating from FTP protocols to API-driven
% HTTP workflows (websave/webread), improving stability and preventing execution hangs.
%
% Input:  entry - EMDB numerical identifier (string/char)

mapfv = [];
map_x = [];
map_y = [];
map_z = [];
map_v = [];

entry = string(entry);

% -------- SETTINGS --------
apply_preprocessing = false;   % OFF by default
preprocess_entries = ["23686","23687","23688","23689"];

% -------- Set folder (Optimised with Portable Relative Path) --------
% Create directory structure relative to the project working directory
emdbEntryPath = fullfile(pwd, 'data', 'emdb', "EMD_" + entry);

if ~isfolder(emdbEntryPath)
    mkdir(emdbEntryPath);
end

fprintf("\nRetrieving EMD-%s\n", entry);

% -------- Get metadata --------
url = "https://www.ebi.ac.uk/emdb/api/entry/" + entry;

options = weboptions( ...
    'HeaderFields', {'Accept','application/json'}, ...
    'Timeout', 20);

metaData = webread(url, options);

fprintf('%s\n', metaData.admin.title);
disp("STEP 2: Metadata retrieved");

% -------- OPTIONAL FIX: twist/rise correction --------
% Apply ONLY to known problematic entries
problem_entries = ["23686","23687","23688","23689"];

if any(entry == problem_entries)
    fprintf("Checking helical parameters for EMD-%s\n", entry);

    try
        hp = metaData.structure_determination_list ...
            .structure_determination.helical_parameters;

        twist_val = hp.twist;
        rise_val  = hp.rise;

        % Detect likely swapped values
        if abs(twist_val) < 1 && rise_val > 10
            fprintf("Correcting swapped twist/rise values\n");

            temp = twist_val;
            hp.twist = rise_val;
            hp.rise  = temp;

            metaData.structure_determination_list ...
                .structure_determination.helical_parameters = hp;
        end
    catch
        warning("Could not inspect helical parameters");
    end
end

% -------- Save XML --------
try
    websave( ...
        fullfile(emdbEntryPath, "emd_" + entry + ".xml"), ...
        url, ...
        weboptions('HeaderFields', {'Accept','text/xml'}, 'Timeout', 20));
catch
    warning("Failed to save XML (non-critical)");
end

% -------- Map file paths --------
remoteFile = "emd_" + entry + ".map.gz";
localFile  = fullfile(emdbEntryPath, remoteFile);

remoteURL = ...
    "https://ftp.ebi.ac.uk/pub/databases/emdb/structures/EMD-" ...
    + entry + "/map/" + remoteFile;

% -------- Download map --------
if ~isfile(localFile)
    fprintf("Downloading %s...\n", remoteFile);
    websave(localFile, remoteURL);
    disp("STEP 3: Map downloaded");
else
    fprintf("Using existing file: %s\n", localFile);
end

% -------- Decompress --------
mapPath = gunzip(localFile, emdbEntryPath);
mapFile = mapPath{1};

disp("STEP 4: Map decompressed");

% -------- Get contour level --------
if isfield(metaData, 'map') && ...
   isfield(metaData.map, 'contour_list') && ...
   isfield(metaData.map.contour_list, 'contour') && ...
   isfield(metaData.map.contour_list.contour, 'level')

    contourLevel = metaData.map.contour_list.contour.level;
else
    contourLevel = 0;
    warning("No contour level found — using 0");
end

fprintf("Using contour level: %.4f\n", contourLevel);

% -------- Load original map --------
[mapfv, map_x, map_y, map_z, map_v] = ...
    ImportMRC(contourLevel, mapFile, 1);

disp("STEP 5: Original map loaded");

% -------- Attach metadata --------
if ~isfield(mapfv, 'UserData') || isempty(mapfv.UserData)
    mapfv.UserData = struct();
end

mapfv.UserData.metaDataEMDB = metaData;

fprintf("Metadata attached to mapfv.UserData\n");

end

