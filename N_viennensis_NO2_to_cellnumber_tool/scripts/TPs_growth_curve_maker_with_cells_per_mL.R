# Load necessary libraries
library(ggplot2)
library(dplyr)
library(scales)

# Function to perform NO2-cell interpolation and generate a growth curve
run_growth_analysis <- function(measurements_file, output_file = "calculated_cells_per_mL.csv") {
  
  # Define standard file path (fixed)
  standards_file <- "./scripts/standard_AM.csv"  # Change this if the location is different
  # Load data
  standards <- read.csv(standards_file)
  measurements <- read.csv(measurements_file)
  
  # Check if standard deviation column exists, otherwise create NA column

  
  # Rename columns for consistency
  colnames(standards) <- c("hours", "NO2", "cells_mL")
  colnames(measurements)[1:4] <- c("hours", "NO2", "NO2_sd", "replicate")  # Ensure first three columns are correctly assigned
  
  # Sort standards data by NO2 for consistent interpolation
  standards <- standards %>% arrange(NO2)
  
  # Interpolate cells/mL for each replicate separately
  interpolate_cells <- function(standards, measurements) {
    measurements <- measurements %>% mutate(cells_mL = NA)
    
    for (rep in unique(measurements$replicate)) {
      subset_measurements <- measurements %>% filter(replicate == rep)
      
      for (i in 1:nrow(subset_measurements)) {
        input_no2 <- subset_measurements$NO2[i]
        
        lower <- standards %>% filter(NO2 <= input_no2) %>% slice_tail(n = 1)
        upper <- standards %>% filter(NO2 > input_no2) %>% slice_head(n = 1)
        
        if (nrow(lower) == 0 || nrow(upper) == 0) {
          measurements$cells_mL[measurements$replicate == rep & measurements$NO2 == input_no2] <- "out of range"
          next
        }
        
        interpolated_hours <- lower$hours + 
          (input_no2 - lower$NO2) / (upper$NO2 - lower$NO2) * (upper$hours - lower$hours)
        
        interpolated_cells <- lower$cells_mL + 
          (interpolated_hours - lower$hours) / (upper$hours - lower$hours) * (upper$cells_mL - lower$cells_mL)
        
        measurements$cells_mL[measurements$replicate == rep & measurements$NO2 == input_no2] <- interpolated_cells
      }
    }
    
    return(measurements)
  }
  
  # Perform interpolation
  result <- interpolate_cells(standards, measurements)
  
  # Convert "out of range" values to NA for plotting

  result$cells_mL[is.na(result$cells_mL)] <- "out of range"
  
  
  # Save the result
  write.csv(result, output_file, row.names = FALSE)
  
  result$cells_mL <- as.numeric(result$cells_mL)
  
  
  format_sci_2dp <- function(x) {
    parse(text = sprintf("%.2f%%*%%10^%d", x / 10^(floor(log10(x))), floor(log10(x))))
  }
  
  min_no2 <- min(result$NO2, na.rm = TRUE)
  max_no2_valid <- max(result$NO2[!is.na(result$cells_mL)], na.rm = TRUE)  # Only consider valid NO₂ values
  
  min_cells <- min(result$cells_mL, na.rm = TRUE)
  max_cells <- min(max(result$cells_mL, na.rm = TRUE), 26479014)  # Cap secondary y-axis at 26479014
  
  
  # Define custom breaks for secondary y-axis (ensuring they stay below max_cells_scaled)
  secondary_y_breaks <- c(min_cells, seq(1e7, max_cells, by = 1e7), max_cells)
  
  # Generate the growth curve plot
  p <- ggplot(result, aes(x = hours, color = factor(replicate), group = replicate)) +
    
    # NO2 values as a single line per replicate
    geom_line(aes(y = NO2), size = 1) +
    geom_point(aes(y = NO2), size = 2) +
    
    # Error bars for NO2 (if NO2_sd is provided)
    geom_errorbar(aes(ymin = NO2 - NO2_sd, ymax = NO2 + NO2_sd), 
                  width = 0.2, na.rm = TRUE) +
    
    # Define the y-axes: primary for NO2, secondary for Cells/mL (capped at max valid value)
    scale_y_continuous(
      name = "NO2 (µM)", 
      sec.axis = sec_axis(
        trans = ~ ( . - min_no2 ) / (max_no2_valid - min_no2) * max_cells,
        name = "Cells/mL",
        breaks = secondary_y_breaks[secondary_y_breaks <= max_cells],  # Only allow valid breaks
        labels = format_sci_2dp
      )
    ) +
    
    # Labels and theme
    labs(
      x = "Time (hours)", 
      color = "Replicate",
      title = ""
    ) +
    theme_minimal() +
    theme(
      panel.grid.major = element_line(color = "grey85", size = 0.5),  
      panel.grid.minor = element_line(color = "grey85", size = 0.3),
      panel.background = element_rect(fill = "white", color = NA),  
      legend.position = "right"
    )
  
  # Print the plot
  print(p)
}
