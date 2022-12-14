ENV.instance_eval do
  OLD_ASSIGN = ENV.method(:[]=)
  OLD_HASH = ENV.method(:[])
  OLD_TO_H = ENV.method(:to_h)
  SMUGGLED = {}
  @smuggling = false

  def start_smuggling(keys: [])
    keys.each { |key|
      hide(key)
    }

    @smuggling = true
  end

  def [](key)
    value = OLD_HASH.call key
    return value unless value.nil?
    return SMUGGLED[key]
  end

  def []=(key, value)
    if @smuggling
      SMUGGLED[key] = value
    else
      OLD_ASSIGN.call(key, value)
    end
  end

  def smuggle(key, value)
    SMUGGLED[key] = value
  end

  def hide(key)
    SMUGGLED[key] = OLD_HASH.call key
    ENV.delete key
  end

  def to_h
    OLD_TO_H.call.merge(SMUGGLED.map { |k,v|
      [k, "**REDACTED**"]
    }.to_h)
  end

  def inspect
    to_h.inspect
  end
end
