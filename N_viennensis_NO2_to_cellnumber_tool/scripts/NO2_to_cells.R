# Load necessary library
library(dplyr)

# Function to get cells/mL for a single NO2 value
get_cells_from_NO2 <- function(input_no2, standards_file = "./scripts/standard_AM.csv") {
  
  # Load standard data
  standards <- read.csv(standards_file)
  
  # Rename columns for consistency
  colnames(standards) <- c("hours", "NO2", "cells_mL")
  
  # Sort standards data by NO2 for consistent interpolation
  standards <- standards %>% arrange(NO2)
  
  # Find the two surrounding NO2 values
  lower <- standards %>% filter(NO2 <= input_no2) %>% slice_tail(n = 1)
  upper <- standards %>% filter(NO2 > input_no2) %>% slice_head(n = 1)
  
  # Handle out-of-range values
  if (nrow(lower) == 0 || nrow(upper) == 0) {
    return("out of range")
  }
  
  # Linear interpolation for hours
  interpolated_hours <- lower$hours + 
    (input_no2 - lower$NO2) / (upper$NO2 - lower$NO2) * (upper$hours - lower$hours)
  
  # Linear interpolation for cells/mL
  interpolated_cells <- lower$cells_mL + 
    (interpolated_hours - lower$hours) / (upper$hours - lower$hours) * (upper$cells_mL - lower$cells_mL)
  
  return(interpolated_cells)
}

# Function to run the script from another R script
run_NO2_to_cells <- function(input_no2) {
  
  # Convert input to numeric
  input_no2 <- as.numeric(input_no2)
  
  # Handle non-numeric input
  if (is.na(input_no2)) {
    stop("Error: NO2 value must be a numeric input.")
  }
  
  # Get the corresponding cells/mL
  result <- get_cells_from_NO2(input_no2)
  
  # Return the result
  return(result)
}