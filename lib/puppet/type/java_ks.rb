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

        return false
      end

      defaultto :present
    end

    newparam(:name) do
      desc ''
      isnamevar

      munge do |value|
        value.downcase
      end
    end

    newparam(:target) do
      desc ''
      isnamevar
    end

    newparam(:certificate) do
      desc ''
      isrequired
    end

    newparam(:private_key) do
      desc ''
    end

    newparam(:password) do
      desc ''
      isrequired
    end

    newparam(:trustcacerts) do
      desc ''

      newvalues(:true, :false)

      defaultto :false
    end

    autorequire(:file) do
      auto_requires = []
      [:private_key, :certificate].each do |param|
        if @parameters.include?(param)
          auto_requires << @parameters[param].value
        end
      end
      if @parameters.include?(:target)
        auto_requires << ::File.dirname(@parameters[:target].value)
      end
      auto_requires
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
