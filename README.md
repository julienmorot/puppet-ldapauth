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

Start with a one- or two-sentence summary of what the module does and/or what
problem it solves. This is your 30-second elevator pitch for your module.
Consider including OS/Puppet version it works with.

You can give more descriptive information in a second paragraph. This paragraph
should answer the questions: "What does this module *do*?" and "Why would I use
it?" If your module has a range of functionality (installation, configuration,
management, etc.), this is the time to mention it.

## Setup

### What ldapauth affects **OPTIONAL**

This module tends to provide ldap authentication :
- Master LDAP Server
- Slave LDAP Server
- Client configuration

### Setup Requirements **OPTIONAL**

Require https://github.com/camptocamp/puppet-openldap

### Beginning with ldapauth

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage
  class {'ldapauth::master':
    basedn => 'dc=morot,dc=fr',
    rootpw => 'yousecretpassword',
  }

  class {'ldapauth::client':
    basedn          => 'dc=morot,dc=fr',
    servers         => ['master.int.morot.fr', 'slave.int.morot.fr']
  }



## Limitations

A lot

