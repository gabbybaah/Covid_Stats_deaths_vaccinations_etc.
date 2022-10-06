select * 
from Covid.dbo.CovidDeaths
where continent is not null
order by 3,4

select * 
from Covid.dbo.CovidDeaths
where continent is not null
order by 3,4



-- Selecting data to be used 

select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from Covid.dbo.CovidDeaths
where continent is not null
order by 1,2


-- Finding total cases against total deaths (percentage dead)
-- Probability of dieing from covid19 by location

select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
from Covid.dbo.CovidDeaths
where location like '%Ghana%' AND continent is not null
order by 1,2


-- Total Cases against Population
-- Percentage of people infected

select 
	location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 as Infection_rate
from Covid.dbo.CovidDeaths
where location like '%Ghana%' AND continent is not null
order by 1,2


-- Countries with highest Infection rate in relation to population

select 
	location, 
	max(total_cases) as Peak_numbers, 
	population, 
	max((total_cases/population))*100 as highest_Infection_rate
from Covid.dbo.CovidDeaths
-- where location like '%Ghana%'
where continent is not null
group by location, population
order by highest_Infection_rate desc


-- Countries with Highest Death counts per-population

select 
	location, 
	max(cast(total_deaths as int)) as Total_death_count, 
	population
from Covid.dbo.CovidDeaths
-- where location like '%Ghana%'
where continent is not null
group by location, population
order by Total_death_count desc


-- deaths numbers by continents

select 
	location, 
	max(cast(total_deaths as int)) as Total_death_count
from Covid.dbo.CovidDeaths
-- where location like '%Ghana%'
where location != 'World' AND location != 'International' AND continent is null
group by location
order by Total_death_count desc


-- Global stats for each day of the year feb 2020 - april 2021

select
	date, 
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_rate
from Covid.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--Joining Vacinations Data to Covid Data

select *
from Covid.dbo.CovidDeaths dea
join Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date



-- Total population against vaccinations

select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by 
	dea.location Order by dea.location, dea.Date) as Cummulative_vaccinations
	---or (convert(int, vac.new_vaccinations))
from Covid.dbo.CovidDeaths dea
join Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


--- Creating a CTE for % of Population Vaccinated

with PopVac (Continent, location, date, population, new_vaccinations, Cummulative_vaccinations)
as
(
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by 
	dea.location Order by dea.location, dea.Date) as Cummulative_vaccinations
	---or (convert(int, vac.new_vaccinations))
from Covid.dbo.CovidDeaths dea
join Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
)
select *, (Cummulative_vaccinations/population) *100
from PopVac


---- Putting Data into Temp table

Create Table #Percentage_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Cummulative_vaccinations numeric
)

Insert into #Percentage_Vaccinated
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by 
	dea.location Order by dea.location, dea.Date) as Cummulative_vaccinations
	---or (convert(int, vac.new_vaccinations))
from Covid.dbo.CovidDeaths dea
join Covid.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null

select *, (Cummulative_vaccinations/population) *100
from #Percentage_Vaccinated
