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
	    path    => '${ldapauth::params::slapdconfpath}/schema/cosine.schema',
	}
	openldap::server::schema { 'inetorgperson':
  	    ensure  => present,
	    path    => '${ldapauth::params::slapdconfpath}/schema/inetorgperson.schema',
	    require => Openldap::Server::Schema["cosine"],
	}
	openldap::server::schema { 'nis':
	    ensure  => present,
	    path    => '${ldapauth::params::slapdconfpath}/schema/nis.ldif',
	    require => Openldap::Server::Schema["inetorgperson"],
	}

}
