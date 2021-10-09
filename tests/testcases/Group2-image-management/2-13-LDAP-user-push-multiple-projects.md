Test 2-13 - User Create Multiple Projects (LDAP Mode)
=======

# Purpose:

To verify that a non-admin user can create multiple projects in LDAP mode.

# References:
User guide

# Environment:
* This test requires that a Harbor instance is running and available.
* Harbor is set to authenticate against an LDAP or AD server. ( auth_mode is set to **ldap_auth** .) The user data is stored in an LDAP or AD server.
* A linux host with Docker CLI installed (Docker client).
* At least a non-admin user. 

# Test Steps:

Same as Test 2-03 except that users are from LDAP/AD.

# Expected Outcome:
* Same as Test 2-03.

# Possible Problems:
None