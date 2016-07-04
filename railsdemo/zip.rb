require 'zip'

# 解压
class ZipExtractor
  attr_reader :entries

  def initialize(zip, format)
    @zip = zip
    @format = format
    @entries = []
  end

  def extract_zip_entries
    Zip::File.open(@zip.path) do |zip_file|
      zip_file.each do |entry|
        entry_name = entry.name.force_encoding('utf-8')
        next unless entry_name =~ @format
        @entries << { name: File.basename(entry_name, '.*'),
                      filename: File.basename(entry_name),
                      path: entry_name,
                      file: create_tempfile_for_entry(entry, entry_name) }
      end
    end

    entries
  end

  def create_tempfile_for_entry(entry, filename)
    Zip.on_exists_proc = true

    basename = File.basename(filename, '.*')
    extname = File.extname(filename)
    Tempfile.new([basename, extname]).tap do |tempfile|
      entry.extract(tempfile.path)
      tempfile.binmode
    end
  end
end

# example
ZipExtractor.new(File.open(zip_path), /^(?!__MACOSX).*\.(jpg|png)/)

# 压缩
# Copy from: https://github.com/rubyzip/rubyzip#zipping-a-directory-recursively
class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w(. ..)

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |io|
      write_entries entries, '', io
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, io)
    entries.each do |e|
      zip_file_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zip_file_path)
      Rails.logger.info "Deflating #{disk_file_path}"

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, io, zip_file_path)
      else
        put_into_archive(disk_file_path, io, zip_file_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, io, zip_file_path)
    io.mkdir zip_file_path
    subdir = Dir.entries(disk_file_path) - %w(. ..)
    write_entries subdir, zip_file_path, io
  end

  def put_into_archive(disk_file_path, io, zip_file_path)
    io.get_output_stream(zip_file_path) do |f|
      f.puts(File.open(disk_file_path, 'rb').read)
    end
  end
end

# example
ZipFileGenerator.new(target_dir, zip_output).write
