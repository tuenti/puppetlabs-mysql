#
class mysql::server::service (
  $options,
  $real_service_manage,
  $real_service_enabled,
  $service_name,
  $service_provider,
  $override_options,
  $manage_config_file
) {

  if $real_service_manage {
    if $real_service_enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  } else {
    $service_ensure = undef
  }

  if $override_options and $override_options['mysqld']
      and $override_options['mysqld']['user'] {
    $mysqluser = $override_options['mysqld']['user']
  } else {
    $mysqluser = $options['mysqld']['user']
  }

  if $real_service_manage {
    service { 'mysqld':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $real_service_enabled,
      provider => $service_provider,
    }

    # only establish ordering between service and package if
    # we're managing the package.
    if $mysql::server::package_manage {
      Service['mysqld'] {
        require  => Package['mysql-server'],
      }
    }

    # only establish ordering between config file and service if
    # we're managing the config file.
    if $manage_config_file {
      File['mysql-config-file'] -> Service['mysqld']
    }

    if $override_options and $override_options['mysqld']
        and $override_options['mysqld']['socket'] {
      $mysqlsocket = $override_options['mysqld']['socket']
    } else {
      $mysqlsocket = $options['mysqld']['socket']
    }

    if $service_ensure != 'stopped' {
      exec { 'wait_for_mysql_socket_to_open':
        command   => "test -S ${mysqlsocket}",
        unless    => "test -S ${mysqlsocket}",
        tries     => '3',
        try_sleep => '10',
        require   => Service['mysqld'],
        path      => '/bin:/usr/bin',
      }
    }
  }
}
