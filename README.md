# Source Time Function (STF) Inversion

This repository contains MATLAB scripts for extracting Source Time Functions (STF) from natural earthquakes using the Multitaper Spectral and Empirical Green's Function (eGF) deconvolution method.

## Overview

The methodology is based on the empirical Green's Function approach proposed by Hartzell (1978), which utilizes a smaller aftershock as an empirical Green's Function for a larger earthquake with similar hypocenter locations and focal mechanisms. By deconvolving the waveform data of the small earthquake from the larger one, the source information of the target earthquake can be resolved.

**Mathematical Representation:**
```
u = STF * eGF
```
where:
- `u`: Displacement waveform of the target (large) earthquake
- `STF`: Source Time Function of the target earthquake
- `eGF`: Displacement waveform of the empirical Green's Function (small) earthquake

## Prerequisites

- MATLAB R2022a or later
- Parallel Computing Toolbox (optional, for parallel processing)
- SAC format seismic data files

## Workflow

The processing workflow consists of three main stages:

### Stage 1: STF Extraction (`for_1_4.m`)

This script performs the core deconvolution procedure to extract STFs from earthquake pairs.

**Key Steps:**
1. Load target earthquake and eGF earthquake waveform data
2. Preprocess data (filtering, detrending, tapering)
3. Extract P-wave and/or S-wave windows
4. Perform cross-correlation to align waveforms
5. Apply multitaper deconvolution to compute STF
6. Generate diagnostic figures showing:
   - Target and eGF displacement waveforms
   - Extracted P-wave windows and spectra
   - Computed STF and spectrum
   - Predicted seismograms and variance reduction

**Output:**
- Individual STF files (`*_STF.txt`)
- Spectral files (`*_spec.txt`, `*_spectmp.txt`)
- Waveform windows (`*_tarPwin.txt`, `*_fitPwin.txt`)
- Diagnostic figures (`.png` files)

**Configuration Parameters:**
- `Pwavelen`: P-wave window length (default: 8s)
- `Swavelen`: S-wave window length (default: 16s)
- `kspec`: Number of spectral windows for multitaper method (default: 7)
- `tbp`: Time-bandwidth product (default: (kspec+1)/2)
- `xorr_threshold`: Cross-correlation threshold for quality control (default: 0.6)
- `Wavemode`: Wave type selection ('P', 'S', 'W', or 'PS')

### Stage 2: Result Organization (`part2_3.m`)

This script organizes results by target earthquake, copying STF files and associated data from event pairs into target-specific directories.

**Key Steps:**
1. Read result directories from Stage 1
2. Group results by target earthquake number
3. Copy STF, spectra, and figure files to target-specific folders
4. Apply station filtering (if needed)

**Output:**
- Organized results in target-specific directories

### Stage 3: Stacking and Visualization (`part5.m`)

This script stacks STFs and spectra from multiple stations for each target earthquake, performs quality control, and generates comprehensive summary figures.

**Key Steps:**
1. Load all STF and spectra files for each target earthquake
2. Normalize and align individual STFs
3. Compute median/mean STF and spectra across stations
4. Remove outliers using statistical criteria (±σ threshold)
5. Perform grid search to fit theoretical source spectra
6. Calculate source parameters (Mw, corner frequency, stress drop)
7. Generate comprehensive visualization including:
   - Station-event map
   - Individual and stacked STFs
   - Individual and stacked spectra with theoretical fit
   - Observed vs. predicted waveforms

**Output:**
- Summary figures for each target earthquake
- Stacked STF files (`*_STF.mat`)
- Stacked spectra files (`*_spec.mat`, `*_bestspec.mat`)
- Source parameters (`*_source_para.mat`)

**Estimated Source Parameters:**
- Moment magnitude (Mw)
- Corner frequency (fc)
- High-frequency falloff rate (η)
- Stress drop (Δσ)
- L2 norm of spectral fit

## Directory Structure

