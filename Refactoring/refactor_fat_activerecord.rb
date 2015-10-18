### 分离装饰器 ###
#
# 装饰器让你可以对现有操作分层，所以它和回调有点像。
# 当回调逻辑仅仅只在某些环境中使用或者将它包含在模型里会给模型增加太多权责，装饰器是很有用的。
#
# 给一篇博文加一条评论会触发在某人的 facebook 墙上发一条帖子，但这并不意味着需要将这个逻辑硬编码到 Comment 类。
# 一个你给回调加了太多权责的信号是：测试变得很慢并且很脆弱或者你恨不得将所有不相关的测试屏蔽掉。
#
# 这里展示了你如何将 Facebook 发贴的逻辑提取到装饰器里面：
#
# 装饰器之所以和服务对象不同，是因为它对权责分层。
# 一旦加上装饰器，使用者就就可将 FacebookCommentNotifier 实例看作 Comment 。

class FacebookCommentNotifier
  def initialize(comment)
    @comment = comment
  end

  def save
    @comment.save && post_to_wall
  end

  private

  def post_to_wall
    Facebook.post(title: @comment.title, user: @comment.author)
  end
end

class CommentsController < ApplicationController
  def create
    @comment = FacebookCommentNotifier.new(Comment.new(params[:comment]))

    if @comment.save
      redirect_to blog_path, notice: 'Your comment was posted.'
    else
      render 'new'
    end
  end
end

### 分离值对象(value Objects) ###

### 分离出服务对象（Service Objects）###
#
# 一个系统中的有些 action 需要一个服务对象来封装它们的操作。如果一个 action 满足以下的某个条件，我会使用服务对象。
#
# action 非常复杂（比如说： 会议结束后合上书本）
# action 关联了好几个模型（比如说：一个电子商务系统中下单过程使用了 Order ， CreditCard 和 Customer 对象）
# action 和其它外部系统有交互（比如说：在社交网络上发贴）
# action 不是根本模型的核心关注点（比如说：一段时间后清除过时数据）
# 有很多方式可以实现这个 action（比如说： 使用 token 或者密码验证用户）。也就是四人帮的策略模式。
# 我们可以举一个 UserAuthenticator 的 User#authenticate 的例子：

class UserAuthenticator
  def initialize(user)
    @user = user
  end

  def authenticate(unencrypted_password)
    return false unless @user

    if BCrypt::Password.new(@user.password_digest) == unencrypted_password
      @user
    else
      false
    end
  end
end

class SessionsController < ApplicationController
  def create
    user = User.where(email: params[:email]).first

    if UserAuthenticator.new(user).authenticate(params[:password])
      self.current_user = user
      redirect_to dashboard_path
    else
      flash[:alert] = 'Login failed.'
      render 'new'
    end
  end
end

### 分离出表单对象(Form Objects) ###
#
# 当一个表单需要更新很多个 ActiveRecord 模型时，一个表单对象可以很好的实现封装。
# 这样比使用 accepts_nested_attributes_for 要清晰多了， 后者在我看来应该过时了。
# 一个普遍的例子是一个注册的表单，他可能需要创建 Company 和 User 对象：
class Signup
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :user
  attr_reader :company

  attribute :name, String
  attribute :company_name, String
  attribute :email, String

  validates :email, presence: true
  # … more validations …

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    @company = Company.create!(name: company_name)
    @user = @company.users.create!(name: name, email: email)
  end
end

# 我们使用 Virtus 来让这些对象获得 ActiveRecord 一样的功能属性。这个表单对象就像 ActiveRecord 一样。所以，控制器还是和原来差不多。

class SignupsController < ApplicationController
  def create
    @signup = Signup.new(params[:signup])

    if @signup.save
      redirect_to dashboard_path
    else
      render 'new'
    end
  end
end

### 分离出查询对象(Query Objects) ###

### 分离出 Policy Objects ###
# 有时候，复杂的读操作需要分别处理它们自己的对象，这时候，我会用 Policy Objects 。
# 这样可以让你将逻辑切片，像找出哪些是活跃用户来达到分析的目的，和你的核心业务对象分离开。
# 比如：

class ActiveUserPolicy
  def initialize(user)
    @user = user
  end

  def active?
    @user.email_confirmed? &&
      @user.last_login_at > 14.days.ago
  end
end

# 这个 Policy Objects 封装了一个业务规则：如果一个用户已经验证过邮箱，并且两周以内登录过，则认为他是活跃用户。
# 你也可以使用 Policy Objects 来封装一组业务规则，比如用 Authorizer 来管理一个用户可以处理的数据。

# Policy Objects 和服务对象很相似，但是，我用服务对象来完成写操作， Policy Objects 来完成读操作。
# 它们和查询对象也很相似，但是查询对象关注执行查询语句并返回结果集，然后 Policy Objects 对一个已经加载到内存中的模型操作。
