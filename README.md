# Traffic Accident Pattern Analysis

## Task Overview:
This task focuses on analyzing large-scale traffic accident data to identify patterns related to time of day, weather conditions, road infrastructure, and traffic control mechanisms. The objective is to uncover factors that influence both accident frequency and accident severity, and to visualize geographic and contextual hotspots.

## Dataset:
The analysis uses a representative sample (500,000 records) from the US Accidents Dataset to enable efficient exploratory analysis of large-scale traffic data.
Link: https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents

Key Columns Used: Severity, Start_Time, Start_Lat, Start_Lng, Weather_Condition, Visibility(mi), Traffic_Signal, Junction, Station, Turning_Loop, Sunrise_Sunset

## Objective

1. Identify time-based patterns in accident frequency

2. Analyze the relationship between environmental conditions and accident severity

3. Evaluate the impact of road infrastructure and traffic control on accident outcomes

4. Visualize geographic accident hotspots and contributing factors


## Tools & Technologies
* Python
* Pandas
* Matplotlib, Seaborn
* Folium (for hotspot mapping)
* Git & GitHub
* Mysql, SQL
* MS Excel

## Key Analyses Performed:
#### Time-Based Analysis
- Accident frequency by hour of day to identify peak traffic risk periods
- Day vs night comparison using Sunrise_Sunset

#### Severity & Risk Analysis
- Average severity comparison for locations with and without traffic signals
- High-severity accident proportion (Severity ≥ 3) by infrastructure type
- Risk feature index based on the presence of complex road elements (junctions, stations, turning loops)

#### Environmental Factors
- Severity distribution by visibility levels and weather conditions
- Combined analysis of lighting conditions and accident impact

#### Spatial Analysis
- Geographic heatmap to visualize accident hotspots across regions

## Key Insights:


## Repository Structure:
PRODIGY_DS_05/
├── data/
│   └── US_Accidents_500k.csv
├── notebook/
│   └── task5_accident_analysis.ipynb
├── images/
│   ├── time_of_day_distribution.png
│   ├── severity_by_traffic_signal.png
│   ├── severity_features.png
│   └── accident_hotspots.html
└── README.md

## Conclusion

This analysis demonstrates how traffic accident risk is shaped by both human activity patterns (time of day and traffic volume) and environmental and infrastructure factors (lighting, visibility, and traffic control). The findings highlight the importance of targeted traffic regulation and infrastructure planning to reduce high-severity incidents.