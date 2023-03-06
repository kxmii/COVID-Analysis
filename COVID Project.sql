--Select Data by Country-Date
select Location, date, total_cases, new_cases, total_deaths, population
from [Covid Project]..CovidDeaths
order by 1,2

--Deaths vs Total Cases in Canada (Deathrate in Canada)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as Deathrate
from [Covid Project]..CovidDeaths
where location like '%canada%'
order by 1,2


--Total Cases vs Canadian Population (Infectionrate in Canada)
select Location, date, total_cases, population, (total_cases/population*100) as Infectionrate
from [Covid Project]..CovidDeaths
where location like '%canada%'
order by 1,2


--Countries with highest infection rates
select Location, max(total_cases) as Max_Cases, population, max(total_cases/population*100) as Infectionrate
from [Covid Project]..CovidDeaths
group by Location, Population
order by Infectionrate Desc



--Countries with Highest Deathcounts
--cast total_deaths to correct datatype, and sort out entries with null continent.
select Location, max(cast(total_deaths as int)) as deathcount
from [Covid Project]..CovidDeaths
where continent is not null
group by Location, Population
order by deathcount Desc


--Continents with highest death count
select continent, max(cast(total_deaths as int)) as deathcount
from [Covid Project]..CovidDeaths
where continent is not null
group by continent
order by deathcount Desc


--Deaths worldwide
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathrate
from [Covid Project]..CovidDeaths
where continent is not null
order by 1,2




--Joining tables to look at population vs vaccinations
select deaths.continent, deaths.location, deaths.date, population, vaccinations.new_vaccinations, 
sum(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as sum_vaccinations
from [Covid Project]..CovidDeaths deaths
join [Covid Project]..CovidVaccinations vaccinations
	on deaths.location=vaccinations.location
	and deaths.date=vaccinations.date
where deaths.continent is not null
order by 2,3


--CTE to view percentvaccinated
with popvsvac (continent, location, date, population, new_vaccinations, sum_vaccinations)
as
(
select deaths.continent, deaths.location, deaths.date, population, vaccinations.new_vaccinations, 
sum(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as sum_vaccinations
from [Covid Project]..CovidDeaths deaths
join [Covid Project]..CovidVaccinations vaccinations
	on deaths.location=vaccinations.location
	and deaths.date=vaccinations.date
where deaths.continent is not null
)
select *, sum_vaccinations/population*100 as percentvaccinated
from popvsvac


--Temp table to view percent vaccinated
drop table if exists #percentvaccinated
create table #percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_vaccinations numeric
)
Insert into #percentvaccinated
select deaths.continent, deaths.location, deaths.date, population, vaccinations.new_vaccinations, 
sum(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as sum_vaccinations
from [Covid Project]..CovidDeaths deaths
join [Covid Project]..CovidVaccinations vaccinations
	on deaths.location=vaccinations.location
	and deaths.date=vaccinations.date
where deaths.continent is not null
select *, sum_vaccinations/population*100 as percentvaccinated
from #percentvaccinated


--creating a view 
use [Covid Project]
go
create view percentvaccinated as
select deaths.continent, deaths.location, deaths.date, population, vaccinations.new_vaccinations, 
sum(cast(vaccinations.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as sum_vaccinations
from [Covid Project]..CovidDeaths deaths
join [Covid Project]..CovidVaccinations vaccinations
	on deaths.location=vaccinations.location
	and deaths.date=vaccinations.date
where deaths.continent is not null

select *
from percentvaccinated


--deathcount by continent view
use [Covid Project]
go
create view deathcount as
select continent, max(cast(total_deaths as int)) as deathcount
from [Covid Project]..CovidDeaths
where continent is not null
group by continent

select *
from deathcount
order by deathcount desc