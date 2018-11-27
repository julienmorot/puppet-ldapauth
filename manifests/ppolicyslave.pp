class ldapauth::ppolicyslave(String $basedn = $domain, String $rootpwd = 'notverysecret') inherits ldapauth::params {

    Exec { "add_ppolicy_schema":
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f  /etc/ldap/schema/ppolicy.ldif && touch /root/.${module_name}/ppolicy.schema.ldif.done",
        cwd      => "/root",
        path     => "/usr/bin:/usr/sbin:/bin:/sbin",
        provider => shell,
        unless   => ["test -f /root/.${module_name}/ppolicy.schema.ldif.done"],
        require  => [Package["slapd"],File["ppolicy.ldif"]],
    }

    File { "ppolicy.ldif":
        path    => "/root/.${module_name}/ppolicy.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/ppolicy.ldif.erb"),
    }

    Exec { "add_ppolicy":
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/.${module_name}/ppolicy.ldif && touch /root/.${module_name}/ppolicy.ldif.done",
        cwd      => "/root",
        path     => "/usr/bin:/usr/sbin:/bin:/sbin",
        provider => shell,
        unless   => ["test -f /root/.${module_name}/ppolicy.ldif.done"],
        require  => [Exec["add_ppolicy_schema"],Package["slapd"],File["ppolicy.ldif"]],
    }

}

