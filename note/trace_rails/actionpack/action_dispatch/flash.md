# Flash

## ActionDispatch::Request
#reset_session
#commit_flash

## ActionDispatch::Flash
重写Request#commit_flash
重写方式为 ```prepend Flash::RequestMethods```

```ruby
def commit_flash # :nodoc:
  session    = self.session || {}
  flash_hash = self.flash_hash

  if flash_hash && (flash_hash.present? || session.key?('flash'))
    session["flash"] = flash_hash.to_session_value
    self.flash = flash_hash.dup
  end

  if (!session.respond_to?(:loaded?) || session.loaded?) && session.key?('flash') && session['flash'].nil?
    session.delete('flash')
  end
end
```

1. FlashNow生命周期到当前action处理完毕
```ruby
def []=(k, v)
  k = k.to_s
  @flash[k] = v
  @flash.discard(k)
  v
end
```
它会在赋值的同时将它塞到@discard中去
这样在commit_flash的时候(当前action处理完毕)不会将它塞到session中去
```ruby
def to_session_value #:nodoc:
  flashes_to_keep = @flashes.except(*@discard)
  return nil if flashes_to_keep.empty?
  {'flashes' => flashes_to_keep}
end
```

2. 非FlashNow之所以在下一次action处理完毕后会消失是因为
```ruby
def flash
  flash = flash_hash
  return flash if flash
  self.flash = Flash::FlashHash.from_session_value(session["flash"])
end

class FlashHash
  include Enumerable

  def self.from_session_value(value)
    case value
    when FlashHash # Rails 3.1, 3.2
      flashes = value.instance_variable_get(:@flashes)
      if discard = value.instance_variable_get(:@used)
        flashes.except!(*discard)
      end
      new(flashes, flashes.keys)
    when Hash # Rails 4.0
      flashes = value['flashes']
      if discard = value['discard']
        flashes.except!(*discard)
      end
      new(flashes, flashes.keys)
    else
      new
    end
  end


  def initialize(flashes = {}, discard = [])
    @discard = Set.new(stringify_array(discard))
    @flashes = flashes.stringify_keys
    @now     = nil
  end
end
```
在call flash的时候回先去session中去取, 并且将其key塞入@discard


## ActionController::Metal
1. 生命周期到处理完action之后停止
```ruby
def dispatch(name, request, response) #:nodoc:
  set_request!(request)
  set_response!(response)
  process(name)
  request.exitexitexit

  to_a
end
```

## ActionController::Flash
之所以在controller中可以直接调用flash时因为在这个地方
`delegate :flash, to: :request`
并且重写了redirect_to 以支持 `redirect_to url, notice: "notice"`