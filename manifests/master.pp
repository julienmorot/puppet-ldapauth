class ldapauth::master(String $basedn = 'dc=domain,dc=tld', String $rootpw = 'notverysecret') {
  class { 'openldap::server': }
  openldap::server::database { $basedn:
    suffix => $basedn,
    ensure => present,
    rootdn => "cn=admin,${basedn}",
    rootpw => $rootpw,
  }


}
