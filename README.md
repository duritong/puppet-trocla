# trocla

This is the puppet module to manage a trocla installation on the puppet
master. It also, provides the necessary function to query trocla from puppet.

To get a quick start you might be interested in using the `trocla::yaml` class
on your master. This will install trocla and setup it using the default YAML
storage backend for your master. There is no need to configure anything on the
clients if you do not want to use trocla on the clients itself.

If you want to do your own very custom setup, you should look into the other
classes.

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

    trocla_set(KEY, FORMAT,PASSWORD)

This will set the passed password for the key/format pair and return it
as well. This is mainly interesting if you want to migrate existing manifests
with plenty of passwords in it to trocla.

## Other classes

### trocla::config

This is a class that manages a trocla configuration. You might use this
one if you do not use the default yaml setup.

### trocla::master

This class manages the installation of trocla itself. It will not configure
trocla, it will just install the necessary packages.

## Moar

RTFC and for more information about trocla visit: https://github.com/duritong/trocla
