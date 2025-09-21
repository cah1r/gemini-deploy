-- CREATE ROLE gemini_app LOGIN PASSWORD 'ignore';
CREATE DATABASE gemini_db OWNER gemini_app;
\c gemini_db;
CREATE SCHEMA IF NOT EXISTS public;
GRANT ALL PRIVILEGES ON DATABASE gemini_db TO gemini_app;
GRANT ALL PRIVILEGES ON SCHEMA public TO gemini_app;
