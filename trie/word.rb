class Word
  attr_reader :vague_words

  def initialize(word)
    @word = word
    build_vague_words
  end

  def real_word
    @word
  end

  def real_chars
    @real_chars ||= real_word.chars.uniq
  end

  def possible_chars(vague_word)
    (real_chars - vague_word_chars(vague_word)).join(',')
  end

  def vague_word_chars(vague_word)
    vague_word.tr('*', '').chars
  end

  private

  def build_vague_words
    @vague_words = []

    1.upto(real_word.size).each do |size|
      real_word.chars.uniq.combination(size).each do |combination|
        new_word = real_word.dup
        combination.each do |char|
          new_word.tr!(char, '*')
        end

        @vague_words << new_word
      end
    end
  end
end


p Word.new('angelfan')