class ldapauth::master(String $basedn, String $rootpwd) {

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
        ensure       => "installed",
        responsefile => "/var/cache/debconf/slapd.preseed",
        require      => File["slapd.preseed"]
    }

    File { "/var/lib/ldap/accesslog":
        ensure  => directory,
        owner   => "openldap",
        group   => "openldap",
        mode    => "700",
        require => Package['slapd'],
    }

    File { "/var/lib/ldap/accesslog/DB_CONFIG":
        ensure => present,
        owner  => "openldap",
        group  => "openldap",
        mode   => "700",
        source => "puppet:///modules/${module_name}/DB_CONFIG",
        require => Package['slapd'],
    }

    File { "provider.ldif":
        path    => "/root/.${module_name}/provider.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/provider.ldif.erb"),
    }

    Exec { 'add_provider':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/.${module_name}/provider.ldif && touch /root/.${module_name}/provider.ldif.done",
        cwd      => "/root",
        provider => shell,
        unless   => ["test -f /root/.${module_name}/provider.ldif.done"],
        require  => [ Package["slapd"],File["provider.ldif"] ],
    }

    class {'ldapauth::ppolicy':
        basedn          => $basedn,
        rootpwd         => $rootpwd,
    }

    include ldapauth::overlay
    include ldapauth::service

    File { "base_dit.ldif":
        path    => "/root/.${module_name}/base_dit.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/base_dit.ldif.erb"),
    }

    Exec { 'add_base_dit':
        command  => "ldapadd -x -w ${rootpwd} -D cn=admin,${basedn} -H ldap:// -f /root/.${module_name}/base_dit.ldif && touch /root/.${module_name}/base_dit.ldif.done",
        cwd      => "/root",
        provider => shell,
        unless   => ["test -f /root/.${module_name}/base_dit.ldif.done"],
        require  => [ Package["slapd"],File["base_dit.ldif"] ],
    }

}
