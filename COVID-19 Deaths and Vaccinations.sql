SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL AND location LIKE '%canada%'
ORDER BY 1,2

-- Looking at the total cases vs population
-- Shows waht percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as total_case_percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
WHERE location LIKE '%kingdom%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percent_population_infected
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 DESC

-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as highest_death_count, MAX(cast(total_deaths as int)/population)*100 as percent_population_died
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as highest_death_count, MAX(cast(total_deaths as int)/population)*100 as percent_population_died
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Global Numbers
SELECT date, SUM(new_cases) as daily_new_cases_total, SUM(cast(new_deaths as int)) as daily_new_deaths_total, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as daily_death_percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases and total deaths in the world until 2022/03/21
SELECT SUM(new_cases) as daily_new_cases_total, SUM(cast(new_deaths as int)) as daily_new_deaths_total, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as daily_death_percentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Same purpose but some how in this way there are more total cases and more total deaths??
SELECT location, MAX(total_cases), MAX(cast(total_deaths as int))
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE 'world'
GROUP BY location 
ORDER BY 1,2

-- Looking at total population vs vaccinations
-- JOINING TABLES
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2,3

-- USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2,3
)
SELECT *, (rolling_people_vaccinated / population)*100 AS percent_total_people_vaccinated
FROM pop_vs_vac
WHERE location LIKE '%states%'
ORDER BY 1,2,3


-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2,3
SELECT *, (rolling_people_vaccinated / population)*100 AS percent_total_people_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS -- A new table title, different from the temp table one
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2,3

SELECT *
FROM PercentPopulationVaccinated
