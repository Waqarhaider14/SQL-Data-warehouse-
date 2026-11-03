create table src.drought(
Disaster_Event_Id text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
Country_Location text,
From_Date date,
To_Date date,
Severity integer,
Source_System text,
Iso3 text,
Event_Type text,
GDACS_ID text,
Duration_Days text,
Impact_level text,
Drought_Type text,
Effected_Area_Km2 integer
);

create table src.earthquake(
Disaster_Event_Id text,
Country_Location text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
From_Date date,
To_Date date,
Severity decimal,
Source_System text,
Iso3 text,
Event_Type text,
Earthquake_Magnitude text,
depth_Km text,
Population_Effected Integer,
Impact_Category text
);

create table src.flood(
Disaster_Event_Id text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
Country_Location text,
From_Date date,
To_Date date,
Severity integer,
Source_System text,
Iso3 text,
Event_Type text,
Death Integer,
Displaced Integer,
GDACS_ID text
);

create table src.wild_fire(
Disaster_Event_Id text,
Country_Location text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
From_Date date,
To_Date date,
Severity decimal,
Source_System text,
Iso3 text,
Event_Type text,
GDACS_ID text,
Population_Effected Integer,
Duration_Days integer,
Burned_Area text
);

create table src.volcano_eruption(
Disaster_Event_Id text,
Country_Location text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
From_Date date,
To_Date date,
Severity decimal,
Source_System text,
Iso3 text,
Event_Type text,
GDACS_ID text,
Volcano_Name text,
Volcano_Number text,
Volcano_Explosivity_Index text,
Population_Exposure_Index text,
Population_Effected integer
);

create table src.tropical_cyclone(
Disaster_Event_Id text,
Alert_Level text,
Alert_Score integer,
Episode_Alert_Level text,
Episode_Alert_Score decimal,
From_Date date,
To_Date date,
Severity decimal,
Source_System text,
Iso3 text,
Event_Type text,
GDACS_ID text,
Cyclone_Name text,
Country_Location text,
Exposed_Population text,
Maximum_Wind_Speed text,
Category text,
Vulnerability text
)