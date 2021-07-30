/*

COVID-19 Data Exploration

*/

-- checking if data sets imported correctly
select *
from portfolio..coviddeaths
order by 3,4

select *
from portfolio..covidvaccinations
order by 3,4

-- showing the amount of tests given out at each country
select location, sum(cast(new_tests as int)) as tests_given
from portfolio..covidvaccinations
where continent is not null
group by location
order by tests_given desc

-- showing the rate of getting covid by each country
select location, population, MAX(total_cases) as HighestCovidCases,
	MAX((total_cases/population))*100 as CovidRate
from portfolio..coviddeaths
group by location, population
order by location, population

-- looking at the highest death counts by each country
select location, MAX(cast (total_deaths as int)) as HighestDeathCount
from portfolio..coviddeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- looking at the rate of the population that got at least one vaccination shot in each continent
select dea.continent, 
	(MAX(cast(vac.people_vaccinated as float))/MAX(dea.population))*100 as VacRate
from portfolio..coviddeaths dea
join portfolio..covidvaccinations vac
	on  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent
order by VacRate desc

-- looking at the amount of fully vaccinated people out of all the vaccinations by continent
select *, (a.TotalFullVacCount/a.TotalVacCount) as FullyVacRate
from (select continent, MAX(cast(total_vaccinations as float)) as TotalVacCount,
	MAX(cast(people_fully_vaccinated as float)) as TotalFullVacCount
	from portfolio..covidvaccinations
	where continent is not null
	Group by continent) a
order by FullyVacRate desc

-- looking at the rolling death count by day in each location
select continent, location, date, population, new_cases, sum(new_cases) over (partition by location order by location, date) as RollingCasesCount,
	new_deaths, sum(cast(new_deaths as int)) over (partition by location order by location, date) as RollingDeathCount
from portfolio..coviddeaths
where continent is not null
order by location, date

-- using a CTE to see the Percentage of Deaths from the total cases by each day at each location and date
with RateOfDeath (continent, location, date, population, new_cases, RollingCasesCount, new_deaths, RollingDeathCount) as
(
select continent, location, date, population, new_cases, sum(new_cases) over (partition by location order by location, date) as RollingCasesCount,
	new_deaths, sum(cast(new_deaths as int)) over (partition by location order by location, date) as RollingDeathCount
from portfolio..coviddeaths
where continent is not null
)

select *, (RollingDeathCount/RollingCasesCount)*100 as RollingDeathRate
from RateOfDeath
;
