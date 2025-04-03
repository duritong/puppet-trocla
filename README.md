# trocla

This is the puppet module to manage a trocla installation on the puppet
master. It also, provides the necessary function to query trocla from puppet.

To get a quick start you might be interested in using the `trocla::yaml` class
on your master. This will install trocla and setup it using the default YAML
storage backend for your master. There is no need to configure anything on the
clients if you do not want to use trocla on the clients itself.

If you want to do your own very custom setup, you should look into the other
classes.

## Compatibility

* Version 0.2.2 of this module is for version 0.2.2 of trocla.

## Functions

### trocla


Usage:

    trocla(KEY, FORMAT, [optional options])

This is the main function you will use. This is similar to a

    trocla create foo FORMAT

on the cli. This means, that *if* a password for this key and format
exists, it will return this one, otherwise will create one automatically
and return the generated password. So you might want to do something like:

    user{'foobar':
      password => trocla('user_foobar','plain')
    }

If you want to pass down encrypted passwords, you might use:


    user{'foobar':
      password => trocla('user_foobar','sha512crypt')
    }

As descriped further in trocla's docs.

The optional options, can be used to pass options to the format, like
overriding the default length for passwords that are being created:

    user{'foobar':
      password => trocla('user_foobar','sha512crypt','length: 32')
    }

### trocla_get

Usage:

    trocla_get(KEY, FORMAT)

This will return the value of the passed key and format. If nothing is
found an error will be raised. This is interesting if you want do not
want to autogenerate a password and rather be sure that it's already
existing in trocla's database.

### trocla_set

Usage:

    trocla_set(KEY, PASSWORD, FORMAT)

This will set the passed password for the key/format pair and return it
as well. This is mainly interesting if you want to migrate existing manifests
with plenty of passwords in it to trocla. 

Note that the `FORMAT`, in this context, is the format of the
`PASSWORD` itself: it will not reencode it unless you pass a second
argument, for example:

    trocla_set('admin', 'test', 'plain')

... will return the string "test" but this:

    trocla_set('admin', 'test', 'plain', 'bcrypt')

... will return a bcrypt-hashed password.

## Hiera backend

Trocla can also be integrated into [Hiera](https://docs.puppetlabs.com/hiera/).

For previous hiera versions (<= 3) you might want to use ZeroPointEnergy's [hiera-backend](https://github.com/ZeroPointEnergy/hiera-backend-trocla).
Simply `include trocla::master::hiera` to make that backend available. This backend also works
with newer hiera releases, but only for a global hiera level.

For hiera >= 5, there is a custom hiera backend using a puppet lookup function shipped with
this module.

It ships with the same feature set as ZeroPointEnergy's [hiera-backend](https://github.com/ZeroPointEnergy/hiera-backend-trocla), but uses
the modern hiera interfaces, so it can also be used in per environment.

Configuration is straight forward, by adding the following hierarchy entry:

```
:hierarchy:
  - name: trocla
    lookup_key: trocla_lookup_key
    options:
      trocla_hierarchy:
        - hosts/%{facts.fqdn}
        - roles/%{::role}
        - defaults
      config: /etc/puppetlabs/puppet/troclarc.yaml
```

Important are the options:

* trocla_hierarchy: Defines the inner-hierarchy for the trocla hierarchy level. Usually, this might match your common hiera-hierarchy.
* config: A path to a trocla hierarchy, defining any further options.

There are two different methods to lookup a password in trocla. trocla_lookup and trocla_hierarchy

### trocla_lookup

trocla_lookup will simply lookup the password for a specified key and completely ignore
the hierarchy defined in the hiera configuration. If the password does not exist it will
create one.

The trocla hiera backend will resolve all the variables which start with "trocla_lookup::"

The second part of the variable is used to describe the format, the last part is the variable
to lookup in trocla.

    trocla_lookup::format::myvar

You can use the backend via interpolation tokens like this:

    myapp::database::password: "%{hiera('trocla_lookup::plain::myapp_mysql_password')}"

    mysql::server::users:
      'someuser@localhost':
          ensure: 'present'
          password_hash: "%{hiera('trocla_lookup::mysql::myapp_mysql_password')}"

### trocla_hierarchy

trocla_hierarchy will lookup the key in the hierarchy defined in your hiera configuration.
It will simply prefix all the variables with 'hiera/source/key' where source is one of
the interpolated strings defined in the hierarchy section.

It will try to find a password on every level in your hierarchy first. After that it will
create a password on the first hierarchy level by default. You can overwrite the level it
should create the password with the key 'order_override' in the trocla_options hash.

This is useful if you require different key for different nodes or on any other hierarchy level
you desire.

If you have a hierarchy defined like this:

    :trocla_hierarchy:
      - "nodes/%{::clientcert}"
      - "roles/%{::role}"
      - defaults

And you want to create a different password on the roles level, so that nodes within the
same role will get the same password you can set the 'order_override' like this:

    trocla_options::my_special_key:
      order_override: "roles/%{::role}"

The format to lookup a password this way is the same as with 'trocla_lookup':

    trocla_hierarchy::format::myvar

Here is how you would use that in hiera:

    mysql::server::root_password: "%{hiera('trocla_hierarchy::plain::mysql_root')}"

### options hash

Trocla takes a hash of options which provides information for the password creation. This
options can be set directly in hiera globally or for every key. You can also specify options
specifically for a password format. However, keep in mind that trocla will respect most of
the options only on the initial/first lookup, when the password is created. As most of the
options only apply for creating a password.

    trocla_options:
      length: 16
      some_other_global_setting: bla
      mysql:
        length: 32

    trocla_options::some_key:
      plain:
        length: 64
      order_override: "roles/%{::role}"

Some formats may require options to be set for creating passwords, like the
postgresql format. Check the trocla documentation for available options.

Through the options mechanism it is also possible to change the lookup key used for trocla.
This is especially interesting, if you want to pass 2 different options for the same key,
e.g. the render option. An example for that is to have trocla use the same key for 2 different
lookups, so that with the x509 format, once a certificate and once a key is returned.


    var_with_x509_cert: "%{hiera('trocla_lookup::x509::my_cert')}"
    trocla_options::my_cert:
      x509:
        CN: 'my-cert'
        render:
          certonly: true
    var_with_x509_key: "%{hiera('trocla_lookup::x509::my_cert_only_key')}"
    trocla_options::my_cert_only_key:
      x509:
        CN: 'my-cert'
        trocla_key: my_cert
        render:
          keyonly: true

This will lookup one trocla key: my_cert, but with different rendering options, so that
once we only get the certificat, while on the second lookup we get the private key.

## Other classes

### trocla::config

This is a class that manages a trocla configuration. You might use this
one if you do not use the default yaml setup.

### trocla::master

This class manages the installation of trocla itself. It will not configure
trocla, it will just install the necessary packages.

## Moar

RTFC and for more information about trocla visit: https://github.com/duritong/trocla
