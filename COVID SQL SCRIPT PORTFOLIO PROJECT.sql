select * from PortfolioProject..MyCovidDeaths
where continent is not NULL
ORDER by 3,4

-- select * from MyCovidVacination
-- ORDER by 3,4

-- Select de data we are going to be using --
SELECT location, date, total_cases, new_cases, total_deaths, population
from MyCovidDeaths
where continent is not NULL
ORDER by 1,2
 

 -- Loking at Total Cases vs Total Deaths
-- shows the likelihood of dying if you contrat Covid in your conutry

 SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from MyCovidDeaths
where location like '%Italy%'
and continent is not NULL
ORDER by 1,2

-- Looking at the Total Cases vs the Population
--Shows what percentage of the population got Covid
SELECT location, date, population, total_cases,  (total_cases/population) *100 as PopulationInfectionPercentage
from MyCovidDeaths
where location like '%Italy%'
and continent is not NULL
ORDER by 1,2

--Looking at Countries with Highest Infection Rate compare to Population
SELECT location,population, max(total_cases)as HighestInfectionCount,  max((total_cases/population)) *100 as PopulationInfectionPercentage
from MyCovidDeaths
-- where location like '%Italy%'
GROUP BY location,population
ORDER by PopulationInfectionPercentage DESC


-- Showing Countries with Highest DeathCount per Population
SELECT location, max(total_deaths)as TotalDeathCount
from MyCovidDeaths
where continent is not NULL
GROUP BY location
ORDER by TotalDeathCount DESC


CREATE VIEW DeathCountPerCountry 
AS
SELECT location, 
        max(total_deaths) as TotalDeathCount
from MyCovidDeaths
where continent is not NULL
GROUP BY location
--ORDER by TotalDeathCount DESC
GO

select * from DeathCountPerCountry

-- LET'S BREAK IT DOWN BY CONTINENT

-- Select the data we are going to be using per continent --
SELECT continent, date, total_cases, new_cases, total_deaths, population
from MyCovidDeaths
where continent is not NULL
ORDER by 1,2

--Shows what percentage of the population got Covid
SELECT continent, date, population, total_cases,  (total_cases/population) *100 as PopulationInfectionPercentage
from MyCovidDeaths
-- where location like '%Italy%'
where continent is not NULL
ORDER by 1,2


--Looking at Continent with Highest Infection Rate compare to Population
SELECT continent,population, max(total_cases)as HighestInfectionCount,  max((total_cases/population))*100 as PopulationInfectionPercentage
from MyCovidDeaths
-- where location like '%Italy%'
where continent is not NULL
GROUP BY continent,population
ORDER by PopulationInfectionPercentage DESC


SELECT location, max(total_deaths)as TotalDeathCount
from MyCovidDeaths
where continent is NULL
GROUP BY location
ORDER by TotalDeathCount DESC


--Showing the Contitents with the Highest DeathCount per Population

SELECT continent, max(total_deaths)as TotalDeathCount
from MyCovidDeaths
where continent is not NULL
GROUP BY continent
ORDER by TotalDeathCount DESC



--- GLOBAL NUMBERS

 SELECT sum(new_cases) as TotalCases,  sum(new_deaths) as TotalDeaths, sum(cast(new_deaths as FLOAT))/sum(new_cases)*100 as DeathPercentage
from MyCovidDeaths
where continent is not NULL
-- GROUP BY date
ORDER by 1,2



---Looking at Population vs Vaccination
select * 
from MyCovidDeaths dea
    join MyCovidVacination vac
        on dea.location = vac.location


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.date) --as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/dea.population) * 100
from MyCovidDeaths dea
    join MyCovidVacination vac
        on dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not NULL
ORDER by 2,3


--- USE CTE
with PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)

as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) * 100
from MyCovidDeaths dea
    join MyCovidVacination vac
        on dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not NULL
--ORDER by 2,3
)

select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac

---TEMP TABLE
Drop TABLE if EXISTS  #PercentpeopleVaccinated

CREATE TABLE #PercentpeopleVaccinated
(
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    Date date,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC

)

insert into #PercentpeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) * 100
from MyCovidDeaths dea
    join MyCovidVacination vac
        on dea.location = vac.location
        and dea.date = vac.date
--where dea.continent is not NULL
--ORDER by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #PercentpeopleVaccinated

--- Creation a view to store data for later visualization


CREATE VIEW PercentpeopleVaccinated AS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population) * 100
from MyCovidDeaths dea
    join MyCovidVacination vac
        on dea.location = vac.location
        and dea.date = vac.date
where dea.continent is not NULL
--ORDER by 2,3

select * from PercentpeopleVaccinated