# Mac App Store package management

#### Table of Contents

1. [Overview](#overview)
1. [Setup](#setup)
1. [Limitations](#limitations)

## Overview

This is a barebones package provider for the Mac App Store. It's still fairly
early in development, but should work for most things. Be aware that the Mac
App Store is intended for interactive use, so you'll likely get popup dialogs
requesting your iCloud password unless you save it for free items.

This uses the `mas` command-line tool:

* https://github.com/argon/mas

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

This can take standard `ensure` parameters and can also accept App IDs. This is
a bit weird, and I might refactor it sometime. But it seemed like the most
reasonable way to handle the unusual versioning scheme used by the Mac App Store.
This allows you to install apps that don't have unique names.

``` Puppet
package { 'Dash':
  ensure   => present,
  provider => mas,
}

package { 'Kindle':
  ensure   => '405399194',
  provider => mas,
}

package { 'Twitter':
  ensure   => latest,
  provider => mas,
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

* This is super early in development.
* Installing by name will only work when the App Store has only a single app by
  that name. Otherwise, you'll need to use the app ID.
* You cannot upgrade a single package. Instead, it will upgrade all outdated
  packages. This is a limitation of the `mas` tool.
* You can only install the latest version of any app.
* You may see popup dialogs requesting App Store logins. Choose to save your
  password for free apps to see this dialog less.

## Disclaimer

I take no liability for the use of this module.

Contact
-------

binford2k@gmail.com

