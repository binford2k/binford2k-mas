# Mac App Store package management

#### Table of Contents

1. [Overview](#overview)
1. [Setup](#setup)
1. [Limitations](#limitations)

## Overview

This is a barebones package provider for the Mac App Store. It's currently barely
functional, and doesn't even have the ability to install new packages by name.
But it and the project it depends on are a work in progress.

* https://github.com/argon/mas
* https://github.com/argon/mas/issues/9

```
Projects $ puppet resource package
package { '1Password':
  ensure => '443987910',
}
package { 'DaisyDisk':
  ensure => '411643860',
}
package { 'Dash':
  ensure => '458034879',
}
package { 'GarageBand':
  ensure => '682658836',
}
package { 'Keynote':
  ensure => '409183694',
}
package { 'Kindle':
  ensure => '405399194',
}
[... plus a whole pile of gems, etc ...]

Projects $ puppet resource package Dash
package { 'Dash':
  ensure => '458034879',
}
```

## Setup

This comes with a utility class to install the `mas` tool using Homebrew and
(optionally) to log into an account. This isn't required if you're managing this
some other way, or prefer the end user to manage the logged in account manually.

*Warning:* including passwords in Puppet manifests means that they are visible in
the catalog and every report. You might consider using `binford2k/node_encrypt`
to mitigate that issue!

## Limitations

This is super early in development. The `mas` tool doesn't currently have the
ability to install new packages by name, so this provider cannot install new
packages, only manage the ones that exist on the system.

* https://github.com/argon/mas/issues/9

## Disclaimer

I take no liability for the use of this module. As this uses standard Ruby and
OpenSSL libraries, it should work anywhere Puppet itself does. I have not yet
validated on anything other than CentOS, though.

Contact
-------

binford2k@gmail.com

