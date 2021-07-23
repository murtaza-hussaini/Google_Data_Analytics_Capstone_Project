# Step 1: Set working directory and install required packages
# Set working directory
setwd("E:\\Google Data Analytics\\Datasets")

# Load Packages for collecting data then wrangling, manipulating, analyzing and visualizing
# If you do not have the packages installed in your machine use
# install.packages("name of the package")
# After that use the following code.
library(ggplot2)
library(dplyr)
library(janitor)
library(skimr)
library(tidyr)
library(lubridate)

# Step 2: COllect Data
# Combine all 12 months data sets into one data frame
combined <- ldply(list.files(),read.csv,header=TRUE)

# Due to computational limitation, we will work on 10% of the total observations
# 10% will be taken randomly which concludes as :
# Population size : 4,073,561
# Confidence level : 99.9%
# Margin of error : 0.2
# Sample size : 407,356
df <- sample_n(combined, 407356)
colnames(df)
nrow(df)
head(df)
str(df)
summary(df)

# Step 3: CLean Data and prepare for analysis
# Remove unnecessary columns from our data frame
df <- df %>%
  select(-c(start_lat,start_lng,end_lat,end_lng))

# Change type of columns for usability
df$started_at <- as_datetime(df$started_at)
df$ended_at <- as_datetime(df$ended_at)

# Split columns of ride date for future usability
df$year <- format(as.Date(df$started_at), "%Y")
df$month <- format(as.Date(df$started_at), "%m")
df$day <- format(as.Date(df$start_date), "%d")

# Add column to calculate ride length duration
# Add column to to find day of the week
df <- df %>%
  mutate(ride_length = difftime(ended_at, started_at, units = "mins")) %>%
  mutate(day_of_week = weekdays(as.Date(started_at)))

# Arrange days of the week
df$day_of_week <- ordered(df$day_of_week, levels = c("Sunday","Monday","Tuesday",
                                                     "Wednesday","Thursday","Friday",
                                                     "Saturday"))
#  Remove rows with negative ride length (bad data)
df <- df %>%
  filter(ride_length > 0)

# CLean column names and remove duplicate rows
df <- df %>%
  clean_names() %>%
  unique()

# Export data frame to csv file for analyzing in other platforms
write.csv(df, "sample.csv")

# Optional: If you want to directly import sample data set, run the following code
df <- read.csv("sample.csv")

# Step 4: Descriptive Analysis of Data
# Compare how Member and Casual customer use bikes differently
# Units are in minutes
aggregate(df$ride_length ~ df$member_casual, FUN = mean)
aggregate(df$ride_length ~ df$member_casual, FUN = median)
aggregate(df$ride_length ~ df$member_casual, FUN = max)
aggregate(df$ride_length ~ df$member_casual, FUN = min)

# Total number of ride of shares taken by type of customer in one year
df %>%
  group_by(member_casual) %>%
  summarise(number_of_rides = n()) %>%
  arrange(member_casual)

# Average ride time during the week by type of customer
aggregate(df$ride_length ~ df$member_casual + df$day_of_week, FUN = mean)

# Total number of rides by month sorted by busiest month at the top
df %>%
  group_by(month) %>%
  summarise(number_of_rides = n()) %>%
  arrange(desc(number_of_rides))
# Average ride time in each month by type of customer
aggregate(df$ride_length ~ df$member_casual + df$month, FUN = mean)

# Step 5: Visualize the analysis
# Line chart showing number ride taken by different customer group during the week
df %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual,weekday) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_line(aes(colour = member_casual, group = member_casual)) +
  ggsave("number_of_rides_by_week_line_chart")

# Line chart showing average duration of ride by different customer group during the week
df %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual,weekday) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot(aes(x = weekday, y = average_duration)) +
  geom_line(aes(colour = member_casual, group = member_casual))+
  ggsave("avg_duration_rides_by_week_by_line_chart")

# Line chart showing total number of rides by month grouped by type of customer
df %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n()) %>%
  arrange(member_casual) %>%
  ggplot(aes(x = month, y = number_of_rides,colour = member_casual)) +
  geom_line() + scale_x_binned() +
  ggsave("number_of_rides_by_month_line_chart.png")

# Bar chart showing popularity of different type of bikes by type of customer
df %>%
  group_by(member_casual, rideable_type) %>%
  summarise(number_of_rides = n()) %>%
  arrange(member_casual, rideable_type) %>%
  ggplot(aes(x = rideable_type, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  ggsave("type_of_bike_by_customer_bar_chart")

