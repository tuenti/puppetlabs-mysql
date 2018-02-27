# Class: mysql::server:  See README.md for documentation.
class mysql::server (
  $instances               = $mysql::params::instances,
  $package_ensure          = $mysql::params::server_package_ensure,
  $package_manage          = $mysql::params::server_package_manage,
  $package_name            = $mysql::params::server_package_name,
  $service_provider        = $mysql::params::server_service_provider,

) inherits mysql::params {

  include '::mysql::server::install'

  create_resources('mysql::server::resource::instance', $instance)
}
