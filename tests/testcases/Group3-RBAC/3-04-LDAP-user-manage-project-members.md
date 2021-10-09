Test 3-04 - Manage Project Members (LDAP Mode)
=======

# Purpose:

To verify that a non system admin user can add members of various roles to a project in LDAP mode.

# References:
User guide

# Environment:
* This test requires that a Harbor instance is running and available.
* Harbor is set to authenticate against an LDAP or AD server. ( auth_mode is set to **ldap_auth** .) The user data is stored in an LDAP or AD server.
* A linux host with Docker CLI installed (Docker client).
* At least three non-admin users are in Harbor. 

# Test Steps:

**NOTE:**  
* In below test, user A, B and C are non system admin users. User A, B, C and project X should be replaced by longer and meaningful names.
* MUST use two kinds of browsers at the same time to ensure independent sessions. For example, use Chrome and Firefox, or Chrome and Safari. 
* DO NOT use the same browser to log in two users at the same time in different windows(tabs).

Same as Test 3-01.

# Expected Outcome:

Same as Test 3-01.

# Possible Problems:
None