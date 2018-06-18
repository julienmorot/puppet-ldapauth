class ldapauth::params {
  $slapdconfpath = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => '/etc/ldap',
    /(?i-mx:centos|fedora|redhat)/ => '/etc/openldap',
  }
}
