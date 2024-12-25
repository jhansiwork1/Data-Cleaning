-- Exploratory Data Analysis(EDA)

-- Basic EDA
#Max and Min laid off
select max(total_laid_off), min(total_laid_off)
from layoffs_copy;
-- 12000 is the highest number of laid off and 3 is the smallest 

# Names of highest and least laid of companies
select company, total_laid_off
from layoffs_copy
where total_laid_off in (
select max(total_laid_off)
from layoffs_copy);

select company, total_laid_off
from layoffs_copy
where total_laid_off in (
select min(total_laid_off)
from layoffs_copy);
-- Google laid off highest employees and Branch laid off lowest employees without considering other factors

#Max and Min % laid off
select max(percentage_laid_off), min(percentage_laid_off)
from layoffs_copy;
-- 1 (100% company laid off) is the higest laid off and 0 (none laid off) is the least

-- Names of the companies 
select company, percentage_laid_off
from layoffs_copy
where percentage_laid_off in (
select max(percentage_laid_off)
from layoffs_copy);

select company, percentage_laid_off
from layoffs_copy
where percentage_laid_off in (
select min(percentage_laid_off)
from layoffs_copy);
-- lots of companies laid off 100% employees and TaskUs laid off 0 employees

# Max layoff in a single day in each company without adding same company
select company, max(total_laid_off) as max
from layoffs_copy
group by company
order by 2 desc
limit 5;
-- Google has max layoff in a single day without considering other factors

# Adding layoffs in same company
select company, sum(total_laid_off) as sum_totaloff
from layoffs_copy
group by company
order by 2 desc
limit 5;
-- Amazon has max layoff after adding same companies

#Max % layoff in each company in a single day without adding same company
select company, max(percentage_laid_off) as max
from layoffs_copy
where percentage_laid_off is not null
group by company
order by 2 desc
limit 5;
-- Lots of companies have 1 percent layoff, where 1 means 100% company laid off

# Biggest company in companies laid off 100% can be identified by amount of funds raised
select company, max(percentage_laid_off), funds_raised_millions
from layoffs_copy
where percentage_laid_off = 1
group by company, funds_raised_millions
order by funds_raised_millions desc;
-- Britishvolt is the biggest company with 100% laid off

# Location where most laid off happened
select location, sum(total_laid_off)
from layoffs_copy
group by location
order by 2 desc
limit 5;
-- SF Bay Area has most layoffs

# country where most laid off happened
select country, sum(total_laid_off)
from layoffs_copy
group by country
order by 2 desc
limit 5;
-- United States has most layoffs

# Stage where most laid off happened
select stage, sum(total_laid_off)
from layoffs_copy
group by stage
order by 2 desc
limit 5;
-- Post-IPO stage has most layoffs

# Year where most laid off happened
select year(date), sum(total_laid_off)
from layoffs_copy
group by year(date)
order by 2 desc
limit 5;
-- 2022 year has most layoffs

# industry where most laid off happened
select industry, sum(total_laid_off)
from layoffs_copy
group by industry
order by 2 desc
limit 5;
-- Consumer industry has most layoffs

-- Adding a new column company size and inserting data form calculation as below
-- company size = total_laid_off/percentage_laid_off
alter table layoffs_copy
add comp_size int(20);

Update layoffs_copy
Set comp_size = total_laid_off / percentage_laid_off
Where percentage_laid_off != 0
and percentage_laid_off is not null;

#Max layoff by company size in a single day
select company, max(total_laid_off) as nmbr, max(percentage_laid_off) as percent, comp_size
from layoffs_copy
where percentage_laid_off is not null
and total_laid_off is not null
group by company, comp_size
order by percent desc, nmbr desc;
-- Katerra has the highest layoff in a signle day considering the company size(percentage and total laid off)

-- Top 5 companies laid off per year
with Year_laidoff as
(
Select company, 
year(date) AS years, 
sum(total_laid_off) AS total_off,
dense_rank() over(partition by year(date) order by SUM(total_laid_off) desc) as ranking
  from layoffs_copy
  where year(date) is not null
  group by company, years
)
select *
from Year_laidoff
where ranking <= 5;

-- Rolling Total of Layoffs Per Month
with Monthly_laidoff as
(
select substring(date,1,7) as Monthly, sum(total_laid_off) as sum_laidoff
from layoffs_copy
group by Monthly
)
select *,
sum(sum_laidoff) over(order by Monthly) as ranking
from Monthly_laidoff;