class ldapauth::client (String $basedn = 'dc=domain,dc=tld', Array $servers = ['ldap:://srv1', 'ldap://srv2']) inherits ldapauth::params { 

	$pkgdep = ['libpam-modules']
	Package { $pkgdep: ensure => present }

    File { "libnss-ldap.preseed":
        path    => "/var/cache/debconf/libnss-ldap.preseed",
        ensure  => "file",
        mode    => "644",
        owner   => "root",
        group   => "root",
        content => template("${module_name}/libnss-ldap.preseed.erb"),
    }

    Package { "libnss-ldap":
        ensure			=> "present",
        responsefile	=> "/var/cache/debconf/libnss-ldap.preseed",
        require			=> File["libnss-ldap.preseed"],
        notify			=> Exec["libnss_ldap"],
    }

    Service { "libnss-ldap":
        ensure      => "running",
    }

    Exec {"libnss_ldap":
        command		=> "auth-client-config -t nss -p lac_ldap && touch /root/${module_name}/.lac_ldap.done",
        creates		=> "/etc/init.d/libnss-ldap",
        unless		=> ["test -f /root/${module_name}/.lac_ldap.done"],
        require		=> Package["libnss-ldap"],
    }

    File { "pam_mkhomedir":
        path    => "/usr/share/pam-configs/pam_mkhomedir",
        ensure  => "file",
        mode    => "644",
        owner   => "root",
        group   => "root",
        source  => "puppet:///modules/${module_name}/pam_mkhomedir",
    }

    Exec {"pam_mkhomedir":
        command     => "pam-auth-update && touch /root/${module_name}/.pam_mkhomedir.done",
        unless      => ["test -f /root/${module_name}/.pam_mkhomedir.done"],
        require     => Package["libpam-modules"],
    }

    file_line { "security_localgroup":
        path    => "/etc/security/group.conf",
        ensure  => "present",
        line    => "*;*;*;Al0000-2400;users,operator,cdrom",
        append_on_no_match => true
    }

    File { "pam_localgroup":
        path    => "/usr/share/pam-configs/pam_localgroup",
        ensure  => "file",
        mode    => "644",
        owner   => "root",
        group   => "root",
        source  => "puppet:///modules/${module_name}/pam_localgroup",
    }

    Exec {"pam_localgroup":
        command => "pam-auth-update && touch /root/${module_name}/.pam_localgroup.done",
        unless  => ["test -f /root/${module_name}/.pam_localgroup.done"],
        require => Package["libpam-modules"],
    }

}
