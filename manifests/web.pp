# == Class: koji::web
class koji::web (
  $koji_hubserver       = $koji::koji_hubserver,
  $koji_web_packages    = $koji::koji_web_packages,
  $koji_filesystem_base = $koji::koji_filesystem_base,
  $koji_web_secret      = $koji::koji_web_secret,
) inherits koji {

  validate_string($koji_hubserver)
  validate_array($koji_web_packages)
  validate_absolute_path($koji_filesystem_base)
  validate_string($koji_web_secret)

  ensure_packages($koji_web_packages)

  file {'/etc/httpd/conf.d/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    recurse => true,
    source  => 'puppet:///modules/koji/etc/httpd/koji-web/etc/httpd/conf.d/',
  }

  file {'/etc/httpd/conf.modules.d/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    recurse => true,
    source  => 'puppet:///modules/koji/etc/httpd/koji-web/etc/httpd/conf.modules.d/',
  }

  file {'/var/www/html/index.html':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/koji/var/www/html/index.html',
    require => Package[$koji_web_packages],
  }

  file {'/usr/share/koji-web/static/themes/':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    source  => 'puppet:///modules/koji/usr/share/koji-web/static/themes/',
    recurse => true,
    purge   => true,
    require => Package[$koji_web_packages],
  }

  file {'/etc/kojiweb/web.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('koji/etc/kojiweb/web.conf.erb'),
    notify  => Service['httpd'],
    require => Package[$koji_web_packages],
  }

  # For now we bundle CA with the web
  include koji::ca

}
