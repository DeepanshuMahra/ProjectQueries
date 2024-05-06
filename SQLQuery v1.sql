select * from 
['covid-19 deaths]

select * from ['covid-vaccination]

select location,date,population,total_cases,total_deaths,new_cases
from ['covid-19 deaths]
order by 1,2

--looking at total cases and total deaths

SELECT 
    (sum(total_deaths)/sum(total_cases))*100 AS death_percentage
FROM 
    ['covid-19 deaths]
order by death_percentage desc
	
	alter table ['covid-19 deaths]
	alter column total_deaths int


	SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN total_cases = 0 THEN 0  -- Avoid division by zero
        ELSE (CAST(ISNULL(total_deaths, 0) AS bigint) / CAST(total_cases AS bigint)) * 100
    END AS death_percentage
FROM 
    ['covid-19 deaths]
order by death_percentage desc


select location,date,total_cases,total_deaths,([total_deaths]/[total_cases])*100 as DeathPercentage
from Project..['covid-19 deaths]
where location like '%states%'
order by 1,2 desc


select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from Project..['covid-19 deaths]
where location like '%states%'
order by 1,2 


select location,population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 as PercentagePopulationInfected
from ['covid-19 deaths]
group by location,population
order by PercentagePopulationInfected desc

select* from ['covid-19 deaths]

select sum([total_cases]) as TotalCase ,sum(cast([total_deaths] as int)) as TotalDeaths
from ['covid-19 deaths]
where location like '%India%'

--showing countries with highest deathcount
select location,max(cast(total_deaths as int)) as maxdeaths
from ['covid-19 deaths]
where continent is null
group by location
order by maxdeaths desc


--showing continent with highest death count

select continent,count(cast(total_deaths as int)) as TOtalDeathCount
from ['covid-19 deaths]
where continent is not null
group by continent
order by TOtalDeathCount desc



select continent,total_cases,total_deaths,(count(cast(total_deaths as int))/(total_cases)) *100 as TOtalDeathPercentage
from ['covid-19 deaths]
group by continent,total_cases,total_deaths
order by TOtalDeathPercentage

select date,sum(cast(new_deaths as int)) as total_deaths,sum(new_cases)as Total_cases,(SUM(cast(new_deaths as int ))/sum(new_cases)*100 )as deathPercentage
from Project..['covid-19 deaths]
where continent is not null
group by date
order by 1,2

select SUM(cast(new_deaths as int )) as TotalDeath
from Project..['covid-19 deaths]

select SUM(new_cases) as TotalCases
from Project..['covid-19 deaths]
where new_cases is not null;


SELECT 
    date,
    count(CAST(ISNULL(new_deaths, 0) AS int)) AS total_deaths,
    count(new_cases) AS total_cases,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0 -- Avoid division by zero
        ELSE (SUM(CAST(ISNULL(new_deaths, 0) AS int)) / SUM(new_cases)) * 100
    END AS deathPercentage
FROM 
    Project..['covid-19 deaths]
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1,2;

select date,SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project..['covid-19 deaths]
where new_deaths != 0 and continent is not null
group by date
order by 1,2

UPDATE ['covid-19 deaths]
SET new_cases = 3
WHERE new_cases = 1;

UPDATE ['covid-19 deaths]
SET new_deaths = 1
WHERE new_deaths = 3;


select new_cases from 
Project..['covid-19 deaths];

select * from
Project..['covid-vaccination]

select *
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date


select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date
order by 2,3


select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cv.location order by cv.location,cd.date) as  SumTotalVaccsination 
--(RollingPeopleVaccinated/population)*100
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date
where cv.new_vaccinations != 0 and cd.continent is not null
group by cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations
order by 2,3


select sum(convert(bigint,new_vaccinations))
from ['covid-vaccination]

--using cte
with popvsvsc(Continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cv.location order by cv.location,cd.date) as  SumTotalVaccsination 
--(RollingPeopleVaccinated/population)*100
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date
where cv.new_vaccinations != 0 and cd.continent is not null
group by cd.continent,
cv.location,cd.date,cd.population,cv.new_vaccinations
--order by 2,3
)
select * from popvsvsc


--Temp table

drop table if exists #PercentagePopulationVaccinated
create table  #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVAccinated numeric
)

insert into #PercentagePopulationVaccinated 
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cv.location order by cv.location,cd.date) as  SumTotalVaccsination 
--(RollingPeopleVaccinated/population)*100
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date
where cv.new_vaccinations != 0 and cd.continent is not null
group by cd.continent,
cv.location,cd.date,cd.population,cv.new_vaccinations
--order by 2,3


--create view
create view PercentagePopulationVaccinated  as
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cv.location order by cv.location,cd.date) as  SumTotalVaccsination 
--(RollingPeopleVaccinated/population)*100
from ['covid-19 deaths] cd
join ['covid-vaccination] cv
on cd.location= cv.location
and cd.date = cv.date
where cv.new_vaccinations != 0 and cd.continent is not null
group by cd.continent,
cv.location,cd.date,cd.population,cv.new_vaccinations

