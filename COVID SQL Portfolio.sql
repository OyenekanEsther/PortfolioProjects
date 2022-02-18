Select * 
From PortfolioProject..coviddeaths$
Where continent is not null
ORDER BY 3,4


--Select * 
--From PortfolioProject..CovidVacinations$
--ORDER BY 3,4


Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths$
Where continent is not null
ORDER BY 1,2

--Calculating Total cases vs Total Deaths
--Chances of dying if someone in Nigeria contract Covid-19

Select Location,date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..coviddeaths$
Where location like '%nigeria%'
and continent is not null
ORDER BY 1,2


--Total cases vs population
--What percentage of the population got covid?

Select Location,date, total_cases, population, (total_cases/population)*100 as Death_Percentage
From PortfolioProject..coviddeaths$
Where location like '%nigeria%'
and continent is not null
ORDER BY 1,2


--Countries with highest infection rate compared to population


Select Location,population,  MAX(total_cases) as HighestInfectionCount , MAX((total_deaths/total_cases))*100 as PercentPopulationInfected
From PortfolioProject..coviddeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by location, population
ORDER BY PercentPopulationInfected desc


--Countries with highest death count per population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..coviddeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc


--By Continent

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..coviddeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc


--Continents with highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..coviddeaths$
--Where location like '%nigeria%'
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc


-- Global Numbers

Select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100
 as Death_Percentage
From PortfolioProject..coviddeaths$
Where continent is not null
ORDER BY 1,2

--Total population vs vaccinations
--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..CovidVacinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
 --  ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..CovidVacinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
 --  Where dea.continent is not null
 --  ORDER BY 2,3

 Select *,(RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated


--View to store data for visualization

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..CovidVacinations$ vac
   ON dea.location = vac.location
   and dea.date = vac.date
  Where dea.continent is not null
 --  ORDER BY 2,3

 select *
 From PercentPopulationVaccinated

 Create view GlobalNumbers as
 Select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100
 as Death_Percentage
From PortfolioProject..coviddeaths$
Where continent is not null
--ORDER BY 1,2

select*
From GlobalNumbers
