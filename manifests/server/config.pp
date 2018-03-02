# See README.me for options.
class mysql::server::config (
  $options,
  $includedir,
  $root_group,
  $purge_conf_dir,
  $manage_config_file,
  $config_file,
) {

  File {
    owner  => 'root',
    group  => $root_group,
    mode   => '0400',
  }

  if $includedir != '' {
    file { $includedir:
      ensure  => directory,
      mode    => '0755',
      recurse => $purge_conf_dir,
      purge   => $purge_conf_dir,
    }

    # on some systems this is /etc/my.cnf.d, while Debian has /etc/mysql/conf.d and FreeBSD something in /usr/local. For the latter systems,
    # managing this basedir is also required, to have it available before the package is installed.
    $includeparentdir = mysql_dirname($includedir)
    if $includeparentdir != '/' and $includeparentdir != '/etc' {
      file { $includeparentdir:
        ensure => directory,
        mode   => '0755',
      }
    }
  }

  if $manage_config_file  {
    file { 'mysql-config-file':
      path                    => $config_file,
      content                 => template('mysql/my.cnf.erb'),
      mode                    => '0644',
      selinux_ignore_defaults => true,
    }

    # on mariadb systems, $includedir is not defined, but /etc/my.cnf.d has
    # to be managed to place the server.cnf there
    $configparentdir = mysql_dirname($config_file)
    if $configparentdir != '/' and $configparentdir != '/etc' and $configparentdir
        != $includedir and $configparentdir != mysql_dirname($includedir) {
      file { $configparentdir:
        ensure => directory,
        mode   => '0755',
      }
    }
  }

  if $options['mysqld']['ssl-disable'] {
    notify {'ssl-disable':
      message =>'Disabling SSL is evil! You should never ever do this except
                if you are forced to use a mysql version compiled without SSL support'
    }
  }
}
