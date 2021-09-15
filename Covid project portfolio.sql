SELECT * from practice..covidDeath where [continent] is  NULL
SELECT * from practice..covidVaccinations order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
from practice..covidDeath
order by 1,2

--chances of death
SELECT location,date,total_cases,total_deaths,(convert(decimal(15,3),total_deaths)/convert(decimal(15,3),total_cases))*100 as Deathpercentage 
from covidDeath
WHERE location='united states'
order by 1,2

-- Total cases vs population
-- percentage of population that contracted covid 
SELECT location,date,total_cases,population,(convert(decimal(15,3),total_cases)/convert(decimal(15,3),population))*100 as rateofcontraction 
from covidDeath
--WHERE location='united states'
order by 1,2

-- highcases vs population
SELECT location,population,MAX(total_cases) as highestcase ,MAX(convert(decimal(15,3),total_cases)/convert(decimal(15,3),population)) * 100 as impactonpopulation
from covidDeath
--WHERE location='united states'
GROUP by location,population
order by impactonpopulation DESC



--death count per population
SELECT  location,population,total_deaths,MAX(convert(decimal(15,3),total_deaths)/convert(decimal(15,3),population)) * 100 as deathperpopulation
from covidDeath
--WHERE location='united states'
GROUP by location 
--order by impactonpopulation DESC


SELECT  [continent], MAX(cast(total_deaths as int)) as deathcount from covidDeath
WHERE continent is NOT null
GROUP by [continent]
ORDER by deathcount DESC

-- continent with highest death count

select  SUM(cast(new_cases as int)) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int)) * 100 as deathpercentage from covidDeath
WHERE [continent] is NOT null
--group by [date]
order by deathpercentage DESC


-- total population vs vaccination


select d.continent,d.[location],d.[date],d.population,v.new_vaccinations, 
SUM(cast(v.new_vaccinations as int)) OVER(PARTITION by d.location order by d.location,d.date) as vaccine
from covidDeath d JOIN covidVaccinations v on d.[location]=v.[location] and d.[date]=v.[date]
WHERE d.[continent] is NOT null
--order by 2,3



--CTE 
with popvsvac (continent,LOCATION,date,population,new_vaccinations,rollingvaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.LOCATION order by dea.LOCATION,dea.DATE  ) as rollingvaccinated
from covidDeath dea join covidVaccinations vac on dea.LOCATION=vac.LOCATION and dea.[date]=vac.[date]
WHERE dea.continent is not NULL AND vac.new_vaccinations is not NULL)

SELECT *,(rollingvaccinated/population)*100 as ratio from popvsvac
order by ratio DESC


--temp table
DROP TABLE if EXISTS ppv
create TABLE ppv
( continent nvarchar(255),
LOCATION nvarchar(255),
date DATETIME,
population numeric,
new_vaccinations numeric,
rollingvaccinated numeric
)
INSERT into ppv
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.LOCATION order by dea.LOCATION,dea.DATE  ) as rollingvaccinated
from covidDeath dea join covidVaccinations vac on dea.LOCATION=vac.LOCATION and dea.[date]=vac.[date]
WHERE dea.continent is not NULL 

SELECT *,(rollingvaccinated/population)*100 as ratio from ppv


--CREATE view
CREATE VIEW ppv1 as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.LOCATION order by dea.LOCATION,dea.DATE  ) as rollingvaccinated
from covidDeath dea join covidVaccinations vac on dea.LOCATION=vac.LOCATION and dea.[date]=vac.[date]
WHERE dea.continent is not NULL 



SELECT * from ppv1










SELECT d.LOCATION,sum(cast(v.new_vaccinations as int)) as vaccine from covidDeath d join covidVaccinations v on d.[location]=v.LOCATION
GROUP BY d.[location]







-- change date from nvarchar to date type
update covidDeath
set date = CONVERT(nvarchar(255),CONVERT(date,date,105))
ALTER TABLE covidDeath
alter COLUMN date date

UPDATE covidVaccinations
set [date]=CONVERT(nvarchar(255),CONVERT(date,[date],105))
ALTER TABLE covidVaccinations
ALTER COLUMN DATE DATE
