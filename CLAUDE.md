# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A SQL learning/analysis project over a data-job-postings dataset (2023). There is no application code, build, lint, or test tooling — work consists of writing and running PostgreSQL queries.

## Database setup

- PostgreSQL on `localhost:5432`, user `postgres`. Database name: `sql_course`.
- Queries are run from VS Code via the SQLTools extension; connections ("Local PostgreSQL" → `postgres` db, "sql_course" → `sql_course` db) are defined in `.vscode/settings.json`. The `*.session.sql` files are SQLTools scratch sessions tied to those connections.
- To (re)build from scratch, run the scripts in `sql_load/` in order:
  1. `1_create_database.sql` — creates `sql_course` (run while connected to `postgres`).
  2. `2_create_tables.sql` — creates the four tables, FKs, and indexes.
  3. `3_modify_tables.sql` — loads `csv_files/*.csv` via server-side `COPY` using absolute paths under `D:\sql_project_data_job_analysis\csv_files\`. Load order matters because of FKs: `company_dim`, `skills_dim`, `job_postings_fact`, `skills_job_dim`. If `COPY` fails with "permission denied", use the client-side `\copy` commands in the comment at the top of that file (via pgAdmin's PSQL Tool).
- With `psql` available: `psql -U postgres -d sql_course -f <file.sql>`.

## Schema (star schema)

- `job_postings_fact` (~788k rows) — one row per posting. Key columns: `job_title_short` (normalized role, e.g. `'Data Analyst'`), `job_location` (`'Anywhere'` = remote), `job_posted_date` (TIMESTAMP, no time zone — stored as UTC), `job_country`, `salary_year_avg` / `salary_hour_avg` (mostly NULL), `job_work_from_home`, `job_no_degree_mention`, `job_health_insurance`.
- `company_dim` — joined via `job_postings_fact.company_id`.
- `skills_dim` — `skills` (name) and `type` (e.g. `programming`).
- `skills_job_dim` (~3.7M rows) — many-to-many bridge (`job_id`, `skill_id`) between postings and skills.

Typical skill analysis: `job_postings_fact` → `skills_job_dim` (on `job_id`) → `skills_dim` (on `skill_id`). Filter `salary_year_avg IS NOT NULL` for salary questions.

## Notes

- The CSVs are large (`skills_job_dim.csv` ~3.7M lines, `job_postings_fact.csv` ~788k); don't read them whole — use `head` or query the database.
- `test.sql` holds ad-hoc practice queries; convert timestamps with `AT TIME ZONE 'UTC' AT TIME ZONE '<zone>'` (user's local zone is `Asia/Dhaka`).
