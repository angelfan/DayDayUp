require 'strscan'

class TransitionTable
  def initialize(regexp_states, string_states)
    @regexp_states = regexp_states
    @string_states = string_states
    # @accepting     = {}
    # @memos         = Hash.new { |h,k| h[k] = [] }
  end

  def move(t, a)
    return [] if t.empty?

    regexps = []

    t.map { |s|
      if states = @regexp_states[s]
        regexps.concat states.map { |re, v| re === a ? v : nil }
      end

      if states = @string_states[s]
        states[a]
      end
    }.compact.concat regexps
  end

  def get_memo_index(path_info)
    input = StringScanner.new(path_info)
    state = [0]
    while sym = input.scan(%r([/.?]|[^/.?]+))
      state = move(state, sym)
    end

    state
  end
end


# 'hello/:name'
# 'welcome/hello'
string_states = {
    0 => {
        '/' => 1
    },
    1 => {
        'hello' => 2,
        'welcome' => 3
    },
    2 => {
        '/' => 4
    },
    3 => {
        '/' => 5
    },
    5 => {
        'hello' => 'welcome/hello memo_index'
    }
}
regexp_states = {
    4 => {
        /[^\.\/\?]+/ => 'hello/:name memo_index'
    }
}

tt = TransitionTable.new(regexp_states, string_states)
p tt.get_memo_index('/welcome/hello')
p tt.get_memo_index('/hello/name')