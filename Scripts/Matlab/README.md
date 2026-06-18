# Data extraction and ETL engineering pipeline (MATLAB)

This directory contains Useful data engineering scripts that were used alongside `Trace_y`
to add to the data pipeline. These scripts act as quality-of-life improvements over standard `Trace_y` 
functions and assist them by improving data retrieval from public scientific archives (EMDB), standardising 3D 
coordinate space positioning and automation, and aggregation of raw structural numeric features into a 
unified matrix for the downstream Python machine learning workflow [H-D-Wilson]. 

It's important to note that these Functions are to be used alongside the MATLAB program `Trace_y` 
and are not a substitute for it

If you lack this program, you can find it here: [wfxue/Trace_y] (https://github.com/wfxue/Trace_y)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Outputs:

 These functions are to be used in tandem with `Trace_y`; together, they can retrieve data more consistently and
 inspect and correct it when it's incorrect. Standardises `Trace_y` pipeline processing and can convert many
 multi-modal biological data structures produced by `Trace_y` into a clean, relative schema ready for modelling [H-D-Wilson].

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Core Functions

This folder contains 3 Functions:

1. `ImportEMDBv2.m` (Data Ingestion & API Integration)
 • Improved over legacy "Trace_y" function `ImportEMDB` architecture, which is based on antiquated FTP connections. This function uses a more modern asynchronous HTTP API layout ("webread"/"websave").
 • This script can also deal with server timeouts and detect/corrects Incorrect values. For example, it can swap helical parameters such as twist/rise directly within the JSON metadata stream.

2. `AlignToZAxis.m` (Data Pre-processing & Standardisation)
• This function removes the need for manual positioning within the `CalcHelicalAxisEM` function by centring and orienting 3D density maps automatically before fibril axis alignment.
• This is performed by the script by using terminal endpoint coordinate averaging paired with a "Rodrigues' rotation matrix"  based transformation, which forces the fibril to be rigidly aligned with the Z-axis.
  
3. `combineHelicalData.m` (Automated ETL & Feature Engineering).
• This function searches nested directories to find workspace variables (".mat") and parses polymorphic nomenclature across different fibril structures.
• The script then extracts specific helical features from these objects and their associated values, it also calculates "Roundness_Index" by dividing h_min by h_max, and then flattens the datasets into one combined dataset (.csv), serving as an Input for Scripts apart of the Python side of the workflow







  ( )
 /   \
 | | |
  | |




 
   
