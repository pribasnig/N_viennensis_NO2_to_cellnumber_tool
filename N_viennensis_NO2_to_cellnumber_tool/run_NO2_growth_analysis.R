# Set working directory to the folder where this script is located
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))  # Works in RStudio
# Alternative for general R use:
# setwd("path/to/NO2_growth_curve_tool")

# Define paths
script_dir <- file.path(getwd(), "scripts")
measurements_file <- file.path(getwd(), "measurement.csv")




######### PART1


# Load and run Growth Curve Analysis
source(file.path(script_dir, "TPs_growth_curve_maker_with_cells_per_mL.R"))
run_growth_analysis(measurements_file)



#######PART 2

# Interpolate Cells/mL from NO2
source(file.path(script_dir, "NO2_to_cells.R"))

# Define the NO2 value to interpolate
input_no2_value <- 1300  # Change this to the desired NO2 value

# Run the function and store the result
result <- run_NO2_to_cells(input_no2_value)

# Display result in scientific notation if numeric
if (is.numeric(result)) {
  formatted_result <- format(result, scientific = TRUE, digits = 3)
} else {
  formatted_result <- result  # Keep "out of range" as is
}


print(paste("Interpolated cells/mL for NO2 =", input_no2_value, ":", result))
