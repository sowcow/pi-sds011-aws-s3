library(stats)

# Load the data from CSV file
data <- read.csv("local_data/all.csv", header = FALSE)

# Assign column names
colnames(data) <- c("timestamp", "PM2.5", "PM10")

# Convert timestamp to date-time format
data$datetime <- as.POSIXct(data$timestamp, origin = "1970-01-01", tz = "UTC")

# Extract date part from datetime
data$date <- as.Date(data$datetime)


# Open a PNG device
png("PM_levels.png", width = 16000, height = 900)

plot(data$datetime, data$PM2.5, type = "l", col = "blue",
     main = "PM2.5 and PM10 Levels Over Time",
     xlab = "Time",
     ylab = "Concentration (µg/m³)")

# Add PM10 to the plot
lines(data$datetime, data$PM10, col = "red")

# Customize x-axis ticks for hourly intervals
axis.POSIXct(1, at = seq(min(data$datetime), max(data$datetime), by = "hour"), format = "%H:%M")

# Replicate left y-axis ticks and labels on the right
axis(side = 4)

# Add a legend
legend("topright", legend = c("PM2.5", "PM10"), col = c("blue", "red"), lty = 1)

# Close the PNG device
dev.off()



# Open a PDF device
pdf("PM_levels_by_day.pdf", width = 8, height = 6)

# Loop through each unique date
unique_dates <- unique(data$date)
for (current_date in unique_dates) {
  # Subset data for the current date
  daily_data <- subset(data, date == current_date)
  
  # Plot PM2.5 for the current date
  plot(daily_data$datetime, daily_data$PM2.5, type = "l", col = "blue",
       main = paste("PM2.5 Levels on", current_date),
       xlab = "Time",
       ylab = "PM2.5 (µg/m³)")
  
  # Plot PM10 for the current date
  plot(daily_data$datetime, daily_data$PM10, type = "l", col = "red",
       main = paste("PM10 Levels on", current_date),
       xlab = "Time",
       ylab = "PM10 (µg/m³)")
}

# Close the PDF device
dev.off()
