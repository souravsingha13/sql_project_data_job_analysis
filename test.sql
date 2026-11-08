SELECT 
    job_title_short as title,
    job_location as location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Dhaka' as date,
    EXTRACT(month FROM job_posted_date) AS month
FROM
    job_postings_fact
LIMIT 100;


SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'Dhaka' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;


select * 
from (select * FROM job_postings_fact
    where EXTRACT( MONTH from job_posted_date) = 1)
as january_jobs;


select 
    company_id,
    count(*)
from
    job_postings_fact
group by
    company_id
order by
    count(*) desc
limit 10;


WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS job_count
    FROM job_postings_fact
    WHERE company_id IS NOT NULL
    GROUP BY company_id
    ORDER BY job_count DESC
    LIMIT 10
)
SELECT
    company_dim.name AS company_name,
    company_job_count.job_count
FROM company_dim
INNER JOIN company_job_count
    ON company_dim.company_id = company_job_count.company_id
ORDER BY company_job_count.job_count DESC;

