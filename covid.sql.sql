
-- Showing Death per Total Case
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Death
order by 1,2 

-- Showing what percentage of people are affected by Covid in Indonesia
Select location,date, population,total_cases, (total_cases/population)*100 as CasePercentage
from PortfolioProject..Covid_Death
where location like 'Indonesia'
AND continent is not null
order by 1,2 

-- Showing maximum percentage of Total Cases and Case Percentege by each location 
Select  Location, Population,Date, MAX(total_cases) as [Highest Cases], MAX((total_cases/population)*100) as [Pecent Population Infected]
from PortfolioProject..Covid_Death
where continent is not null
group by location, population,Date
order by [Pecent Population Infected] desc

-- Showing maximum death per population by each location
Select  location, MAX(cast(new_deaths as int)) as [Total Death Count]
from PortfolioProject..Covid_Death
where continent is not null
group by location, population
order by [Total Death Count] desc

-- Showing maximum death per population by each continent
Select continent, MAX(cast(total_deaths as int)) as [Total Death Count]
from PortfolioProject..Covid_Death
where continent is not null
group by continent
order by [Total Death Count] desc

-- Showing total new cases by day around the world
select date, sum(new_cases) as [New Cases]
from PortfolioProject..Covid_Death
group by date
order by date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 