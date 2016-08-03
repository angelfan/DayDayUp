class FilesChecker
  attr_accessor :files, :last_watched, :last_update_at

  def update?
    FilesUpdateChecker.new(files, {}, {last_update_at: last_update_at}).updated?
  end
end

# 目的是希望可以给予ActiveSupport::FileUpdateChecker
# 一个最后修改的时间 或者 最后跟踪的文件(只会根据文件数量去比对!)
# 使之给予提供的标准去比较
class FilesUpdateChecker < ActiveSupport::FileUpdateChecker
  def initialize(files, dirs={}, options = {}, &block)
    @files = files.freeze
    @glob  = compile_glob(dirs)
    @block = block

    @watched    = nil
    @updated_at = nil

    @last_watched   = options[:last_watched] || watched
    @last_update_at = options[:last_update_at] || updated_at(@last_watched)
  end

  def last_watched=(last_watched)
    @last_watched = last_watched
  end

  def last_update_at=(last_update_at)
    @last_update_at = last_update_at
  end
end
