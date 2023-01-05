create database Portfolio_project
use portfolio_project
select * from CovidDeaths
select * from covidvaccination;
select Location , date , total_cases , new_cases , total_deaths, population from covidDeaths

-- Shows us Total cases vs Total deaths
-- Shows liklihoood of death if covid is contracted in your country.
select Location , date , total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage  
from covidDeaths where location like '%states%' order by 1,2

--Looking at total cases vs total population
-- shows what percentage of population got covid
select Location , date , total_cases, Population , (total_cases/Population)*100 as death_percentage  
from covidDeaths where location like '%states%' order by 1,2

--Looking at countrues with highest infection rate compared to population
select Location, MAX(total_cases) as highestinfectioncount, Population , MAX((total_cases/Population)) *100 as percentagepopulationinfected  
from covidDeaths group by location,population order by percentagepopulationinfected desc

--showing countries with highest death count per population
select Location, MAX(cast(Total_deaths as int) ) as totaldeathcount from covidDeaths where continent is not null group by Location order by totaldeathcount desc

--Break things down, showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount from covidDeaths where continent is not null group by continent order by totaldeathcount desc

-- Global Numbers
select  date, sum(new_cases),sum(cast (new_deaths as int)) --total_deaths, (total_deaths/total_cases)*100 as death_percentage  
from covidDeaths 
--where location like '%states%' 
where continent is not null
group by date
order by 1,2

select date, sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as newdeathpercentage from covidDeaths
-- where location like %states% 
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as newdeathpercentage 
from covidDeaths where continent is not null
order by 1,2

-- Total populations vs vaccincation
With PopvsVac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated ) as 
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100 
From Portfolio_project..covidDeaths dea 
join Portfolio_project..covidvaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (Rollingpeoplevaccinated/population)*100 from PopvsVac

-- TEMP TABLE
DROP Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100 
From Portfolio_project..covidDeaths dea 
join Portfolio_project..covidvaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

Select *, (Rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

-- Creating view for visualizations
create view percentpopulationvaccincated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
-- ,(Rollingpeoplevaccinated/population)*100 
From Portfolio_project..covidDeaths dea 
join Portfolio_project..covidvaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select * from percentpopulationvaccincated