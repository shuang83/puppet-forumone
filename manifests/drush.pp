class forumone::drush ($version = '7.1.0') {
  $filename = "${version}.zip"

  include forumone::composer

  # Download drush
  exec { 'forumone::drush::download':
    command => "wget --directory-prefix=/opt -O ${filename} https://github.com/drush-ops/drush/archive/${filename}",
    cwd     => '/opt',
    path    => '/usr/bin',
    creates => "/opt/${filename}",
    timeout => 4800,
    require => Class['forumone::composer'],
  }

  # extract from the archive
  exec { 'forumone::drush::extract':
    command => "unzip -o /opt/${filename} -d /opt",
    path    => ["/bin", "/usr/bin"],
    require => Exec["forumone::drush::download"],
    creates => '/opt/drush-${version}/README.md',
  }

  file { "/opt/drush-${version}":
    ensure  => directory,
    owner   => 'vagrant',
    require => Exec['forumone::drush::extract']
  }

  file { "/opt/drush-${version}/lib":
    ensure  => directory,
    owner   => 'vagrant',
    require => File["/opt/drush-${version}"]
  }

  file { '/usr/local/bin/drush':
    ensure  => 'link',
    target  => "/opt/drush-${version}/drush",
    require => Exec['forumone::drush::extract']
  }

  exec { 'forumone::drush::composer':
    command => "composer install",
    cwd     => "/opt/drush-${version}",
    path    => ['/usr/bin', '/user/local/bin'],
    creates => "/opt/drush-${version}/vendor/bin/phpunit",
    require => [Exec["forumone::drush::extract"], Class['forumone::composer']],
    environment => ["COMPOSER_HOME=${::forumone::composer::home}", "HOME=${::forumone::composer::home}"],
    user    => $::forumone::composer::user,
  }
}
