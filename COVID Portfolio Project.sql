SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks3
ORDER BY 
	1,2




--Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country
SELECT 
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks3
WHERE 
	location like '%states%'
ORDER BY 
	1,2




--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT 
	Location, date, population, total_cases, (total_cases/population)*100 AS PercentageWithCovid
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks5
--WHERE 
--	location like '%states%'
ORDER BY 
	1,2




--Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageWithCovid
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks5
--WHERE 
--	location like '%states%'
GROUP BY
	Location, population
ORDER BY 
	PercentageWithCovid DESC




-- Showing Countries with Highest Death Count Per Population
SELECT 
	Location, MAX(total_deaths) AS TotalDeathCount
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks5
--WHERE 
--	location like '%states%'
WHERE continent is not null
GROUP BY
	Location
ORDER BY 
	TotalDeathCount DESC




--LETS BREAK THINGS DOWN BY CONTINENT
SELECT 
	continent, MAX(total_deaths) AS TotalDeathCount
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks5
--WHERE 
--	location like '%states%'
WHERE continent is not null
GROUP BY
	continent
ORDER BY 
	TotalDeathCount DESC




-- Showing continents with the highest death count per population
SELECT 
	continent, MAX(total_deaths) AS TotalDeathCount
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks5
--WHERE 
--	location like '%states%'
WHERE continent is not null
GROUP BY
	continent
ORDER BY 
	TotalDeathCount DESC




-- Global Numbers
SELECT 
	date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks7
WHERE
	continent is not null
GROUP BY
	date
ORDER BY
	1,2



-- Looking at Total Population vs Vaccinations
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks7 dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY
	2,3




	--USE CTE

	WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	AS
	(
	SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks7 dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY
--	2,3
)
SELECT
	*, (RollingPeopleVaccinated/population)*100
FROM PopVsVac



-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks7 dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY
--	2,3

SELECT
	*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeathsNoBlanks7 dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY
--	2,3

SELECT *
FROM PercentPopulationVaccinated