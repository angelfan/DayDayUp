# RSpec speed

##  [tweaking ruby garbage collection](https://ariejan.net/2011/09/24/rspec-speed-up-by-tweaking-ruby-garbage-collection/)
```ruby
# spec/support/deferred_garbage_collection.rb
class DeferredGarbageCollection

  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 15.0).to_f

  @@last_gc_run = Time.now

  def self.start
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def self.reconsider
    if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable
      @@last_gc_run = Time.now
    end
  end
end
```

```ruby
if defined?(Cucumber)
  # put it to feature/support/hooks.rb
  Before do
    DeferredGarbageCollection.start
  end

  After do
    DeferredGarbageCollection.reconsider
  end
elsif defined?(RSpec)
  # put it to spec/spec_helper.rb
  RSpec.configure do |config|
    config.before(:all) do
      DeferredGarbageCollection.start
    end

    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end
  end
end
```

## [DatabaseCleaner](https://github.com/DatabaseCleaner/database_cleaner)

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
    # if ex.metadata[:type] == :feature
    #   DatabaseCleaner.cleaning { ex.run }
    # else
    #   ex.run
    # end
  end
end
```

## Sidekiq::Worker.clear

```ruby
config.before(:each) do
  Sidekiq::Worker.clear_all
end
```

## [vcr](https://github.com/vcr/vcr)

```ruby
# spec/support/vcr_setup.rb
VCR.configure do |c|
  #the directory where your cassettes will be saved
  c.cassette_library_dir = 'Rails.root.join('spec', 'vcr')
  # your HTTP request service. You can also use fakeweb, webmock, and more
  c.hook_into :typhoeus # :webmock
  c.ignore_localhost = true
  c.ignore_hosts 'baidu.com'
end

# spec/spec_helper.rb
config.around(:each) do |ex|
  if ex.metadata.key?(:vcr)
    ex.run
  else
    VCR.turned_off { ex.run }
  end
end
```

## [webmock](https://github.com/bblimke/webmock)

## [timecop](https://github.com/travisjeffery/timecop)

```ruby
config.around(:each) do |ex|
  if ex.metadata.key?(:freeze_time)
    Timecop.freeze { ex.run }
  else
    ex.run
  end
end
```
## Notice

```ruby
let (:address) {create(:address)}
# =>
let (:address) {build_stubbed(:address)}

expect(page).not_to have_content('Dashboard')
# =>
expect(page.has_no_content?('Dashboard')).to eq(true)

xhr :get, params, format: :js
```

