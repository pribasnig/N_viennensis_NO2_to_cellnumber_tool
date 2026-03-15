# NO₂ Growth Curve & Cells/mL Interpolation Tool
This tool intends to convert measured NO2 values to cell numbers for Nitrososphaeria viennesis EN76.
This tool converts **NO₂ measurements from growth experiments into estimated cell numbers (cells/mL)** using a calibrated growth curve.

## Citation

If you use this tool in your work, please cite the following paper:
Pribasnig et al. 2026 - coming soon to biorxiv.

It can be used to:

1. **Generate a growth curve** from NO₂ measurements and estimate cell numbers for each time point.
2. **Convert a single NO₂ value** into the corresponding estimated cell density.

---

# Required Input

The script requires a measurement file named:

```
measurement.csv
```

An example file is included.

Your file **must contain the following columns in this order**:

```
hours,NO2,NO2_sd,replicate
```

Example:

```
hours,NO2,NO2_sd,replicate
0,12,1,NV1
12,255,20,NV1
24,600,30,NV1
```

Column description:

| Column      | Description                               |
| ----------- | ----------------------------------------- |
| `hours`     | Time point of the measurement             |
| `NO2`       | Nitrite concentration (µM)                |
| `NO2_sd`    | Standard deviation of the NO₂ measurement |
| `replicate` | Replicate identifier                      |

---

# Valid NO₂ Range

The calibration curve used in this tool is valid for NO₂ values between:

```
4 – 1809 µM
```

Values outside this range will be reported as **"out of range"**.

The growth curve plot will still display NO₂ values outside this range on the **primary axis**, but cell numbers will not be calculated.

---

# Repository Structure

```
NO2_growth_curve_tool/
│
├── run_NO2_growth_analysis.R
├── measurement.csv
├── README.md
│
└── scripts/
    ├── TPs_growth_curve_maker_with_cells_per_mL.R
    ├── NO2_to_cells.R
    └── standard_AM.csv
```

---

# How to Use

### Step 1 — Open the project

Open **R or RStudio** and navigate to the project folder.

### Step 2 — Run the main script

Run:

```
run_NO2_growth_analysis.R
```

This script controls the whole workflow.

---

# Part 1 – Generate Growth Curve

This step:

* interpolates **cells/mL** from NO₂ values
* generates a **growth curve plot**
* writes a results file

Output file:

```
calculated_cells_per_mL.csv
```

This file contains your original measurements plus the calculated cell numbers.

---

# Part 2 – Convert a Single NO₂ Value

In the main script you can define a NO₂ value:

```
input_no2_value <- 1141.252
```

Running the script will return:

```
Interpolated cells/mL for NO2 = 1141.252 : 2.3e+07
```

---

# How the Interpolation Works

The script is based on a **calibrated growth experiment** where both:

* NO₂ production
* cell numbers (FACS counts)

were measured over time.

Two growth curves are therefore available:

1. **NO₂ vs time**
2. **cells/mL vs time**

For a given NO₂ value the script:

1. **Interpolates the corresponding time point** on the NO₂ growth curve.
2. **Interpolates the cell number** at that time point using the cell growth curve.

This two-step interpolation accounts for small deviations between the NO₂ and cell growth curves.

---

# Notes on the Growth Curve Plot

* The **primary y-axis** shows NO₂ concentration.
* The **secondary y-axis** shows estimated cell numbers.
* Standard deviation bars apply only to the **NO₂ measurements**.

Because the secondary axis is derived from interpolation, it should be interpreted as an **approximate reference scale**.

---

# Contact

If you have questions about the script or the calibration curve, feel free to contact:

Thomas Pribasnig
[thomas.pribasnig@univie.ac.at](mailto:thomas.pribasnig@univie.ac.at)