```
STF Inversion/
├── for_1_4.m              # Main processing script (Stage 1)
├── part2_3.m              # Result organization (Stage 2)
├── part5.m                # Stacking and visualization (Stage 3)
├── Multitaper/            # Multitaper spectral analysis functions
│   ├── mt_deconv.m        # Multitaper deconvolution
│   ├── mtspec.m           # Multitaper spectrum estimation
│   ├── MTtaper_spline.m   # Multitaper with spline interpolation
│   └── MTtaper_logspline.m
├── Others/                # Utility functions
│   ├── bp_STD.m           # Bandpass filter parameter estimation
│   ├── Grid_search.m      # Grid search for source parameters
│   ├── Er_est.m           # Radiated energy estimation
│   ├── CutBiasNd.m        # Outlier removal
│   ├── final_plot.m       # Plotting utilities
│   ├── patch_plot.m
│   ├── startMatlabPool.m  # Parallel processing setup
│   └── closeMatlabPool.m
├── PLD/                   # Projected Landweber Deconvolution
│   ├── pld.m
│   └── posproj.m
├── Pre process/           # Data preprocessing functions
│   ├── Pre_process.m      # Main preprocessing wrapper
│   ├── filtering.m        # Bandpass filtering
│   └── taper.m           # Tapering function
└── SAC Related/           # SAC file I/O functions
    ├── load_sac.m         # Load SAC files
    ├── rsac.m, rsac_big.m # Read SAC data
    ├── wsac.m             # Write SAC files
    ├── lh.m, ch.m         # Read/change SAC headers
    ├── rotate_NE2RT.m     # Coordinate rotation
    └── SNR.m              # Signal-to-noise ratio calculation
```

## Usage

### Basic Workflow

1. **Prepare input data:**
   - Organize SAC files by event directories
   - Create an Excel file with event pairs (target and eGF earthquake pairs)
   - Ensure event metadata (location, magnitude, focal mechanism)

2. **Configure paths in `for_1_4.m`:**
   ```matlab
   addpath(genpath('path/to/STF/src/'))
   eventlist = correct_list('path/to/event/directories/');
   resultfd = 'path/to/results/';
   EGFpairs = readtable('path/to/pairs.xlsx','sheet','SheetName');
   ```

3. **Run Stage 1 - STF Extraction:**
   ```matlab
   run for_1_4.m
   ```

4. **Run Stage 2 - Result Organization:**
   ```matlab
   run part2_3.m
   ```

5. **Run Stage 3 - Stacking and Analysis:**
   ```matlab
   run part5.m
   ```

## Key Features

- **Automatic waveform alignment:** Cross-correlation-based alignment of target and eGF waveforms
- **Adaptive filtering:** Automatic bandpass filter adjustment based on earthquake magnitude
- **Quality control:** Cross-correlation threshold and variance reduction filtering
- **Parallel processing:** Optional parallel processing for large datasets
- **Comprehensive visualization:** Automated generation of diagnostic figures
- **Source parameter estimation:** Grid search optimization for spectral fitting

## Notes

1. The program is designed for events with magnitude 1 < M < 3
2. P and S wave separation requires sufficient epicentral distance (typically > 10°), though this may be challenging for small events with low SNR at large distances
3. Results with variance reduction (VR) > 60% are saved as valid outputs
4. The code automatically handles both byte orders for SAC files


## Author

**Tao Mo**  
Earth and Space Sciences, SUSTech  
Contact: casertao1996@gmail.com

## Version History

- v1.0 (2022.10.12): Auto-recognize component pairs for rotation
- v1.1 (2022.10.18): Added P & S wave separation option
- v1.2 (2022.10.25): Auto-save plot figures
- v1.3 (2022.11.05): Auto-search minimum STF value
- v1.4 (2022.11.11): Downsample and trim SAC files
- v2.0 (2022.11.25): Batch processing with pre-generated eGF pairs
- v2.1 (2022.11.30): Auto-adapt to different SAC byte orders
- v2.2 (2023.03.22): Figure resize and restructure
- v2.3 (2023.05.18): Auto-adjust filter range by magnitude
- v3.1 (2023.09.11): Rewrite modules as functions with parallel processing

## License

This code is provided for academic research purposes. No need to cite.
