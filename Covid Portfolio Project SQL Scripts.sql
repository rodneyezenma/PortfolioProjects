SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths]

SELECT date, CONVERT(date, date)
FROM [PortfolioProject].[dbo].[CovidDeaths]


--Looking at total cases vs total deaths 

SELECT location, ConvertedDate, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM [PortfolioProject].[dbo].[CovidDeaths]
where location = 'Nigeria'

--Looking at total cases vs total population. Shows the prevalence (in %) of covid-19

SELECT location, ConvertedDate, population, total_cases, ROUND((total_cases/population)*100, 2) AS percentage_of_population
FROM [PortfolioProject].[dbo].[CovidDeaths]
--where location = 'Nigeria' or continent = 'Africa'
--ORDER BY 1, 2

--Looking at countres with the highest incidence/cases per population
SELECT location, population, MAX(total_cases) AS total_infection, ROUND(MAX((total_cases/population))*100, 2) AS percentage_total_of_infection
FROM [PortfolioProject].[dbo].[CovidDeaths]
GROUP BY location, population
ORDER BY percentage_total_of_infection desc

--Showing the total number of deaths per population
SELECT location, MAX (CAST(total_deaths AS int)) AS death_count
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location, population
ORDER BY death_count desc

--Breaking down by continent

SELECT continent, MAX (CAST(total_deaths AS int)) AS death_count_by_continent
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY death_count_by_continent desc

--Global numbers; Gobal total cases, deaths, and death rate

SELECT SUM(new_cases) AS global_total_cases, SUM(CAST(new_deaths as int)) AS global_total_deaths, ROUND((SUM(CAST(new_deaths as int))/SUM(new_cases))*100, 2) AS death_rate
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
--GROUP BY ConvertedDate
ORDER BY 1,2 

--Global total cases by date

SELECT ConvertedDate, SUM(new_cases) AS global_total_cases, SUM(CAST(new_deaths as int)) AS global_total_deaths, ROUND((SUM(CAST(new_deaths as int))/SUM(new_cases))*100, 2) AS death_rate
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
GROUP BY ConvertedDate
ORDER BY 1,2 

--Looking at percentage population vs vaccination

SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_total_vaccinations
--,MAX((rolling_total_vaccinations)/cd.population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null and cd.location = 'Albania'
ORDER BY 2,3


--Using a CTE to calculate the percentage of the population that have been vaccinated

WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as 
(
SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_total_vaccinations
--,MAX((rolling_total_vaccinations)/cd.population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null and cd.location = 'Albania'
--ORDER BY 2,3
)
SELECT *, (rolling_total_vaccinations/population)*100 AS vaccination_rate
FROM PopVsVac


--Using a TEMP Table to calculate the percentage of the population that have been vaccinated

DROP TABLE IF EXISTS #population_vaccination_rate
CREATE TABLE #population_vaccination_rate
(continent nvarchar(255),
location nvarchar(255),
date date,
population numeric, 
new_vaccinations numeric,
rolling_total_vaccinations numeric
)

insert into #population_vaccination_rate
SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_total_vaccinations
--,MAX((rolling_total_vaccinations)/cd.population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null and cd.location = 'Albania'
--ORDER BY 2,3

SELECT *, (rolling_total_vaccinations/population)*100 AS vaccination_rate
FROM #population_vaccination_rate


--Creating View for later visualization

CREATE VIEW percent_population_vaccinated as
SELECT cd.continent, cd.location, cd.ConvertedDate, cd.population, cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location order by cd.location, cd.date) as rolling_total_vaccinations
--,MAX((rolling_total_vaccinations)/cd.population)*100
FROM PortfolioProject..CovidDeaths AS cd
JOIN PortfolioProject..CovidVaccinations AS cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null and cd.location = 'Albania'
--ORDER BY 2,3