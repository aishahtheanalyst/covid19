select *
from coviddeaths
order by 3, 4;

select *
from covidvaccinations
order by 3,4;


-- updated all columns manually from both tables to show blank fields as null

update projectportfolio.covidvaccinations
set human_development_index = null
where human_development_index = "";

-- select data we will be using

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;

-- total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
order by 1,2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where location like '%kingdom%'
order by 1,2;

-- total cases vs population
-- shows what percentage of population infected with covid

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as population_infected_percent
from coviddeaths
where location like '%kingdom%'
order by 1,2;

-- countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as population_infected_percent
from coviddeaths
group by location, population
order by population_infected_percent desc;

-- countries with highest death count per population

select location, max(cast(total_deaths as unsigned)) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc;

-- showing continents with the highest death count per population

select location, max(cast(total_deaths as unsigned)) as total_death_count
from coviddeaths
where continent is not null
group by continent
order by total_death_count desc;

-- global numbers

select date, sum(new_cases) as total_cases, sum((new_deaths)) as total_deaths, sum((new_deaths))/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum((new_deaths)) as total_deaths, sum((new_deaths))/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2;

-- total population vs vaccinations
-- shows percentage of population that has received at least one covid vaccine

select *
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- using temp table to perform calculation on partition by in previous query
create temporary table percentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric);

insert into percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

select *, (rolling_people_vaccinated/population)*100
from percentPopulationVaccinated;


-- creating view to store data for later visualisations

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
