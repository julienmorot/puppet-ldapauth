class ldapauth::client (String $basedn = 'dc=domain,dc=tld', Array $servers = ['ldap:://srv1', 'ldap://srv2']) inherits ldapauth::params { 
  class { 'openldap::client':
    base       => $basedn,
    uri        => $servers,
  }


}
