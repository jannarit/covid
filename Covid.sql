/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views
*/

-- Creating Tables covid_deaths & covid_vaccinations

USE PortfolioProject;

DROP TABLE IF EXISTS covid_deaths;

CREATE TABLE covid_deaths (
    iso_code VARCHAR(20) NOT NULL,
    continent VARCHAR(50) NULL,
    location VARCHAR(50) NOT NULL,
    date DATE NULL,
    population BIGINT NULL,
    total_cases INT NULL,
    new_cases INT NULL,
    new_cases_smoothed DECIMAL(15,3) NULL,
    total_deaths INT NULL,
    new_deaths INT NULL,
    new_deaths_smoothed DECIMAL(15,3) NULL,
    total_cases_per_million DECIMAL(15,3) NULL,
    new_cases_per_million DECIMAL(15,3) NULL,
    new_cases_smoothed_per_million DECIMAL(15,3) NULL,
    total_deaths_per_million DECIMAL(15,3) NULL,
    new_deaths_per_million DECIMAL(15,3) NULL,
    new_deaths_smoothed_per_million DECIMAL(15,3) NULL,
    reproduction_rate DECIMAL(15,3) NULL,
    icu_patients INT NULL,
    icu_patients_per_million DECIMAL(15,3) NULL,
    hosp_patients INT NULL,
    hosp_patients_per_million DECIMAL(15,3) NULL,
    weekly_icu_admissions DECIMAL(15,3) NULL,
    weekly_icu_admissions_per_million DECIMAL(15,3) NULL,
    weekly_hosp_admissions DECIMAL(15,3) NULL,
    weekly_hosp_admissions_per_million DECIMAL(15,3) NULL
);


DROP TABLE IF EXISTS covid_vaccinations;

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR(20) NOT NULL,
    continent VARCHAR(50) NULL,
    location VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    new_tests INT NULL,
    total_tests INT NULL,
    total_tests_per_thousand DECIMAL(15,3) NULL,
    new_tests_per_thousand DECIMAL(15,3) NULL,
    new_tests_smoothed DECIMAL(15,3) NULL,
    new_tests_smoothed_per_thousand DECIMAL(15,3) NULL,
    positive_rate DECIMAL(10,3) NULL,
    tests_per_case DECIMAL(10,2) NULL,
    tests_units VARCHAR(20) NULL,
    total_vaccinations INT NULL,
    people_vaccinated INT NULL,
    people_fully_vaccinated INT NULL,
    new_vaccinations INT NULL,
    new_vaccinations_smoothed INT NULL,
    total_vaccinations_per_hundred DECIMAL(10,2) NULL,
    people_vaccinated_per_hundred DECIMAL(10,2) NULL,
    people_fully_vaccinated_per_hundred DECIMAL(10,2) NULL,
    new_vaccinations_smoothed_per_million INT NULL,
    stringency_index DECIMAL(10,2) NULL,
    population_density DECIMAL(15,3) NULL,
    median_age DECIMAL(10,2) NULL,
    aged_65_older DECIMAL(10,3) NULL,
    aged_70_older DECIMAL(10,3) NULL,
    gdp_per_capita DECIMAL(15,3) NULL,
    extreme_poverty DECIMAL(10,2) NULL,
    cardiovasc_death_rate DECIMAL(10,3) NULL,
    diabetes_prevalence DECIMAL(10,2) NULL,
    female_smokers DECIMAL(10,2) NULL,
    male_smokers DECIMAL(10,2) NULL,
    handwashing_facilities DECIMAL(15,3) NULL,
    hospital_beds_per_thousand DECIMAL(10,2) NULL,
    life_expectancy DECIMAL(10,2) NULL,
    human_development_index DECIMAL(10,3) NULL
);
    
-- Select data from covid_deaths

SELECT 
	* 
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 3,4;


SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs. Total Deaths to show the likelyhood of dying if you contract covid

SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs Population
-- Shows % of Population infected with Covid

SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS percent_population_infected
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT 
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY 
	percent_population_infected DESC;

SELECT 
	location,
	population,
    date,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population, date
ORDER BY 
	percent_population_infected DESC;

-- Countries with Highest Death Count 

SELECT 
	location,
	MAX(total_deaths) AS total_death_count_country
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	total_death_count_country DESC;

-- Continents with Highest Death Count => wrong result

SELECT 
	continent,
	MAX(total_deaths) AS total_death_count_continent
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	total_death_count_continent DESC;

-- Correct
SELECT 
	location, SUM(new_deaths) as TotalDeathCount
FROM 
	covid_deaths
WHERE 
	continent is null 
AND 
	location not in ('World', 'European Union', 'International')
GROUP BY 
	location
ORDER BY 
	TotalDeathCount desc;

-- Global Numbers

SELECT 
	SUM(new_cases) AS total_cases_global,
	SUM(new_deaths) AS total_deaths_global,
	sum(new_deaths)/SUM(new_cases)*100 AS death_percentage_global
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
ORDER BY 1,2; 

SELECT 
	date,
	SUM(new_cases) AS total_cases_global,
	SUM(new_deaths) AS total_deaths_global,
	sum(new_deaths)/SUM(new_cases)*100 AS death_percentage_global
FROM 
	covid_deaths
WHERE 
	continent IS NOT NULL
GROUP BY date
ORDER BY 1,2; 


-- Total Population vs Vaccinations
-- Shows % of Population that has received at least one Covid Vaccine

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
    -- (rolling_people_vaccinated/population)*100
FROM 
	covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
    
-- ORDER BY 2,3
)
SELECT 
	*, (rolling_people_vaccinated/population)*100
FROM 
	pop_vs_vac;
 
 -- Using Temp Table to perform Calculation of Partition By in previous query
 
 DROP TABLE IF EXISTS Percent_Population_Vaccinated;
 
 CREATE TEMPORARY TABLE Percent_Population_Vaccinated
 (
 continent VARCHAR(255),
 location VARCHAR(255),
 date DATE,
 population BIGINT,
 new_vaccinations INT,
 rolling_people_vaccinated INT
 );
 
 INSERT INTO Percent_Population_Vaccinated
 SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL;
-- ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM Percent_Population_Vaccinated;
 
 
 -- Creating View to store data for visualisations
 
CREATE VIEW v_percent_population_vaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL;

SELECT * FROM v_percent_population_vaccinated;