class ldapauth::params {
    
    Exec { path => ['/bin','/sbin','/usr/bin','/usr/sbin']}

    File { "/root/${module_name}":
        ensure  => directory,
        owner   => "root",
        group   => "root",
        mode    => "700",
    }

}
