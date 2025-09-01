
-- Select the Data

Select *
From [master]..CovidDeaths
Where continent is not null 
	order by 3,4


Select *
From "master"..CovidVaccination
Where continent is not null
	order by 3,4
 

Select Location, date, total_cases, new_cases, total_deaths, population
From "master"..CovidDeaths
Where continent is not null
	order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as "Death%"
From "master"..CovidDeaths
Where continent is not null
	order by 1,2

-- Total Cases vs Population 

Select Location, date, total_cases, population, (total_cases/population)*100 as "Population%"
From "master"..CovidDeaths
Where continent is not null
	order by 1,2 

-- Countries with highest infection rate

Select Location, population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as "MAXInfectionRate%"
From "master"..CovidDeaths
Where continent is not null
Group by Location, population
	order by "MAXInfectionRate%" desc


-- Countries & continents with highest death rate

Select Location, population, MAX( cast(total_deaths as int)) as HighestDeathsCount,  MAX(total_deaths/population)*100 as "MAXDeathRate%"
From "master"..CovidDeaths
Where continent is not null
Group by Location, population
	order by HighestDeathsCount desc

	
Select location, MAX( cast(total_deaths as int)) as HighestDeathsCount
From "master"..CovidDeaths
Where continent is null
Group by location 
	order by HighestDeathsCount desc 

-- Global numbers  

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DethPercentage
From "master"..CovidDeaths
Where continent is not null
	order by 1,2

-- total cases = 150574977, total deths = 3180206, deth% = 2,11%

-- Total Population vs Vacciantions 

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, SUM_new_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER(partition by dea.location Order by dea.location, dea.date) as SUM_new_vaccinations
From "master"..CovidVaccination vac
Join "master"..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (SUM_new_vaccinations/Population)*100 as "Vaccination in %"
From PopvsVac

order by 1,2,3  

-- Create view for visualization  

Create View PercentPopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER(partition by dea.location Order by dea.location, dea.date) as SUM_new_vaccinations
	From "master"..CovidVaccination vac
	Join "master"..CovidDeaths dea
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

Select *
From PercentPopulationVaccinated 