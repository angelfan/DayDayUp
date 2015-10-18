# coding: utf-8
require 'nokogiri'
require 'open-uri'
NORMALIZE_USER_REGEXP = /(^|[^a-zA-Z0-9_!#\$%&*@＠])@([a-zA-Z0-9_]{1,20})/io
LINK_USER_REGEXP = /(^|[^a-zA-Z0-9_!#\$%&*@＠])@(user[0-9]{1,6})/io
def normalize_user_mentions(text)
  users = []

  # 这里面有两个起来很奇怪的东西 $1, $2
  # 3.匹配组
  # 在Ruby正则表达式中,可以用正则式匹配一个或多个子字符串；方法是将正
  # 则式用小括号括起来；使用小括号指定的获取子字符串,可以将匹配的字符串保存；如下正则式中有两个组(hi)和(h…o):
  #     　　/(hi).*(h...o)/ =~ "The word 'hi' is short for 'hello'."
  # 匹配成功时, 会把匹配的值赋给一些变量(正则式中有多少组就有多少变量), 这些变量可以通过$1,$2,$3…的形式访问；如果执行上面的那行代码,可以使用$1,$2来访问变量:
  #     print ( $1, " ", $2, "\n" ) #=> hi hello
  # Note: 如果整个正则式匹配不成功,那么就不会就有变量被初始化, 而是返回nil.
  text.gsub!(NORMALIZE_USER_REGEXP) do
    prefix = Regexp.last_match(1)
    user = Regexp.last_match(2)
    users.push(user)
    "#{prefix}@user#{users.size}"
  end

  users
end

def link_mention_user_in_text(doc, users)
  doc.search('text()').each do |node|
    content = node.to_html
    next unless content.include?('@')

    in_code = has_ancestors?(node, %w(pre code))
    content.gsub!(LINK_USER_REGEXP) do
      prefix = Regexp.last_match(1)
      user_placeholder = Regexp.last_match(2)
      user_id = user_placeholder.sub(/^user/, '').to_i
      user = users[user_id - 1] || user_placeholder

      if in_code
        "#{prefix}@#{user}"
      else
        %(#{prefix}<a href="/#{user}" class="at_user" title="@#{user}">@#{user}</a>)
      end
    end

    node.replace(content)
  end
end
text = '@angel 你好，text() 我是 @legend'
users = normalize_user_mentions(text)
doc = Nokogiri::HTML.fragment(text)
p users
p doc
