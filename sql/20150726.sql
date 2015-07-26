create or replace view view_studiesbymodality as 
select 
  extract(year from st.studydate::date) as "Year",
  extract(month from st.studydate::date) as "Month",
  sum(case when st.modality='CR' then 1 else 0 end) as "CR",
  sum(case when st.modality='CT' then 1 else 0 end) as "CT",
  sum(case when st.modality='MR' then 1 else 0 end) as "MR",
  sum(case when st.modality='US' then 1 else 0 end) as "US",
  count(*) as "Total"  
  from study st  
  where 
    st.modality is not null and 
    st.studydate >= now() - '12 months'::interval
  group by 1, 2
  order by 1, 2, 3;

create view view_globalByModality as
with total as (
  select round(count(*), 2) as count from study
  where
    modality is not null and 
    studydate >= now() - '12 months'::interval
)
select
  st.modality,
  round(100.0 * count(*)/total.count)
from study st, total
where
  st.modality is not null and 
  st.studydate >= now() - '12 months'::interval
group by 1, total.count;

create view view_totalByMonth as
select
  extract(year from st.studydate) as "Year",
  extract(month from st.studydate) as "Month",
  count(*)
from study st
where
  st.studydate >= now() - '12 months'::interval
group by 1, 2
order by 1, 2;
