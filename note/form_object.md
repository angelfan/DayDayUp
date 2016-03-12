# 分离出表单对象(Form Objects)

## step1

```ruby
class SignupForm

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :user_name, department_id

  validates :user_name, presence: true


  def save
    if valid?
      # balabala
    else
      false
    end
  end

  def persisted?
    false
  end
end
```
### 缺点:
+ 属性没有类型
+ 设定default 值不是很方便

## step1
借助 [Virtus](https://github.com/solnic/virtus) 增加default值

```ruby
class SignupForm
  include ActiveModel::Model
  include Virtus

  # Attributes (DSL provided by Virtus)
  attribute :user_name, String
  attribute :department_id, Integer default: 1

  # Validations
  validates :user_name, presence: true

  def save
    if valid?
      # balabala
    else
      false
    end
  end
end
```

## resource
+ gem [reform](https://github.com/apotonick/reform)
+ gem [virtus](https://github.com/solnic/virtus)
+ gem [simple_form_object](https://github.com/reinteractive-open/simple_form_object)
+ [Creating Form Objects with ActiveModel and Virtus ](http://webuild.envato.com/blog/creating-form-objects-with-activemodel-and-virtus/)
+ [Form Objects in Rails](https://www.reinteractive.net/posts/158-form-objects-in-rails)


## other solution
form [sharetribe](https://github.com/sharetribe/sharetribe/blob/master/app/utils/form_utils.rb)
```ruby
module FormUtils
  module_function

  # Define a form class that can be used with ActiveSupport form bindings
  #
  # Usage:
  #
  # -- in some_controller.rb --
  #
  # MyForm = FormUtils.define_form("MyForm", :name, :password)
  #   .with_validations { validates_presence_of :name }
  #
  # def new
  #   render locals: { form_obj: MyForm.new }
  # end
  #
  # def create
  #   myForm = MyForm.new(params[:my_form])
  #   if myForm.valid?
  #     ...
  #
  def define_form(form_name, *ks)
    Class.new(Object) { |klass|
      include ActiveModel::Validations
      include ActiveModel::Conversion

      @__keys = ks
      @__form_name = form_name
      @__validation_blocks = []

      def self.keys
        @__keys
      end

      def self.validation_blocks
        @__validation_blocks
      end

      attr_reader(*ks)

      def initialize(opts = {})
        keys_and_values = self.class.keys
          .map { |k| [k, opts[k]] }
          .reject { |(k, v)| v.nil? }

        keys_and_values.each { |(k, v)|
          instance_variable_set("@#{k.to_s}", v)
        }

        instance_variable_set("@__value_hash", Hash[keys_and_values])
      end

      def persisted?
        false
      end

      def to_hash
        @__value_hash
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, @__form_name)
      end

      def self.with_validations(&block)
        @__validation_blocks << block
        class_exec(&block)
        self
      end
    }
  end

  def merge(form_name, *form_classes)
    keys = form_classes.map(&:keys).flatten
    validation_blocks = form_classes.map(&:validation_blocks).flatten

    form = FormUtils.define_form(form_name, *keys)

    validation_blocks.each do |block|
      form.with_validations(&block)
    end

    form
  end
end

SignupForm = FormUtils.define_form("SignupForm", :user_name, :department_id)
              .with_validations { validates_presence_of :user_name }
```