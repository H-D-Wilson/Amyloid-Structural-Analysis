## Unsupervised Machine Learning Pipeline (Python)

This is the Python pipeline. It precedes the Trace_y part of the workflow; it consists of scripts related to 
unsupervised machine learning, as well as a statistical comparison script. This part of the pipeline has 3 inputs: 
the raw 3D density maps of the fibrils, the master data set made in MATLAB, as the final output of the Trace_y 
pipeline and the Cryo-EM cross sections of the fibrils. Each one of these inputs then had two corresponding forms of 
dimensionality reduction and clustering associated with it, to map amyloid polymorphism across several 
different data types; these were then statistically compared to one another.
-----------------------------------------------------------------------------------------------------------------------------------

## Outputs:

The outputs consisted of 3 different dimensionality reduction scatter graphs and 3 agglomerative 
clustering dendrograms. These were then compared with the ARI table, which measured how much these outputs 
differed from one another.
-----------------------------------------------------------------------------------------------------------------------------------

## Pipeline Scripts:

### 1. 2D **Fibril Cross-Section Images** (Morphological Variance)
* **` PCA_Images.py` = This script reduces high-dimensional image matrices into lower-dimensional eigenvectors.
* **` Clustering_Images.py` = The script applies agglomerative clustering with an average linkage model to image data to identify morphological groups.

### 2. **Helical Parameters** (Numeric data)
* **`PCA_Helical.py` = This PCA script evaluates the linear coordinates and feature variances between fibrils.
* **`Clustering_Helical.py` = Clusters fibrils based on specified geometric constraints identified in the master dataset.

### 3. **Raw Density Maps** (High-Dimensional Structural Profiles)
* **`UMAP_Density.py` =  The UMAP script non-linear geometric shapes of high dimensionality onto a low dimensionality manifold while also still preserving local neighbourhood structures.
* **`Clustering_EMD.py` = Using an Earth Mover's Distance cost matrix, it clusters transport-resolved fibril density maps.
-----------------------------------------------------------------------------------------------------------------------------------

## Cross-Model Validation:

**`Validation_ARI.py`** =  The script validates the different analyses using an **Adjusted Rand Index (ARI)**  to mathematically measure the agreement between the distinct data analyses to see if they reach the same conclusions or differ.
-----------------------------------------------------------------------------------------------------------------------------------

## Python libraries:


* **Machine Learning & Stats:** `scikit-learn`, `umap-learn`, `SciPy`, `POT (Python Optimal Transport)`
* **Image Processing & Deep Learning:** `torch`, `scikit-image (Skimage)`, `PIL`, `h5py`
* **Data Core & Utilities:** `NumPy`, `pandas`, `networkx`, `tqdm`, `os`, `time`, `re`
* **Visualization:** `matplotlib`



```text
/||||\
( )( )
 /_ 
 \_/
```









