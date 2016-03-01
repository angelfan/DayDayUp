# 需要使用到两个gem
```ruby
# Gemfile
gem 'doorkeeper'
gem 'doorkeeper-grants_assertion'
```

# For password grant flow
```ruby
# config/initializers/doorkeeper.rb
resource_owner_from_credentials do |routes|
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
        # 处理登录成功后的其他逻辑
        user # 要返回user
    else
        # 这里可以用来处理自定义的异常信息
        params[:__auth_error] = { type: 'InvalidLoginInfo', description: I18n.t('errors.invalid_login_info') }
        raise Doorkeeper::Errors::DoorkeeperError
    end
end
```

## api url 会像这样
```ruby
http://localhost:3000/oauth/token
params
grant_type: 'password',
client_id: application.uid,
client_secret: application.secret,
scope: 'public',
email: user.email,
password: user.password
```



# For assertion grant flow  处理第三方登录
```ruby
resource_owner_from_assertion do |routes|
    begin
        # 处理第三方登录
        resource_owner = ResourceOwner.from_assertion(*params.values_at(:assertion_type, :assertion_token, :assertion_secret))
        resource_owner
    rescue UnboundError => _e
        params[:__auth_error] = { type: 'Unbound' }
        raise Doorkeeper::Errors::DoorkeeperError
    rescue
        # do nothing (will returns 401 error)
    end
end
```

## api url 会像这样
```ruby
http://localhost:3000/oauth/token
params
grant_type: 'assertion',
client_id: application.uid,
client_secret: application.secret,
scope: 'public'
assertion_type: 'provider',
assertion_token: 'provider access token',
assertion_secret: 'provider secret',
```

## 处理第三方登录的逻辑

```ruby
# 以qq为例

class ResourceOwner
    self.from_assertion(provider, token, secret)
        get_profile_from_qq # get user info form qq
        initializer_or_create_user # initializer or find user by user info
        # return the user
    end

    def get_profile_from_qq(access_token, _ = nil)
        access_token = access_token(access_token)
        openid = openid(access_token)
        # 通过 opendid 取得用户信息
        openid_params = { openid: openid, oauth_consumer_key: 'qq_key', format: :json }
        user_info = access_token.get('/user/get_user_info', params: openid_params, parse: :json)
        # generate user info
    end

    def access_token(access_token)
        # 通过 OAuth2 取得 access_token
        client = OAuth2::Client.new(Settings.qq.app_id,
                                    Settings.qq.app_key,
                                    site:          'https://graph.qq.com',
                                    authorize_url: '/oauth2.0/authorize',
                                    token_url:     '/oauth2.0/token')
        OAuth2::AccessToken.new(client, access_token)
    end

    def openid(access_token)
      # 拿认证后的 access_token 可以去取得 openid
      access_token.options[:mode] = :query
      response = access_token.get('/oauth2.0/me')
      matched = response.body.match(/"openid":"(?<openid>\w+)"/)
      if matched.present?
        matched[:openid]
      else
        fail 'The access token is invalid'
      end
    end

    def initializer_or_create_user(user_info)
        # 可以增加一个model 用来处理User的绑定 User has_many: auth
        auth = User.find_or_initialize_by(provider: user_info.provider, uid: user_info.uid)
        auth.update!(oauth_token: user_info.credentials.token, oauth_secret: user_info.credentials.secret)
        auth
    end
end
```








