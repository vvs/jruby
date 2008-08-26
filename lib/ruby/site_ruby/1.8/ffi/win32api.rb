require 'ffi'

module Win32
  
  class API
    CONVENTION = JRuby::FFI::Platform::IS_WINDOWS ? :stdcall : :default
    SUFFIXES = $KCODE == 'UTF8' ? [ '', 'W', 'A' ] : [ '', 'A', 'W' ]
    TypeDefs = {
      'V' => :void,
      'S' => :string,
      'P' => :pointer,
      'I' => :int,
      'L' => :long,
    }
    def self.find_type(name)
      code = TypeDefs[name]
      raise TypeError, "Unable to resolve type '#{name}'" unless code
      return code
    end
    def self.map_types(spec)
      types = []
      for i in 0..(spec.length - 1)
        if spec[i].chr == 'V'
          return []
        end
        types[i] = self.find_type(spec.slice(i,1))
      end
      types
    end
    def self.create_invoker(lib, func, params, ret, convention)
      SUFFIXES.each { |suffix|
        begin
          return JRuby::FFI.create_invoker(lib, func.to_s + suffix, params, ret, convention)
        rescue FFI::NotFoundError => ex
        end
      }
      raise FFI::NotFoundError, "Could not locate #{func}"
    end
    def initialize(func, params, ret='L', lib='kernel32')
      @invoker = invoker = API.create_invoker(lib, func.to_s, API.map_types(params),
        API.map_types(ret)[0], CONVENTION)
      #
      # Attach the method as 'call', so it gets all the froody arity-splitting optimizations
      #
      mod = Module.new do invoker.attach(self, "call") end
      extend mod
    end
  end
end

beep = Win32::API.new("MessageBeep", 'L', 'L', 'user32')
2.times { beep.call(0) }

buf = 0.chr * 260
GetComputerName = Win32::API.new("GetComputerName", 'PP', 'L', 'kernel32')
ret = GetComputerName.call(buf, [buf.length].pack("V"))
puts "GetComputerName returned #{ret}"
puts "computer name=#{buf.strip}"
len = [buf.length].pack('V')
GetUserName = Win32::API.new("GetUserName", 'PP', 'I', 'advapi32')
ret = GetUserName.call(buf, len)
puts "GetUserName returned #{ret}"
puts "username=#{buf.strip}"
puts "len=#{len.unpack('V')}"
getcwd = Win32::API.new("GetCurrentDirectory", 'LP')
buf = 0.chr * 260
getcwd.call(buf.length, buf)
puts "current dir=#{buf.strip}"
