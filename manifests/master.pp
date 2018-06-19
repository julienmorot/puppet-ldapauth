class ldapauth::master(String $basedn = 'dc=domain,dc=tld', String $rootpw = 'notverysecret') inherits ldapauth::params {
    class { 'openldap::server': }
    openldap::server::database { $basedn:
        suffix => $basedn,
        ensure => present,
        rootdn => "cn=admin,${basedn}",
        rootpw => $rootpw,
    }
	openldap::server::schema { 'cosine':
	    ensure  => present,
	    path    => "${ldapauth::params::slapdconfpath}/schema/cosine.schema",
	}
	openldap::server::schema { 'inetorgperson':
  	    ensure  => present,
	    path    => "${ldapauth::params::slapdconfpath}/schema/inetorgperson.schema",
	    require => Openldap::Server::Schema["cosine"],
	}
	openldap::server::schema { 'nis':
	    ensure  => present,
	    path    => "${ldapauth::params::slapdconfpath}/schema/nis.ldif",
	    require => Openldap::Server::Schema["inetorgperson"],
	}

    file { '/var/lib/ldap/accesslog':
        ensure => directory,
        owner => "openldap",
        group => "openldap",
    }

    file { '/var/lib/ldap/accesslog/DB_CONFIG':
        ensure => present,
        owner => "openldap",
        source => "puppet:///modules/${module_name}/DB_CONFIG",
        require => File['/var/lib/ldap/accesslog']
    }

    file { '/root/.ldap_defaults_ou.ldif':
        ensure  => file,
        content => template('ldapauth/defaults_ou.ldif.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0600',
        notify  => Exec['add_defaults_ou'],
    }
    exec { 'add_defaults_ou':
        command  => "ldapadd -c -x -D cn=admin,${basedn} -w ${rootpw} -f /root/.ldap_defaults_ou.ldif && touch /root/.ldap_defaults_ou.done",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        onlyif   => ['test -f /root/.ldap_defaults_ou.ldif'],
        unless   => ['test -f /root/.ldap_defaults_ou.done'],
    }




}
