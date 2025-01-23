

--SELECT DATA THAT WE ARE GOING TO USING

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2 

--Looking for total cases vs total deaths
--show likelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2 


--Looking for total cases vs population
--show waht population percentage got covid
select location, date, population, total_cases, (total_cases/population)*100 CasesPercentage
from dbo.CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2 



--looking at countries with highest infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%nesia%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc



--Showing Countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
--where location like '%nesia%'
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--showing continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2 

-- Global number calculation
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2 



--Covid Vaccinations
select *
from PortofolioProject..CovidVaccinations

--LOOKING FOR TOTAL POPULATION VS TOTAL VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location) --selain cast, bisa pakai convert jg
--over partition hanya mengeluarkan total kasus yg sama tiap tanggal at same loc, meskipun akan dikalkukasi ulang setiap lokasi baru
FROM PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--LOOKING FOR BETTER TOTAL POPULATION VS TOTAL VACCINATIONS (ROLLING UP)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RolingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, RolingPeopleVaccinated/population*100
from PopvsVac



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
