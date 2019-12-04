class ldapauth::slave(String $basedn, String $rootpwd, String $ldapmaster, String $ldapreplpwd) {

    $pkgdep = ['ldap-utils']
    package { $pkgdep: ensure => present }

    Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

    File { "/root/.${module_name}":
        ensure  => directory,
        owner   => "root",
        group   => "root",
        mode    => "700",
    }

    File { "slapd.preseed":
        path    => "/var/cache/debconf/slapd.preseed",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/slapd.preseed.erb"),
    }

    Package { "slapd":
        ensure => "installed",
        responsefile => "/var/cache/debconf/slapd.preseed",
        require => File["slapd.preseed"]
    }

    File { "consumer.ldif":
        path    => "/root/.${module_name}/consumer.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/consumer.ldif.erb"),
    }

    Exec { 'add_consumer':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/.${module_name}/consumer.ldif && touch /root/.${module_name}/consumer.ldif.done",
        cwd      => "/root",
        provider => shell,
        unless   => ["test -f /root/.${module_name}/consumer.ldif.done"],
        require  => [ Package["slapd"],File["consumer.ldif"] ]
    }

    class {'ldapauth::ppolicyslave':
        basedn          => $basedn,
        rootpwd         => $rootpwd,
    }

    include ldapauth::overlay
    include ldapauth::service

}
