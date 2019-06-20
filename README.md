# docker-nginx-ldap-pam
Nginx container image that uses ldap as basic authentication to a single _upstream server_

**NOTE** currently it has been tested only for AD setups
      
## Versioning
Version of the current stable container is placed in _VERSION_ file.
[sematic versioning](https://semver.org/) is used to version the container
    

## Running the container
Container behaivor can be adjusted using this environment variables

  1. `LDAP_URI` *default: None*  Ldap uri that is used for connecting to ldap server
  2. `LDAP_BASE_DN` *default: None* Ldap base DN in which user search is performed 
  3. `LDAP_BIND_USER_DN` *default: None* User DN that is used for binding to ldap server
  4. `LDAP_BIND_USER_PASSWORD` *default: None* Bind user password
  5. `LDAP_USER_FILTER` *default: ((objectClass=user)* Ldap filter to use when searching for users.
  6. `LDAP_GROUP_FILTER` *default: ((objectClass=group)* Ldap filter to use when searching for group.
  7. `LDAP_LOGIN_ATTRIBUTE` *default: None*  The LDAP attribute used for the authentication lookup, i.e. which attribute is matched to the username when you log in.
  8. `LDAP_AUTH_GROUP` *default: None* Only users of this group can access `NGINX_UPSTREAM_SERVER`
  9. `NGINX_UPSTREAM_SERVER` *default: None* Server which needs ldap authentication 
  10. `LDAP_AD_DOMAIN_SID` *default: None*. _Optional_. AD domain sid. If this environment variable is set - AD specific `nslsd` configuration is chosen 
  11. `NGINX_FORBIDDEN_LOCATIONS` *default: None*. _Optional_. A list of `upstream` `locations` separated by white space that should return `403` http status code

### Example

```
docker run -e LDAP_URI="ldap://ad.somecompany.com" -e LDAP_BASE_DN="ou=ad,dc=ad,dc=somecompany,dc=com" -e LDAP_BIND_USER_DN="cn=someuser,ou=users,ou=ad,dc=ad,dc=somecompany,dc=com" -e LDAP_BIND_USER_PASSWORD="SOME_PASSWORD" -e LDAP_LOGIN_ATTRIBUTE="userPrincipalName" -e LDAP_AUTH_GROUP="kibana-ops" -e NGINX_UPSTREAM_SERVER="http://localhost:5601" -e LDAP_AD_DOMAIN_SID="S-1-5-21-3623811015-3361044348-30300820" -e NGINX_FORBIDDEN_LOCATIONS="/api/console" ggramal/nginx-ldap-pam:0.1.0
```
This command 

 - Sets ldap uri to `ldap://ad.somecompany.com`
 - Sets dn search path for users and groups to `ou=ad,dc=ad,dc=somecompany,dc=com`
 - Uses `cn=someuser,ou=users,ou=ad,dc=ad,dc=somecompany,dc=com` as bind user to bind to ldap server
 - Uses `SOME_PASSWORD` string for the bind user password
 - Uses `(objectClass=user)` to authenticate only users with `objectClass` attribute equal to `user` value 
 - Uses `(objectClass=group)` for using only groups with `objectClass` attribute equal `group`
 - Uses `userPrincipalName` attribute to check against basic auth login prompt
 - Uses `http://localhost:5601` as a nginx upstream server
 - Only `kibana-ops` ldap group users can access `NGINX_UPSTREAM_SERVER`
 - Uses `S-1-5-21-3623811015-3361044348-30300820` as domain sid
 - Adds `location /api/console { deny all;return 403;}` in nginx config
 
## How it works

This nginx setup is based on couple of components:
1. It uses `envsubst` util to configure files in `templates/` folder based on environment variables
2. It uses `nss-pam-ldapd` as NSS and PAM modules for authentication and identity management using LDAP server
3. It uses `nginx pam module` for basic authentication based on pam config
4. It uses `pam_succeed_if.so` pam module to check if the user is in the configured group

   
