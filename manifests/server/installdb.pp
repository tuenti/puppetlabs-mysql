#
class mysql::server::installdb (
  options,
  config_file,
  manage_config_file,
  mysql_group
) {

  if $mysql::server::package_manage {

    # Build the initial databases.
    $mysqluser = $options['mysqld']['user']
    $datadir = $options['mysqld']['datadir']
    $basedir = $options['mysqld']['basedir']
    $config_file = $config_file
    $log_error = $options['mysqld']['log-error']

    if $manage_config_file and $config_file != $mysql::params::config_file {
      $_config_file=$config_file
    } else {
      $_config_file=undef
    }

  if $options['mysqld']['log-error'] {
    file { $options['mysqld']['log-error']:
      ensure  => present,
      owner   => $mysqluser,
      group   => $mysql_group,
      mode    => 'u+rw',
      require => Mysql_datadir[ $datadir ],
    }
  }

    mysql_datadir { $datadir:
      ensure              => 'present',
      datadir             => $datadir,
      basedir             => $basedir,
      user                => $mysqluser,
      log_error           => $log_error,
      defaults_extra_file => $_config_file,
    }

    if $mysql::server::restart {
      Mysql_datadir[$datadir] {
        notify => Class['mysql::server::service'],
      }
    }
  }
}
