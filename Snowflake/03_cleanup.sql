/*
=====================================================================
 Securing AI Agents in Snowflake: Data, Model, and Action Controls
 File 3 of 3: cleanup

 Removes everything 01_setup.sql created.
=====================================================================
*/

USE ROLE ACCOUNTADMIN;

-- If you attached a session policy in setup step 3b, unset it first:
-- ALTER USER <AGENT_SERVICE_USER> UNSET SESSION POLICY;

-- Turn off the account level guardrail setting from setup step 2b.
ALTER ACCOUNT UNSET AI_SETTINGS;

-- Drops the tables, views, policies, tag, sequence, procedure,
-- semantic view, search service, agent, and session scope.
DROP DATABASE IF EXISTS AI_AGENT_SECURITY_DEMO;

USE ROLE SECURITYADMIN;
DROP ROLE IF EXISTS MFG_AI_AGENT_ROLE;
DROP ROLE IF EXISTS PROCUREMENT_MGR;
DROP ROLE IF EXISTS QUALITY_ENGINEER;
DROP ROLE IF EXISTS PO_SERVICE_ROLE;

-- Setup step 2a removed default model access from PUBLIC for the whole
-- account. If other users in this account need it back, restore it as
-- described in the Snowflake documentation for Cortex model RBAC.
