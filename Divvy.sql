Select *
From C##MISM6210.DIVVY
Where rownum < 50;

-- Review of first cut of records
Select to_char(STARTED_AT, 'yyyy-mm-dd')
From C##MISM6210.DIVVY
Where rownum < 50;

Select count(*)
From C##MISM6210.DIVVY;

-- Summary of ride type and member
Select RIDEABLE_TYPE, MEMBER_CASUAL, count(*) count
From C##MISM6210.DIVVY
Group By RIDEABLE_TYPE, MEMBER_CASUAL
Order By count desc;

-- Start station summary
Select START_STATION_NAME, count(*) count
From C##MISM6210.DIVVY
Where START_STATION_NAME is not Null
Group By START_STATION_NAME
Order By count desc;

-- End station summary
Select END_STATION_NAME, count(*) count
From C##MISM6210.DIVVY
Where END_STATION_NAME is not Null
Group By END_STATION_NAME
Order By count desc;

-- Combined summary
Select Case When st.START_STATION_NAME is Null Then ed.END_STATION_NAME Else st.START_STATION_NAME End station_name, st.start_count, ed.end_count, (st.start_count - ed.end_count) net_diff, abs(st.start_count - ed.end_count) abs_diff,
  Case When st.start_count - ed.end_count = 0 Then 'Net Even' When st.start_count - ed.end_count > 0 Then 'Net Start' Else 'Net End' End match_category
From
  (Select START_STATION_NAME, count(*) start_count
  From C##MISM6210.DIVVY
  Where START_STATION_NAME is not Null
  Group By START_STATION_NAME) st
  Inner Join
  (Select END_STATION_NAME, count(*) end_count
  From C##MISM6210.DIVVY
  Where END_STATION_NAME is not Null
  Group By END_STATION_NAME) ed
  On 
  st.START_STATION_NAME = ed.END_STATION_NAME
Order By abs_diff desc;

-- Daily Combined summary of bike movements
Select Case When st.ride_date is Null Then ed.ride_date Else st.ride_date End ride_date,
  Case When st.START_STATION_NAME is Null Then ed.END_STATION_NAME Else st.START_STATION_NAME End station_name,
  nvl(st.start_count,0) start_count, nvl(ed.end_count,0) end_count, (nvl(st.start_count,0) - nvl(ed.end_count,0)) net_diff,
  abs(nvl(st.start_count,0) - nvl(ed.end_count,0)) abs_diff,
  Case When nvl(st.start_count,0) - nvl(ed.end_count,0) = 0 Then 'N/A' When nvl(st.start_count,0) - nvl(ed.end_count,0) > 0 Then 'Net Start' Else 'Net End' End match_category
From
  (Select to_char(STARTED_AT, 'yyyy-mm-dd') ride_date, START_STATION_NAME, count(*) start_count
  From C##MISM6210.DIVVY
  Where START_STATION_NAME is not Null
  Group By to_char(STARTED_AT, 'yyyy-mm-dd'), START_STATION_NAME) st
  Full Outer Join
  (Select to_char(STARTED_AT, 'yyyy-mm-dd') ride_date, END_STATION_NAME, count(*) end_count
  From C##MISM6210.DIVVY
  Where END_STATION_NAME is not Null
  Group By to_char(STARTED_AT, 'yyyy-mm-dd'), END_STATION_NAME) ed
  On 
  st.START_STATION_NAME = ed.END_STATION_NAME
    and st.ride_date = ed.ride_date
Order By abs_diff desc;

-- Daily ride summary by member type
Select MEMBER_CASUAL,
  to_char(STARTED_AT, 'yyyy-mm-dd') ride_date,
  sum(cast(ENDED_AT as date) - cast(STARTED_AT as date))*24*60*60 total_ride_time,
  avg(cast(ENDED_AT as date) - cast(STARTED_AT as date))*24*60*60 avg_ride_time,
  count(*) ride_count
From C##MISM6210.DIVVY
Group by MEMBER_CASUAL,
  to_char(STARTED_AT, 'yyyy-mm-dd');

-- Ride summary by station combination
Select MEMBER_CASUAL,
  START_STATION_NAME,
  END_STATION_NAME,
  sum(cast(ENDED_AT as date) - cast(STARTED_AT as date))*24*60 total_ride_time,
  avg(cast(ENDED_AT as date) - cast(STARTED_AT as date))*24*60 avg_ride_time,
  count(*) ride_count
From C##MISM6210.DIVVY
Group by MEMBER_CASUAL,
  START_STATION_NAME,
  END_STATION_NAME;

-- Station locations
  Select START_STATION_NAME station,
    min(START_LAT) min_lat,
    max(START_LAT) max_lat,
    min(START_LNG) min_lng,
    max(START_LNG) max_lng
  From C##MISM6210.DIVVY
  Where START_STATION_NAME is not Null
  Group by START_STATION_NAME
Union All
  Select END_STATION_NAME station,
    min(END_LAT) min_lat,
    max(END_LAT) max_lat,
    min(END_LNG) min_lng,
    max(END_LNG) max_lng
  From C##MISM6210.DIVVY
  Where END_STATION_NAME is not Null
  Group by END_STATION_NAME;
  
