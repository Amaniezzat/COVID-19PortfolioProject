/* 

Protfolio Project #1: Covid 19 Data Exploration 

*/

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent IS NOT Null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


-- Select data that ae going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent IS NOT Null
ORDER BY 1, 2



-- Lokking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Egypt'
AND continent IS NOT Null
ORDER BY 1, 2



-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationAffectedPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS NOT Null
ORDER BY 1, 2



-- Looking at Countries with Highest Infection rate compared to Population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationAffectedPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS NOT Null
GROUP BY location, population
ORDER BY PopulationAffectedPercentage DESC



-- Showing Countries with Highest Death Count per Population 

SELECT location, population, MAX(Cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS NOT Null
GROUP BY location, population
ORDER BY HighestDeathCount DESC



-- Let's break things down by continent 

SELECT continent, MAX(Cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS NOT Null
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Creating View for Highest Death Count per Population data

CREATE VIEW HighestDeathCount AS
SELECT continent, MAX(Cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS NOT Null
GROUP BY continent
--ORDER BY HighestDeathCount DESC


-- For purposes of hierarchy 

SELECT location, MAX(Cast(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Italy'
Where continent IS Null
GROUP BY location
ORDER BY HighestDeathCount DESC



-- Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Egypt'
WHERE continent IS NOT Null
--GROUP BY date
ORDER BY 1, 2


-- Creating View for Global Numbers data

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE 'Egypt'
WHERE continent IS NOT Null
--GROUP BY date


-- Looking at Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) As RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3 



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM PopvsVac



-- Creating View for Total Population vs Total Vaccinations data for later visualizations

CREATE VIEW PercentagePeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 