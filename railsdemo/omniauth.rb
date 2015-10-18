# == Schema Information
#
# Table name: omniauths
#
#  id               :integer          not null, primary key
#  provider         :string(255)
#  uid              :string(255)
#  oauth_token      :text
#  oauth_expires_at :datetime
#  owner_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  email            :string(255)
#  username         :string(255)
#  owner_type       :string(255)
#  oauth_secret     :string(255)
#

class Omniauth < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, autosave: true, touch: true

  validates :provider, :uid, :oauth_token, presence: true

  validates_associated :owner

  def create_owner(data)
    user = User.create!(
      name: data.info.name,
      email: data.info.email || User.random_email,
      password: SecureRandom.urlsafe_base64,
      remote_avatar_url: data.info.image,
      location: data.info.location
    )
    update(owner: user)
  end

  ID_COLUMN = {
    'facebook' => 'id',
    'twitter' => 'id',
    'google_oauth2' => 'sub',
    'qq' => 'id',
    'weibo' => 'id'
  }

  class << self
    def authenticate(provider, access_token, secret = nil)
      profile = send("verify_#{provider}", access_token, secret)
      id = profile[ID_COLUMN[provider]]
      Omniauth.find_or_initialize_by(provider: provider, uid: id).tap do |auth|
        auth.update(oauth_token: access_token, oauth_secret: secret)
      end
    end

    def verify(provider, access_token, _secret = nil)
      case provider
      when 'qq'
        verify_qq(access_token)
      else
        fail OauthProviderMissingError, caused_by: provider
      end
    end

    def verify_qq(access_token, _ = nil)
      access_token = qq_access_token(access_token)
      openid = get_qq_openid(access_token)
      openid_params = { openid: openid, oauth_consumer_key: Settings.qq.app_id, format: :json }
      access_token.get('/user/get_user_info', params: openid_params, parse: :json).parsed
    end

    def qq_access_token(access_token)
      client = OAuth2::Client.new(Settings.qq.app_id,
                                  Settings.qq.app_key,
                                  site:          'https://graph.qq.com',
                                  authorize_url: '/oauth2.0/authorize',
                                  token_url:     '/oauth2.0/token')
      OAuth2::AccessToken.new(client, access_token)
    end

    def get_qq_openid(access_token)
      access_token.options[:mode] = :query
      response = access_token.get('/oauth2.0/me')
      matched = response.body.match(/"openid":"(?<openid>\w+)"/)
      if matched.present?
        matched[:openid]
      else
        fail 'The access token is invalid'
      end
    end
  end
end
