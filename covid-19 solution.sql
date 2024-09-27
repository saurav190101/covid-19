select * from covid_death
select * from covid_vaccination
--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,  Converting Data Types


-- Q1 total case vs total death.
SELECT location ,date,total_cases as total_case,
total_deaths  as total_death ,(cast(total_deaths as float)/(cast(total_cases as float)))*100 as percentage 
from covid_death
where location LIKE 'India'
order by 3,4 ;  


--Q2. Shows what percentage of population infected with Covid.
-- shows percentage of india populatiio got covid.
 select location,date,population, total_cases ,(cast(total_cases as float)  / population ) *100
 as prtng_population_infected
 from covid_death
 where location LIKE 'India'
 order by 1,3


--Q3.Countries with Highest Infection Rate compared to Population.

select location ,max(total_cases),population  ,
(max(total_cases)/Cast(population as float)) *100 as percnt_infected_population
from covid_death
     where location = 'India'
    group by location,population
    order by percnt_infected_population 


--Q4. Countries with Highest Death Count per Population

select location,population  ,
max(total_deaths)as higest_death_count
from covid_death
group by 1,2

-- Showing Death Count by Continent.

with table1 as(
select location,continent,max(total_deaths) as total_death_count
from covid_death
where continent is not null
group by 1,2
order by total_death_count desc
)

select continent   ,sum(total_death_count) as total_death_count
from table1
group by continent
order by total_death_count desc;


--Q5 Total Cases, Death, and Death Percentage by Date.

SELECT date,
    SUM(new_cases) AS total_cases,
    SUM(total_deaths) AS total_deaths,
	case 
	when sum(new_cases)> 0 then
    (CAST(SUM(total_deaths) AS FLOAT) / SUM(new_cases)) * 100 else 0 
	end AS death_rate_percentage
FROM covid_death
group by date;




--Q6 Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine.



select  covid_death.location,covid_death.continent,covid_death.population,covid_death.date,
covid_vaccination.new_vaccinations ,

sum(covid_vaccination.new_vaccinations) over (partition by covid_death.location order by  covid_death.date ) as
PeopleVaccinated,

sum(covid_vaccination.new_vaccinations) over (partition by covid_death.location order by  covid_death.date )/

(covid_death.population)*100 as  vacinated_people_prcntg


from covid_death join covid_vaccination
on covid_death.location=covid_vaccination.location

             where covid_death.continent is not null
              order by covid_death.date,covid_death.location

			  


-- Q7 Using Temp Table to perform Calculation on Partition By in previous query.


create table vacinated_people_percentage(
location varchar (255),
continent varchar(255),
population bigint ,
date Date,
new_vaccination float,
peoplevaccinated float,
 vacinated_people_prcntg float);

 insert into  vacinated_people_percentage
 select  covid_death.location,covid_death.continent,covid_death.population,covid_death.date,
covid_vaccination.new_vaccinations ,

sum(covid_vaccination.new_vaccinations) over (partition by covid_death.location order by  covid_death.date ) as
PeopleVaccinated,

sum(covid_vaccination.new_vaccinations) over (partition by covid_death.location order by  covid_death.date )
/(covid_death.population)*100 as  vacinated_people_prcntg

from covid_death join covid_vaccination
on covid_death.location=covid_vaccination.location

             where covid_death.continent is not null
              order by covid_death.date,covid_death.location

--change data type 
alter table vacinated_people_percentage alter column location type varchar(225),
alter column continent type varchar(225);


select * from vacinated_people_percentage




 
 