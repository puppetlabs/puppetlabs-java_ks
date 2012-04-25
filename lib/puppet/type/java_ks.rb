module Puppet
  newtype(:java_ks) do
    @doc = 'Manages entries in a java keystore.'

    ensurable do

      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end

      newvalue(:latest) do
        if provider.exists?
          provider.update
        else
          provider.create
        end
      end

      def insync?(is)

        @should.each do |should|
          case should
          when :present
            return true if is == :present
          when :absent
            return true if is == :absent
          when :latest
            unless is == :absent
              return true if provider.latest == provider.current
            end
          end
        end

        false
      end

      defaultto :present
    end

    newparam(:name) do
      desc ''
      isnamevar
    end

    newparam(:target) do
      desc ''
      isnamevar
    end

    newparam(:certificate) do
      desc ''
    end

    newparam(:private_key) do
      desc ''
    end

    newparam(:password) do
      desc ''
    end

    newparam(:trustcacerts) do
      desc ''
    end

    def self.title_patterns
      identity = lambda {|x| x}
      [[
        /^(.*):(.*)$/,
       [
         [ :name, identity ],
         [ :target, identity ]
       ]
      ]]
    end
  end
end
