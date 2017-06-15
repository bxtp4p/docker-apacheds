#!/bin/bash

# Initial check of a restart has happen or not
# just checking if the default pid exists. If yes, removes it and just will ot reload the whole scheme
echo "current directory : ""$(pwd)"
if [ -f default/run/apacheds-default.pid ]
then
    echo "found existing running instance, will keep it and not start a new one"
    rm default/run/apacheds-default.pid
    startnew=0;
else
    echo "No existing running instance, starting a new server"
    startnew=1;
fi


# If running instance, exit at this stage
if [ $startnew -eq 0 ]
then
    echo "previous running instance, exiting at this stage, Ldap ready to go";
else



    # Start apacheds
    apacheds start default
    echo "waiting for apacheds to properly start"
    sleep 40

    # Load initial content from Ldifs
    # Will process files whith absolute path specified in LDIFINIT variable. To be used in conjunction  a -v option in the docker run command
    if [ -z "$LDIFINIT" ]
    then
      echo "No Initial files found, starting with an empty server"
    else
      echo "Found Initial Ldif files to populate server : $LDIFINIT"
      ldapmodify -c -a -f $LDIFINIT -h localhost -p 10389 -D "uid=admin,ou=system" -w secret

    fi

  # change Admin Password to the value specified in ADMINPWD if provided
  #  echo "Changing password"
  if [ -z "$ADMINPWD" ]
  then
    echo "WARNING : No password found as environment variable, keeping default password"
  else
    echo "Changing password for system account"
    cp /tmp/admin_password.ldif .
    echo "userpassword: $ADMINPWD" >> admin_password.ldif
    ldapmodify -c -a -f admin_password.ldif -h localhost -p 10389 -D "uid=admin,ou=system" -w secret
    #cleans places where admin password could be found in the container
    rm admin_password.ldif
    # the following actually does not work as environment variable is always visible at
    # the container level and will allways be accessible with a docker inspect or docker exec
    # See the additionnal comments in the readme.
    unset ADMINPWD

  fi

  #  ldapmodify -c -a -f $HOME/ldifs/admin_password.ldif -h localhost -p 10389 -D "uid=admin,ou=system" -w secret
  apacheds stop default
fi

#Restart apache in Console mode
apacheds console default
