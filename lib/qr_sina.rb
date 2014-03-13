# coding: utf-8
require 'qr_sina/version'

require 'barby'
require 'barby/barcode/qr_code'
require 'barby/outputter/ascii_outputter'
require 'barby/outputter/png_outputter'
require 'rqrcode'

require 'digest/sha1'

# Generate QR code
module QrSina
  module_function

  def barcode(type, data, out_path = './', split_limit = 1024)
    data = 'http://google.com' if data.nil? || data == ''
    # puts '--', "data is: #{data}", '--'

    # MAX 2954
    split_limit = 2900 if split_limit > 2900

    codes = []
    puts "byte: #{data.bytesize} len: #{data.length}"

    loop = 0
    while (split_limit*loop < data.length)
      split_data = data[(split_limit*loop)..(split_limit*(loop+1))-1]
      code = Barby::QrCode.new(split_data.force_encoding(Encoding::ASCII_8BIT))
      codes << { code: code, data: split_data }
      loop += 1
    end
    puts "data: #{loop} times split"

    filenames = []
    count = 0
    codes.each do |c|
      case type
      when :png
        # puts "#{c[:code].encoding}", '--'
        blob = Barby::PngOutputter.new(c[:code])
        # bin    : 89 50 4E 47 0D 0A 1A 0A
        # not bin: 89 50 4E 47 0D 0D 0A 1A 0D 0A
        filename = "#{sha1_digest(data)}_#{count}"
        File.open("#{out_path}#{filename}.png", 'wb') do |f|
          png = blob.to_png(xdim: 7, ydim: 7)

          # puts png.bytes {|b| print b.to_s(16) + ' '}
          # puts png.bytes {|b| print b.to_s(2) + ' '}

          f.write png
          puts "generate: #{filename}.png"
          filenames << { path: "#{filename}.png", data: c[:data] }
          count += 1
        end
      when :ascii
        code.to_ascii
      end
    end
    filenames
  end

  def sha1_digest(data)
    Digest::SHA1.hexdigest(data)
  end
end

if $PROGRAM_NAME == __FILE__
  QrSina.barcode(:png, nil)
  # puts QrSina.barcode(:ascii)
end
