class ldapauth::slave(String $basedn = $domain, String $rootpwd = 'notverysecret', String $ldapmaster, String $ldapreplpwd = 'notverysecret') inherits ldapauth::params {

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

    File { "consumer.ldif":
        path    => "/root/${module_name}/consumer.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/consumer.ldif.erb"),
    }

    Exec { 'add_consumer':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/${module_name}/consumer.ldif && touch /root/${module_name}/.consumer.ldif.done",
        cwd      => "/root",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        unless   => ['test -f /root/${module_name}/.consumer.ldif.done'],
		require  => [ Package["slapd"],File["consumer.ldif"] ]
    }

	include ldapauth::overlay
	include ldapauth::service

}
