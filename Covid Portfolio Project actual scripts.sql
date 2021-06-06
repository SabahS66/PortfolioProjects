SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4
 
--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

Select location, date, population, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United Kingdom
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%kingdom%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentge of population has got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
where location like '%kingdom%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, MAX((Total_Cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with the High Death count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where Continent is not null
group by Location
order by TotalDeathCount  desc

-- Filter by Continent
Select Continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
where Continent is not null
group by Continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where Location like '%kingdom%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualisation

Create View PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated