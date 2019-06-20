#!/bin/bash

#u USAGE: docker-entrypoint.sh | docker-entrypoint.sh -h
#u DESCRIPTION:
#u   Entrypoint to nginx-ldap-pam container. It:
#u     1) checks variables needed to render nginx/pam configs.
#u     2) Renders nginx/pam configs.
#u     4) runs nginx.
#u OPTIONS:
#u   -h/-? prints this help

print_help()
{
  $ECHO '';

  [[ -n "$1" ]] && $ECHO "$1";

  $GREP '^#u' $0 | sed 's/^#u//g' 1>&2;
}

ECHO='echo'
GREP='grep'

while getopts "?h" opt;
do
  case "$opt" in
    h|\?)
      print_help;
      exit 0;
      ;;
  esac
done

ERROR_NO_SUCH_FILE_OR_DIR=2;
export NGINX_FORBIDDEN_LOCATIONS_FORMATED="";

[[ -z "$LDAP_URI" ]] && echo "LDAP_URI mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
[[ -z "$LDAP_BASE_DN" ]] && echo "LDAP_BASE_DN mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
[[ -z "$LDAP_AUTH_GROUP" ]] && echo "LDAP_AUTH_GROUP mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
[[ -z "$LDAP_BIND_USER_DN" ]] && echo "LDAP_BIND_USER_DN mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
[[ -z "$LDAP_BIND_USER_PASSWORD" ]] && echo "LDAP_BIND_USER_PASSWORD mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
[[ -z "$NGINX_UPSTREAM_SERVER" ]] && echo "NGINX_UPSTREAM_SERVER mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR

if [[ ! -z "$LDAP_AD_DOMAIN_SID" ]]
then
  [[ -z "$LDAP_LOGIN_ATTRIBUTE" ]] && echo "LDAP_LOGIN_ATTRIBUTE mandatory variable is not set" && exit $ERROR_NO_SUCH_FILE_OR_DIR
  export LDAP_USER_FILTER=${LDAP_USER_FILTER:='(objectClass=user)'}
  export LDAP_GROUP_FILTER=${LDAP_GROUP_FILTER:='(objectClass=group)'}
  mv /etc/nslcd.conf.ad.tmpl /etc/nslcd.conf.tmpl
else
  mv /etc/nslcd.conf.non-ad.tmpl /etc/nslcd.conf.tmpl
fi

if [[ ! -z "$NGINX_FORBIDDEN_LOCATIONS" ]] && [[ "$NGINX_FORBIDDEN_LOCATIONS" != "" ]] && [[ "$NGINX_FORBIDDEN_LOCATIONS" != " " ]]
then
  for l in $NGINX_FORBIDDEN_LOCATIONS
  do
    export NGINX_FORBIDDEN_LOCATIONS_FORMATED=$(printf "$NGINX_FORBIDDEN_LOCATIONS_FORMATED\n   location $l { deny all; return 403;}")
  done
fi

envsubst < /etc/nslcd.conf.tmpl > /etc/nslcd.conf
envsubst < /etc/pam.d/nginx.tmpl > /etc/pam.d/nginx
envsubst '${NGINX_UPSTREAM_SERVER} ${NGINX_FORBIDDEN_LOCATIONS_FORMATED}' < /etc/nginx/conf.d/nginx-ldap-pam.conf.tmpl > /etc/nginx/conf.d/nginx-ldap-pam.conf
rm /etc/nslcd.conf*tmpl
rm /etc/nginx/conf.d/nginx-ldap-pam.conf.tmpl
rm /etc/pam.d/nginx.tmpl
chmod 600 /etc/nslcd.conf
nslcd
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf 
