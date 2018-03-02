define mysql::server::resource::instance (
  $config_file             = $mysql::params::config_file,
  $includedir              = $mysql::params::includedir,
  $manage_config_file      = $mysql::params::manage_config_file,
  $install_options         = undef,
  $install_secret_file     = $mysql::params::install_secret_file,
  $override_options        = {},
  $purge_conf_dir          = $mysql::params::purge_conf_dir,
  $remove_default_accounts = false,
  $restart                 = $mysql::params::restart,
  $root_group              = $mysql::params::root_group,
  $mysql_group             = $mysql::params::mysql_group,
  $root_password           = $mysql::params::root_password,
  $service_enabled         = $mysql::params::server_service_enabled,
  $service_manage          = $mysql::params::server_service_manage,
  $service_name            = $mysql::params::servier_service_name,
  $service_provider        = $mysql::params::server_service_provider,
  $create_root_user        = $mysql::params::create_root_user,
  $create_root_my_cnf      = $mysql::params::create_root_my_cnf,
  $users                   = {},
  $grants                  = {},
  $databases               = {},

  # Deprecated parameters
  $enabled                 = undef,
  $manage_service          = undef,
  $old_root_password       = undef
) {

  # Deprecated parameters.
  if $enabled {
    crit('This parameter has been renamed to service_enabled.')
    $real_service_enabled = $enabled
  } else {
    $real_service_enabled = $service_enabled
  }
  if $manage_service {
    crit('This parameter has been renamed to service_manage.')
    $real_service_manage = $manage_service
  } else {
    $real_service_manage = $service_manage
  }
  if $old_root_password {
    warning(translate('The `old_root_password` attribute is no longer used and will be removed in a future release.'))
  }

  # Create a merged together set of options.  Rightmost hashes win over left.
  $options = mysql_deepmerge($mysql::params::default_options, $override_options)

  Class['mysql::server::root_password'] -> Mysql::Db <| |>


  include '::mysql::server::config'
  include '::mysql::server::binarylog'
  include '::mysql::server::installdb'
  include '::mysql::server::service'
  include '::mysql::server::root_password'
  include '::mysql::server::providers'

  class {'::mysql::server::config':
    options             => $options,
    includedir          => $includedir,
    root_group          => $root_group,
    purge_conf_dir      => $purge_conf_dir,
    manage_config_file  => $manage_config_file,
    config_file         => $config_file
  }

  class {'::mysql::server::binarylog':
    options   => $options,
    binarylog => $binarylog
  }

  class {'::mysql::server::installdb':
    options             => $options,
    manage_config_file  => $manage_config_file,
    config_file         => $config_file,
    mysql_group         => $mysql_group
  }

  class {'::mysql::server::service':
    options               => $options,
    real_service_manage   => $real_service_manage,
    real_service_enabled  => $real_service_enabled,
    service_name          => $service_name,
    service_provider      => $service_provider,
    override_options      => $override_options,
    manage_config_file    => $manage_config_file
  }

  class {'::mysql::server::root_password':
    options             => $options,
    secret_file         => $secret_file,
    create_root_user    => $create_root_user,
    create_root_my_cnf  => $create_root_my_cnf,
    root_password       => $root_password
  }

  class {'::mysql::server::providers':
    users     => $users,
    grants    => $grants,
    databases => $databases
  }

  if $remove_default_accounts {
    class { '::mysql::server::account_security':
      require => Anchor['mysql::server::end'],
    }
  }

  if $remove_default_accounts {
    class { '::mysql::server::account_security':
      require => Anchor['mysql::server::end'],
    }
  }

  anchor { 'mysql::server::start': }
  anchor { 'mysql::server::end': }

  if $restart {
    Class['mysql::server::config']
    ~> Class['mysql::server::service']
  }

  Anchor['mysql::server::start']
  -> Class['mysql::server::config']
  -> Class['mysql::server::install']
  -> Class['mysql::server::binarylog']
  -> Class['mysql::server::installdb']
  -> Class['mysql::server::service']
  -> Class['mysql::server::root_password']
  -> Class['mysql::server::providers']
  -> Anchor['mysql::server::end']
}
