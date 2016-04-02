#package { 'Kindle':
#  ensure   => present,
#  provider => mas,
#}

#package { 'Kindle':
#  ensure   => '405399194',
#  provider => mas,
#}

package { 'Kindle':
  ensure   => present,
  provider => mas,
}

