require 'triez'

words = %w(大叶榕 细叶榕 高山榕 木棉 洋紫荆 樟树 芒果 蝴蝶果 人面子)

trie = Triez.new

words.each { |word| trie[word] = 1 }

post_text = '行道树芒&&果引市民争相采摘。'

results = Hash.new(0)

post_text = post_text.gsub(/[\s&%$@*]+/, '')

(0..post_text.size - 1).each do |i|
  trie.walk(post_text[i..-1]).each do |word_in_trie, _|
    results[word_in_trie] = results[word_in_trie] + 1
  end
end
