require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:mas, :parent => Puppet::Provider::Package) do
  desc "Manage packages from the Mac App Store"

  confine :osfamily => :darwin
  commands :mas => "/usr/local/bin/mas"

  def self.instances
    packages = []

    # list out all of the packages
    begin
      execpipe("#{command(:mas)} list") { |process|
        # now turn each returned line into a package object
        process.each_line { |line|
          next unless line =~ /^(\d+) (\S+)$/
          hash = {
            :name     => $2,
            :ensure   => $1,
            :provider => self.name,
          }
          packages << new(hash)
        }
      }
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Failed to list packages", $!.backtrace
    end

    packages
  end


  def install
    raise Puppet::Error, "Installing by package name is not yet supported.\nSee https://github.com/argon/mas/issues/9"
  end

  def query
    self.instances.select { |pkg| pkg[:name] == @resource[:name]}
  end

  def uninstall
    app = self.instances.select { |pkg| pkg[:name] == @resource[:name]}
    mas('uninstall', app[:ensure])
  end

  def latest
    packages = []
    # list out all of the packages
    begin
      execpipe("#{command(:mas)} outdated") { |process|
        # now turn each returned line into a package object
        process.each_line { |line|
          next unless line =~ /^(\d+) (\S+)$/
          hash = {
            :name  => $2,
            :appid => $1,
          }
          packages << new(hash)
        }
      }
    rescue Puppet::ExecutionFailure
      raise Puppet::Error, "Failed to list outdated packages", $!.backtrace
    end

    app = packages.select { |pkg| pkg[:name] == @resource[:name]}.first
    app.nil? ? :present : app[:appid]
  end

  def update
    app = self.instances.select { |pkg| pkg[:name] == @resource[:name]}
    mas('update', app[:ensure])
  end
end
