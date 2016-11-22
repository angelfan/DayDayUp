# one url with multiple controller#action
get    'sample/url' => 'my#new_user',       constraints: NewUserConstraint
get    'sample/url' => 'my#wants_photo',    constraints: WantsPhotoConstraint
get    'sample/url' => 'my#user_to_update', constraints: UserToUpdateConstraint

class NewUserConstraint
  def self.matches?(request)
    request.query_parameters['strategy'] == 'new_user'
  end
end

class WantsPhotoConstraint
  def self.matches?(request)
    request.query_parameters['strategy'] == 'wants_photo'
  end
end

class UserToUpdateConstraint
  def self.matches?(request)
    request.query_parameters['strategy'] == 'user_to_update'
  end
end
