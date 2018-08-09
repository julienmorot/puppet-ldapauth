class ldapauth::master(String $basedn = $domain, String $rootpwd = 'notverysecret') inherits ldapauth::params {

    $pkgdep = ['ldap-utils']
    package { $pkgdep: ensure => present }

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
        path    => "/root/provider.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/provider.ldif.erb"),
    }

    Exec { 'add_provider':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/provider.ldif && touch /root/.provider.ldif.done",
        cwd      => "/root",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        unless   => ['test -f /root/.provider.ldif.done'],
		require  => [ Package["slapd"],File["provider.ldif"] ],
    }

	include ldapauth::overlay
	include ldapauth::service

	File { "base_dit.ldif":
        path    => "/root/base_dit.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/base_dit.ldif.erb"),
    }

    Exec { 'add_base_dit':
        command  => "ldapadd -x -w ${rootpwd} -D cn=admin,${basedn} -H ldap:// -f /root/base_dit.ldif && touch /root/.base_dit.ldif.done",
        cwd      => "/root",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        unless   => ['test -f /root/.base_dit.ldif.done'],
        require  => [ Package["slapd"],File["base_dit.ldif"] ],
    }

}
