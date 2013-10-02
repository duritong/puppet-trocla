# Class: trocla::master::ree
#
# This module manages the necessary things for trocla on a master for
# RubyEnterprise installation.
#
# [Remember: No empty lines between comments and class definition]
class trocla::master::ree {

  require ruby_enterprise::gems::moneta
  require ruby_enterprise::gems::highline

  ruby_enterprise::gem{'trocla': }
}
