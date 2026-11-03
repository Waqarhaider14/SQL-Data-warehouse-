-- find second highest salary
select * from (
select first_name, salary, emp_id, department, dense_rank() over (order by salary) as salary_rank
from public.employee
)
where salary_rank = 2;

-- find duplicates department
SELECT * FROM (
SELECT emp_id,
       department,
       salary,
       ROW_NUMBER() OVER (
           PARTITION BY department
           ORDER BY salary DESC
       ) AS rn
FROM employee
)
WHERE rn>1;
