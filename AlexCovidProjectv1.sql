SELECT * FROM PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$ ORDER BY 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Taiwan%'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 AS ContractPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%Taiwan%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, population
ORDER BY 4 desc

-- Showing the Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--LET"S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL TOTAL

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Covid Vaccinations

--Looking at Total Population vs. Vaccination
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaxPercentage
FROM PopvsVac
--USE CTE


--Temp Table

--Use the following command if you need to make any quick updates to temp table

--DROP Table if exists #PercentPopulationVaccinated
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
SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaxPercentage
FROM #PercentPopulationVaccinated



-- Creating View to Store Data For Later Visualizations

