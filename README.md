# trocla

This is the puppet module to manage a trocla installation on the puppet
master. It also, provides the necessary function to query trocla from puppet.

To get a quick start you might be interested in using the `trocla::yaml` class
on your master. This will install trocla and setup it using the default YAML
storage backend for your master. There is no need to configure anything on the
clients if you do not want to use trocla on the clients itself.

If you want to do your own very custom setup, you should look into the other
classes.

## Other classes

### trocla::config

This is a class that manages a trocla configuration. You might use this
one if you do not use the default yaml setup.

### trocla::master

This class manages the installation of trocla itself. It will not configure
trocla, it will just install the necessary packages.

### trocla::dependencies

This class is used to install the necessary dependencies if you are not using
the rubygems module. See dependencies below for more information.

## Dependencies

By default this module requires the rubygems puppet module. If you want to
use trocla with ruby enterprise, you might be also interested in the
ruby_enterprise module.
If the dependencies should be managed internally, set: install_deps to `true`.

You can also use this module with 0 dependencies by setting the option
use_rubygems to false.

## Moar

RTFC and for more information about trocla visit: https://github.com/duritong/trocla
