select *
from PortfolioProect..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProect..CovidDeaths
order by 1,2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProect..CovidDeaths
where location like '%china%'
order by 1,2



select location, date, population, total_cases,  (total_cases/population)*100 as Infectedpercentage
from PortfolioProect..CovidDeaths
where location like '%kenya%'
order by 1,2

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedRate
from PortfolioProect..CovidDeaths
--where location like '%kenya%'
group by population, location
order by PopulationInfectedRate desc


select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProect..CovidDeaths
--where location like '%kenya%'
where continent is not null
group by location
order by TotalDeathsCount desc


select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProect..CovidDeaths
--where location like '%kenya%'
where continent is not null
group by continent
order by TotalDeathsCount desc



select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)  as Deathspercentage
from PortfolioProect..CovidDeaths
where continent is not null
group by date
order by 1,2



with  PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProect..CovidDeaths dea
join PortfolioProect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (PeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from PopvsVac




create table #PercentageofPeopleVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentageofPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProect..CovidDeaths dea
join PortfolioProect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (PeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from #PercentageofPeopleVaccinated



drop table if exists
CREATE VIEW PercentageofPeopleVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProect..CovidDeaths dea
join PortfolioProect..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentageofPeopleVaccinated