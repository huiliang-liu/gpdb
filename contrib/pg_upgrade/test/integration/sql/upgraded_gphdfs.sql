SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcatupdate, rolcanlogin, rolreplication, rolconnlimit, rolpassword, rolvaliduntil, rolconfig, rolcreaterextgpfd, rolcreaterexthttp, rolcreatewextgpfd FROM pg_roles WHERE rolname='gphdfsuser';
