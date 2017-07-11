NB : this branch is set up to correct problems encountered in deployment to openshift as stated in Issue#1

docker-apacheds
===============
A docker image to run [Apache directory Server](http://directory.apache.org/apacheds/)

## Quick start

start a new instance :
```
docker run -d -p 10389:10389 --name my-ldap-ds yvnicolas/apacheds
```

You can then access the ldap directory using [Apache directory studio](http://directory.apache.org/studio/). Set up a connection to localhost:10389 using `uid=admin,ou=system`
and default password secret.

Administrative password can be changed using the `ADMINPWD` environment variable :
```
docker run -d -p 10389:10389 --name my-ldap-ds -e ADMINPWD=my-super-secret yvnicolas/apacheds
```

If you have a preexisting Ldif file, use the `LDIFINIT` environment variable to populate the directory at start using a -v mount:
```
docker run -d -p 10389:10389 --name my-ldap-ds -v <path/to/dir/where/your/ldif/is>:/ldif -e LDIFINIT=/ldif/my-file.ldif yvnicolas/apacheds
```

Open a console
```
docker logs -f my-ldap-ds
```

Stop the server
```
docker stop my-ldap-ds
```

## Additionnal informations

The initds.sh script, used as Entrypoint will check whether the /var/lib/apacheds/default has already something running by checking that the run/apacheds-default.pid files exists (typical case when a container has been stopped previously either purposedly either because of a reboot of the underlying server. If existing, the pid file will be deleted.

This enables the directory to restart gracefully and enables to use `docker stop` and `docker start` on the container.

Setting up the password with an environment variable is not ideally secure as the password will allways be readable by someone who
has access to the machine on which the container runs. This is not recommended by docker anymore although used by official images like
`mysql`. It is suitable for development though and I have not found a clear best practice recommendations for alternatives. [docker engine  issue 13490](https://github.com/moby/moby/issues/13490) seems to be a good discussion on the subject.
