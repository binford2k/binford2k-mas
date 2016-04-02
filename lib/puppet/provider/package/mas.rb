require 'puppet/provider/package'
require 'puppet/network/http_pool'

Puppet::Type.type(:package).provide(:mas, :parent => Puppet::Provider::Package) do
  desc "Manage packages from the Mac App Store"

  # It's only sort of versionable, but we need this in order to reuse the ID as a version
  has_feature :versionable

  confine  :osfamily => :darwin
  commands :mas      => '/usr/local/bin/mas'

  self::MAS_REGEX     = /^(\d+) (\S+)$/
  self::ITUNES_SERVER = 'itunes.apple.com'
  self::ITUNES_PORT   = 443
  self::ITUNES_SEARCH = '/search?entity=macSoftware&attribute=allTrackTerm&term='

  def self.instances
    self.mas_list
  end

  def install
    Puppet.debug "Installing #{@resource[:name]}"
    if [:present, :installed, :latest].include? @resource[:ensure]
      mas('install', mas_app_id)
    else
      mas('install', @resource[:ensure])
    end
  end

  # Find the fully versioned package name and the version alone.
  def query
    Puppet.debug "Querying #{@resource[:name]}"
    app = mas_app
    hash = {
      :provider => self.name,
      :ensure   => app.nil? ? :absent : app[:ensure],
    }

    @property_hash.update(hash)
    @property_hash.dup
  end

  def uninstall
    raise Puppet::Error, "Uninstalling packages is not yet supported."
  end

  def latest
    # if the app exists in the outdated list, then we should update it. But the
    # Mac App Store has a weird concept of versioning....
    outdated = Puppet::Type::Package::ProviderMas.mas_list('outdated').select { |pkg| pkg[:name] == @resource[:name]}
    outdated.empty? ? mas_app.properties[:ensure] : :outdated
  end

  # We cannot actually upgrade individual packages at this time. For now, I just
  # update all packages. This may violate the principle of least surprise, but i
  # expect that the tool will support individual updates someday.
  def update
    Puppet.debug "Attempting to upgrade #{@resource[:name]}"
    install unless mas_app
    mas('upgrade')
  end

  def mas_app
    Puppet::Type::Package::ProviderMas.instances.select { |pkg| pkg.name == @resource[:name]}.first
  end

  def mas_app_id
    Puppet.debug "Retrieving the app ID for #{@resource[:name]} from the App Store."

    search = "#{Puppet::Type::Package::ProviderMas::ITUNES_SEARCH}#{@resource[:name]}"
    server = Puppet::Type::Package::ProviderMas::ITUNES_SERVER
    port   = Puppet::Type::Package::ProviderMas::ITUNES_PORT

    connection = Puppet::Network::HttpPool.http_instance(server, port)

    unless results = PSON.load(connection.request_get(search, {"Accept" => 'application/json'}).body)['results']
      raise "Error searching the iTunes Store for #{@resource[:name]}."
    end

    # discard all the irrelevant hits
    results.select! { |result| result['trackName'] == @resource[:name] }

    unless results.size == 1
      message  = "The Mac App Store has more than one package named '#{@resource[:name]}'.\n"
      message << "You should select the desired package by specifying its ID as the resource `ensure` value.\n\n"
      message << "Possible alternatives are:\n"
      results.each { |package| message << "\t* #{package['trackId']}: #{package['trackName']}" }
      raise message
    end

    results.first['trackId']
  end

  def self.mas_list(action = 'list')
    packages = []

    # list out all of the packages
    begin
      execpipe("#{command(:mas)} #{action}") { |process|
        # now turn each returned line into a package object
        process.each_line { |line|
          next unless line =~ self::MAS_REGEX
          hash = {
            :name     => $2,
            :ensure   => $1,
            :provider => self.name,
          }
          packages << new(hash)
        }
      }
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, 'Failed to list packages', $!.backtrace
    end

    packages
  end

end
