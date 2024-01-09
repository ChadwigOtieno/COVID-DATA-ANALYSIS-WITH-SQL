
SELECT *
FROM [Portfolio Project]..CovidDeaths$


--SELECT *
--FROM [Portfolio Project]..[CovidVaccinations$]

--select data that I am going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2


-- looking at total cases vs total deaths
-- shows the likely of dying if you contract Covid in Kenya

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%Kenya%'
ORDER BY 1,2

-- looking at the total cases vs the population
-- shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS pctpopinfected
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%Kenya%'
ORDER BY 1,2

--Looking at Countries with highest infection rate

SELECT Location, population, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS pctpopinfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%Kenya%'
GROUP BY Location, Population
ORDER BY pctpopinfected DESC

--Showing Countries with highest Death Count per population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%Kenya%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Understanding insights globally
-- Showing the continets with the highest death counts

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location LIKE '%Kenya%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Percentage of Deaths in continents

SELECT continent, date, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
ORDER BY DeathPercentage desc


-- joining our vaccination and deaths tables
-- looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS incrementalPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, incrementalPeopleVaccinated)
AS 
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS incrementalPeopleVaccinated
    FROM
        [Portfolio Project]..CovidDeaths$ dea
    JOIN
        [Portfolio Project]..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL)

SELECT *, (incrementalPeopleVaccinated/Population)*100 AS pctvaccinated
FROM PopVsVac




--Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar (255),
Lication nvarchar (255),
Sate datetime,
Population numeric,
new_vaccinations numeric,
incrementalPeopleVaccinated numeric
)


INSERT INTO PercentPopulationVaccinated
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS incrementalPeopleVaccinated
    FROM
        [Portfolio Project]..CovidDeaths$ dea
    JOIN
        [Portfolio Project]..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    --WHERE dea.continent IS NOT NULL

SELECT *, (incrementalPeopleVaccinated/Population)*100 AS pctvaccinated
FROM PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVacci AS
WITH PopVsVac (continent, location, date, population, new_vaccinations, incrementalPeopleVaccinated)
AS 
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS incrementalPeopleVaccinated
    FROM
        [Portfolio Project]..CovidDeaths$ dea
    JOIN
        [Portfolio Project]..CovidVaccinations$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT * FROM PopVsVac;



SELECT *
FROM PercentPopulationVacci
