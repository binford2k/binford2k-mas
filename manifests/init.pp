# == Class: mas
#
# Just installs the `mas` binary. This is not needed if you install it by hand.
#
class mas (
  $account  = undef,
  $password = undef,
  $secure   = true,
) {
  Exec {
    path => '/bin:/usr/bin:/usr/local/bin:/opt/puppetlabs/bin:',
  }

  if $::osfamily == 'Darwin' {
    exec { 'brew install argon/mas/mas':
      unless => 'mas version',
      onlyif => 'brew --version',
    }

    if $password {
      # node_encrypt works in masterless only with additional configuration.
      if $secure {
        $secret = node_encrypt($password)
        exec { 'mas account login':
          command     => "mas signin ${account} '\$(puppet node decrypt --env SECRET)'",
          unless      => 'mas account',
          environment => "SECRET=${secret}",
          require     => Exec['brew install argon/mas/mas'],
        }
        redact('password')
      }
      else {
        exec { 'mas account login':
          command     => "mas signin ${account} '${password}'",
          unless      => 'mas account',
          require     => Exec['brew install argon/mas/mas'],
        }
      }
    }
  }
  else {
    fail('The Mac App Store only runs on OS X machines.')
  }

}
