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
        ensure => "installed",
        responsefile => "/var/cache/debconf/slapd.preseed",
        require => File["slapd.preseed"]
    }

	File { "/var/lib/ldap/accesslog":
		ensure => directory,
		owner  => "openldap",
		group  => "openldap",
		mode   => "700",
	}

    File { "/var/lib/ldap/accesslog/DB_CONFIG":
        ensure => present,
        owner  => "openldap",
        group  => "openldap",
        mode   => "700",
		source => "puppet:///modules/${module_name}/DB_CONFIG"
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
    }




}
