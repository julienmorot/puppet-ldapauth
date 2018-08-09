class ldapauth::overlay inherits ldapauth::params {

	File { "memberof.ldif":
		path    => "/root/memberof.ldif",
		ensure  => file,
		mode    => "644",
		owner   => "root",
		group   => "root",
    	source 	=> "puppet:///modules/${module_name}/memberof.ldif",
  	}

    Exec { 'add_memberof':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/memberof.ldif && touch /root/.memberof.ldif.done",
        cwd      => "/root",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        unless   => ['test -f /root/.memberof.ldif.done'],
		require  => [ Package["slapd"],File["memberof.ldif"] ],
    }

    File { "refint.ldif":
        path    => "/root/refint.ldif",
        ensure  => file,
        mode    => "644",
        owner   => "root",
        group   => "root",
        source => "puppet:///modules/${module_name}/refint.ldif",
    }

    Exec { 'add_refint':
        command  => "ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /root/refint.ldif && touch /root/.refint.ldif.done",
        cwd      => "/root",
        path     => '/usr/bin:/usr/sbin:/bin:/sbin',
        provider => shell,
        unless   => ['test -f /root/.refint.ldif.done'],
		require  => [ Package["slapd"],File["refint.ldif"] ],
    }

}
