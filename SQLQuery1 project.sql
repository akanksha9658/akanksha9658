


Select *
From PortfolioProject..coviddeaths
where continent is not null
order by 3,4



--Select *
--From PortfolioProject..covidvaccination
----order by 3,4


Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..coviddeaths
where continent is not null
----order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
----order by 1,2

---Looking at Total Cases vs Population
---shows what percentage of population got covid


Select Location, date,population, total_cases,(total_cases/population)*100 as percentpopulationinfected
From PortfolioProject..coviddeaths
--Where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
Select Location,population, max(total_cases) as highestinfectioncont,  max((total_cases/population))*100 as percentpopulationinfected
From PortfolioProject..coviddeaths
--Where location like '%states%'
group by Location,population
order by percentpopulationinfected  desc



--showing countries with highest death count per population

Select Location, max(cast(Total_deaths as int) )as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is not null
--Where location like '%states%'
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--showing the continents with highest death count per population

Select continent, max(cast(Total_deaths as int) ) as TotalDeathCount
From PortfolioProject..coviddeaths
where continent is not null
--Where location like '%states%'
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..coviddeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations
--show percentage of population that has received atleast one covid vaccine

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

--TEMP table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date  datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating  view to store data for later visualisation
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location  order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null