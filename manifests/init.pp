# == Class: mas
#
# Just installs the `mas` binary. This is not needed if you install it by hand.
#
class mas (
  $account  = undef,
  $password = undef,
) {
  Exec {
    path => '/bin:/usr/bin:/usr/local/bin',
  }

  if $::osfamily == 'Darwin' {
    exec { 'brew install argon/mas/mas':
      unless => 'mas version',
      onlyif => 'brew --version',
    }

    if $password {
      exec { "mas signin ${account} '${password}'":
        unless  => 'mas account',
        require => Exec['brew install argon/mas/mas'],
      }
    }
  }
  else {
    fail('The Mac App Store only runs on OS X machines.')
  }

}
