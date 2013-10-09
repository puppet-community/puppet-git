# class: git
#   installs git from repoforge.
class git (
  $version = '1.7.11.1',
  $source  = 'http://pkgs.repoforge.org',
) {
  require 'epel'

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease {
    $release = "1.el${::lsbmajdistrelease}.rfx"
  } else {
    fail('Only RedHat family supported, and require redhat-lsb package or lsb module.')
  }

  $git_pkg      = "${source}/git/git-${version}-${release}.${::architecture}.rpm"
  $perl_git_pkg = "${source}/git/perl-Git-${version}-${release}.${::architecture}.rpm"

  # Work around dependency problem between the two package. We must uninstall first.
  exec { 'remove_git':
    command   => 'yum remove -y git git-Perl',
    path      => $::path,
    logoutput => 'on_failure',
    unless    => "[ \"$(rpm -qa --qf %{VERSION} git)\" == '${version}' ] || [ \"$(rpm -qa --qf %{VERSION} git)\" == '' ]",
  }

  ensure_packages(['perl-Error'])

  exec { 'install_git':
    command   => "yum install -y ${git_pkg} ${perl_git_pkg}",
    path      => $::path,
    logoutput => 'on_failure',
    unless    => "[ \"$(rpm -qa --qf %{VERSION} git)\" == '${version}' ]",
    require   => [
      Exec['remove_git'],
      Package['perl-Error'],
    ],
  }
}
