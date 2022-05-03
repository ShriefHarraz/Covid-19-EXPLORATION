           /* Covid 19 exploration */

select *
from[dbo].[covid_deaths]


           -----  looking at the data that we are going to use ----

select continent, location, date , population, total_cases,new_cases, total_deaths, new_deaths 
from [dbo].[covid_deaths]
where continent != ''
order by location


	 --- question # 1 : what is highest countries for total cases per population ---
	 
with highest_cases as 
(
select location,population, max(cast(total_cases as int )) as highestinfectioncases
from [dbo].[covid_deaths]
where continent != ''
group by location, population
--order by highestinfectioncases desc
)

select location, population, highestinfectioncases , highestinfectioncases / cast (population as numeric) * 100 as cases_per_pop 
from highest_cases
where population != ''
order by cases_per_pop desc


     --- question # 2 : what is highest countries for total deaths per population ---

select location,cast (population as numeric) population , max(cast(total_deaths as int )) as highestdeathsnum,  max(cast(total_deaths as int ))/cast(population as numeric) * 100 as deaths_per_pop
from [dbo].[covid_deaths]
where continent != ''
and  population != ''
group by location, population
order by deaths_per_pop desc

       --- question # 3 : deaths per cases in daily basis  ---

select location, date, population, cast(total_cases as float) as total_cases ,cast (total_deaths as float) as total_deaths,(cast(total_deaths as float) / cast (total_cases as float)) * 100 as deathspercases
from [dbo].[covid_deaths]
where continent != ''
and total_cases != ''
order by location


          --- question # 4 :  total deaths per total cases  ---

select  sum(cast(new_cases as float))as  total_cases ,sum(cast(new_deaths as float))as  total_deaths ,sum(cast(new_deaths as float)) / sum(cast(new_cases as float)) * 100 as totaldeathspercases
from [dbo].[covid_deaths]
where continent != ''

         --- question # 5 :  total cases per total population  ---

select  sum(cast(new_cases as float))as  total_cases ,max(cast(population as float	)) as population , sum(cast(new_cases as float)) / max(cast(population as float )) * 100 as totalcasesperpop
from [dbo].[covid_deaths]
where continent != ''

         --- question # 6  :  total deaths per total population  ---

select  sum(cast(new_deaths as float))as  total_deaths ,max(cast(population as float )) as population , sum(cast(new_deaths as float)) / max(cast(population as float )) * 100 as totaldeathsperpop
from [dbo].[covid_deaths]
where continent != ''
          
       --- question # 7  :  total cases & deaths per continent   ---

select continent, sum(cast(new_cases as float))as  total_cases ,sum(cast(new_deaths as float))as  total_deaths
from [dbo].[covid_deaths]
where continent != ''
group by continent
order by 3 desc
     
select *
from [dbo].[covid_vaccination]
where continent != ''
order by location 

             ----  joining the two tables ----
    --- question # 8  :  total doses_given per pop   ---
	
select dea.location, dea.date, dea.population, dea.total_deaths, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as float)) over (Partition by dea.location) as total_vaccination
from [dbo].[covid_deaths] dea
join [dbo].[covid_vaccination] vacc
   on dea.location = vacc.location
   and dea.date = vacc.date
where dea.continent != ''
order by 1
       -----  using CTE -----
;with vaccineted_people as
(select dea.location, dea.date, dea.population, dea.total_deaths, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as float)) over (Partition by dea.location) as total_vaccination
from [dbo].[covid_deaths] dea
join [dbo].[covid_vaccination] vacc
   on dea.location = vacc.location
   and dea.date = vacc.date
where dea.continent != '')
--order by 1

select  location,total_vaccination, population, (total_vaccination / cast (population as float ))  as vaccperpop 
from vaccineted_people
where population != ''
--and location = 'Egypt
group by location, total_vaccination, population
order by vaccperpop desc

    ---- USING TEMP TABLE -----
drop table if exists #newly_vaccineted
create table #newly_vaccineted
(
location nvarchar(255),
date datetime,
population numeric,
total_deaths numeric,
new_vaccinations numeric,
total_vaccination numeric)

insert into #newly_vaccineted
select dea.location, dea.date, dea.population, dea.total_deaths, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as float)) over (Partition by dea.location) as total_vaccination
from [dbo].[covid_deaths] dea
join [dbo].[covid_vaccination] vacc
   on dea.location = vacc.location
   and dea.date = vacc.date
--where dea.continent != ''
--order by 1

select *,(total_vaccination / population)*100 as vaccperpop
from #newly_vaccineted
WHERE population != ''

               --- question # 9  :  total fully_vaccinated per pop   ---

select dea.location, dea.date, dea.population, dea.total_deaths, vacc.new_vaccinations,
max(cast(people_fully_vaccinated as float)) over (Partition by dea.location) as total_people_vaccinated
from [dbo].[covid_deaths] dea
join [dbo].[covid_vaccination] vacc
   on dea.location = vacc.location
   and dea.date = vacc.date
where dea.continent != ''
order by 1

;with full_vaccination_people as
(select dea.location, dea.date, dea.population, dea.total_deaths, vacc.new_vaccinations,
max(cast(people_fully_vaccinated as float)) over (Partition by dea.location) as total_people_vaccinated
from [dbo].[covid_deaths] dea
join [dbo].[covid_vaccination] vacc
   on dea.location = vacc.location
   and dea.date = vacc.date
where dea.continent != '')
--order by 1


select  location,total_people_vaccinated, population, (total_people_vaccinated / cast (population as float )) * 100 as vaccperpop 
from full_vaccination_people
where population != ''
--and location = 'Egypt
group by location, total_people_vaccinated, population
order by vaccperpop desc
              

























