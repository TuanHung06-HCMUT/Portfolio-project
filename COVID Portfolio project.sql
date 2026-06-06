SELECT *
From project..CovidDeaths
where continent is not null
Order by 3,4

SELECT *
From project..CovidVaccinations
where continent is not null
Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From project..CovidDeaths
where continent is not null
Order by 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From project..CovidDeaths
Where location like '%Viet%' and continent is not null
Order by 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From project..CovidDeaths
Where location like '%Viet%' and continent is not null
Order by 1,2

SELECT location, MAX(total_cases) as HighestInnfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From project..CovidDeaths
where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break thing down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From project..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global number
SELECT  SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) *100 as DeathPercentage
From project..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE vac.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE vac.continent is not null
--order by 2,3
)

SELECT * , (RollingPeopleVaccinated / population) *100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE vac.continent is not null
--order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE vac.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated


