Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..CovidDeaths
--Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select the data we are using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2


--View total cases vs total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1, 2


--View total cases vs population
Select Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where location like '%Phili%' and continent is not null
Order by 1,2


--View countries with highest infection rates in terms of population
Select Location, population, MAX(total_cases) as HighestCount, MAX((total_cases/population))*100 as CasesPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by CasesPercentage desc


--View countries with highest death rates in terms of population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


--View continent with highest death rates in terms of population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent is null
--Group by location
--Order by TotalDeathCount desc


--View continents with higihest deathcounts
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2



--Total Population vs Total Vaccinated over time
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsOverTime
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- CTE
with PopvsVac (Continent, Location, Date, Population, NewVaccionations, VaccinationsOverTime)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsOverTime
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (VaccinationsOverTime/Population)*100
From PopvsVac


--Temp Table option
DROP Table if exists #VaccinatedPopulation
Create Table #VaccinatedPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationsOverTime numeric
)

Insert into #VaccinatedPopulation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as VaccinationsOverTime
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (VaccinationsOverTime/Population)*100
From #VaccinatedPopulation


--Creatieng view to store data for later visualizations
Create view PopvsVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
	OVER (Partition by dea.location Order by dea.location, dea.date) as VaccinationsOverTime
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 