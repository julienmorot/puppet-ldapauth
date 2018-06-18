class ldapauth::service inherits ldapauth {

  service { 'slapd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require => Package['slapd'],
  }

}
