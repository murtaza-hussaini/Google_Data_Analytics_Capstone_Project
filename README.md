# **Cyclistic Bike-Share: Case Study**

_This document is created as part of the capstone project of the Google Data Analytics Professional Certificate._

## **Introdiction and Scenario**
You are a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualizations.

### **About the Company**
In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geo-tracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

The project follows the 6 step of the data analysis process: __ask__, __prepare__, __process__, __analyze__, __share__, and __act__.

## **Step 1: Ask**
### **Guiding questions:**
* What is the problem you are trying to solve?
* How can your insights drive business decisions?

### **Key tasks:**
1. Identify the business task
2. Consider key stakeholders

### **Deliverable:**
#### **Business Task:**
The purpose of this project is to find how do annual members and casual riders use Cyclistic bikes differently? The comparison result along with other insights will later be used by marketing department team who will design a new marketing strategy to convert casual riders into annual members.

#### **Key stakeholders:**
__Primary stakeholders__: The director of marketing and Cyclistic executive team.

__Secondary stakeholders__: Cyclistic marketing analytics team.

## **Step 2: Prepare**
The data used for this project is from Cyclistic's historical data for last 12 months (June-2020 till May-2021). The data has been made available by Motivate International Inc. at this [link](https://divvy-tripdata.s3.amazonaws.com/index.html) under this [license](https://www.divvybikes.com/data-license-agreement).

The data set consist of 12 CSV files each representing a month. It has 13 columns of more than 4 million rows.

ROCCC approach is used to determine the credibility of the data.

* **R**eliable - It is complete and accurate and it represents all bike rides taken in the city of Chicago for the selected duration of our analysis.

* **O**riginal - The data is made available by Motivate International Inc. which operates the city of Chicago's Divvy bicycle share service. It is powered by Lyft.

* **C**omprehensive - The data includes all the information about ride details including starting time,ending time, from and to station names and its ids, type of customer and many more.

* **C**urrent - It is up-to-date as it includes data until May 2021 and analysis is done during June 2021.

* **C**ited - The data is cited and is available under Data License Agreement.

#### **Data Limitation**
A quick filtering and checking data for completeness shows that "start station name and id" and "end station name and id" for some rides are missing. Further observation suggest that 22% of electric-bike ride shares has missing data about "start station name".

This limitation could slightly affect our analysis for finding station where most electric-bikes are taken but we can use "end station names" to locate our customers. This will be used for further analysis and potential marketing campaigns.


## **Step 3: Process**

In this step we will be cleaning our data from possible errors or bad data, changing type of data in analyzable format, adding new columns by creating calculated fields. We will make sure data is ready for analysis.

### **Actions:**

__1. Tools:__ R Programming is used for its ability to handle huge data set efficiently. Microsoft Excel is use for further analysis and visualization.
```{r}
# Load packages in R
library(ggplot2)
library(dplyr)
library(janitor)
library(skimr)
library(tidyr)
library(lubridate)
```

__2. Organize:__ Combined all 12 CSV files into one.
```{r}
# Set working directory
setwd("***/Datasets")
# Read all csv files from directory and map a data frame
combined <- ldply(list.files(),read.csv,header=TRUE)
```

__3. Sampling:__ Due to limitation in computational power and efficiency purpose, I had to take random 10% of data which resulted in:

* Population size: 4,073,561
* Confidence level: 99.9%
* Margin of Error: 0.2
* Sample size : 407,356
```{r}
# Taking random sample
df <- sample_n(combined, 407356)
```

__4. Preparing for analysis:__ We will be applying following data wrangling and manipulation methods:

* Removed not useful columns:
```{r}
df <- df %>%
  select(-c(start_lat,start_lng,end_lat,end_lng))
```

* Changed type of columns and added new columns to be used for aggregating the data in future.
```{r}
df$started_at <- as_datetime(df$started_at)
df$ended_at <- as_datetime(df$ended_at)
df$year <- format(as.Date(df$started_at), "%Y")
df$month <- format(as.Date(df$started_at), "%m")
df$day <- format(as.Date(df$start_date), "%d")
```

* Added column "ride_length" a calculated field indicating duration of ride.
* Added column to find day of the week and organized it.
```{r}
df <- df %>%
  mutate(ride_length = difftime(ended_at, started_at, units = "mins")) %>%
  mutate(day_of_week = weekdays(as.Date(started_at)))
df$day_of_week <- ordered(df$day_of_week, levels = c("Sunday","Monday","Tuesday",
                                                     "Wednesday","Thursday","Friday",
                                                     "Saturday"))
```


__5 Check for errors:__ A quick sorting and filtering shows that in 1931 rows there is negative duration of ride(ride_length) which is logically not possible. Therefore it is considered as bad data and removed.
```{r}
df <- df %>%
  filter(ride_length > 0)
```

__6 Clean column names and checked for duplicate records in rows.__
```{r}
df <- df %>%
  clean_names() %>%
  unique()
```

__7 Exported data frame into CSV file__ For easability of analysis we can use this CSV file in MS.Excel and Tableau.
```{r}
write.csv(df, "sample_cleaned_data.csv")
```


## **Step 4: Analyze**
The entire analyze process was conducted using R Programming. Data aggregation and other analysis is available in R script.

* Click [here](https://github.com/murtaza-hussaini/Google_Data_Analytics_Capstone_Project/tree/main/02.%20Analysis) to view the R script file.


## **Step 5: Share**
Microsoft PowerPoint is used for visualizing and presenting key insights. All the graphs used in presentation are reproducible and generated using ggplot2. It is available in R script.

* Click [here](https://github.com/murtaza-hussaini/Google_Data_Analytics_Capstone_Project/tree/main/03.%20Presentation) to download the presentation.

* Click [here](https://github.com/murtaza-hussaini/Google_Data_Analytics_Capstone_Project/tree/main/02.%20Analysis) to view the R script file.


## **Step 6: Act**

After analyzing the data we found out that:

* Nearly 60% of total number of rides are taken by casual customers.

* Casual customers take longer rides, our bikes used daily:
  
  1. ~18 hours by casual customer.
  
  2. ~6 hours by members.

* casual customers use our bikes for leisure because:
  
  1. They are more active during summer holidays.
  
  2. They mostly use our bikes at the weekends.
  
  3. Their number spike up after working hour (11:19).

* Popular stations and bikes among casual customers are:

  1. Stations: Streeter Dr & Grand Ave, Lake Shore Dr, Millennium Park

  2. Bike: Docked bike.


Here are my recommendations for converting casual customers to annual members based on the above insights:

1. The marketing team can design annual packages that include cheaper rate even for longer hours of ride.

2. Another annual weekend-only package can also be designed to target weekend riders.

3. The offer should be announced in summer when we have the most number of casual customers.

4. To get the most out of our marketing campaign, we can first target our busiest stations used by causal customers.


#### **_Thank you for reading. Please put a star if you liked it._**

#### **_This is an open source project feel free to use or to contribute to it._**



