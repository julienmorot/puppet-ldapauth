# ldapauth

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ldapauth](#setup)
    * [What ldapauth affects](#what-ldapauth-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ldapauth](#beginning-with-ldapauth)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module aims to provide a framework to manage one LDAP master and one slave 
designed to perform users authentication.
Start with a one- or two-sentence summary of what the module does and/or what
problem it solves. This is your 30-second elevator pitch for your module.
Consider including OS/Puppet version it works with.

You can give more descriptive information in a second paragraph. This paragraph
should answer the questions: "What does this module *do*?" and "Why would I use
it?" If your module has a range of functionality (installation, configuration,
management, etc.), this is the time to mention it.

## Setup

### What ldapauth affects

This module tends to provide ldap authentication :
- Master LDAP Server
- Slave LDAP Server for one server
- Client configuration
- PasswordPolicy support

### Setup Requirements

Ubuntu server 16.04

## Usage
A master LDAP server :

```
node 'master' {
    include ldapauth::master
}
```

Then configure Hiera, for example :

/etc/puppetlabs/code/environments/production/data/common.yaml

```
---
ldapauth::master::basedn: dc=int,dc=morot,dc=fr
ldapauth::master::rootpwd: ldappwd
```

A slave LDAP server :

```
node 'slave' {
    include ldapauth::slave
}
```

Then configure Hiera, for example :

/etc/puppetlabs/code/environments/production/data/common.yaml

```
---
ldapauth::slave::basedn: dc=int,dc=morot,dc=fr
ldapauth::slave::rootpwd: ldappwd
ldapauth::slave::ldapmaster: master.int.morot.fr
ldapauth::slave::ldapreplpwd: ldappwd
```


A client authenticationg with PAM againts your LDAP servers :

```
node 'client' {
    include ldapauth::client
}
```

Then configure Hiera, for example :

/etc/puppetlabs/code/environments/production/data/common.yaml

```
---
ldapauth::client::basedn: dc=int,dc=morot,dc=fr
ldapauth::client::servers:
  - master.int.morot.fr
  - slave.int.morot.fr
```

Example for user and group definition :

```
dn: uid=john.rambo,ou=People,dc=int,dc=morot,dc=fr
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: john.rambo
cn: John Rambo
givenName: John
sn: Rambo
loginShell: /bin/bash
homeDirectory: /home/john.rambo
uidNumber: 10000
gidNumber: 10000
userPassword: {SSHA}WGtab5+9lecj8SGsdUq17TwVRrI30LuK

ldapadd -x -w ldappwd -D cn=admin,dc=int,dc=morot,dc=fr -H ldap:// -f usertemplate.ldif

dn: cn=LDAPUsers,ou=Groups,dc=int,dc=morot,dc=fr
objectClass: posixGroup
ObjectClass: top
cn: LDAPUsers
gidNumber: 10000

ldapadd -x -w ldappwd -D cn=admin,dc=int,dc=morot,dc=fr -H ldap:// -f grouptemplate.ldif
```


## Limitations

Only one slave
