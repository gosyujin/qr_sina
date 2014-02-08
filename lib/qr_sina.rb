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

  def barcode(type, data, out_path = './')
    data = 'http://google.com' if data.nil? || data == ''
    # puts '--', "data is: #{data}", '--'

    codes = []
    begin
      data_tmp = data
      code = Barby::QrCode.new(data_tmp.force_encoding(Encoding::ASCII_8BIT))
      codes << code
    rescue ArgumentError => ex
      puts "#{ex} byte: #{data.bytesize} len: #{data.length}"

      # 2954
      split_limit = 1200
      loop = 0
      while (split_limit*loop < data.length)
        split_data = data[(split_limit*loop)..(split_limit*(loop+1))-1]
        code = Barby::QrCode.new(split_data.force_encoding(Encoding::ASCII_8BIT))
        codes << code
        loop += 1
      end
      puts "data: #{loop} times split"
    end

    filenames = []
    count = 0
    codes.each do |code|
      case type
      when :png
        # puts "#{code.encoding}", '--'
        blob = Barby::PngOutputter.new(code)
        # bin    : 89 50 4E 47 0D 0A 1A 0A
        # not bin: 89 50 4E 47 0D 0D 0A 1A 0D 0A
        filename = "#{sha1_digest(data)}_#{count}"
        File.open("#{out_path}#{filename}.png", 'wb') do |f|
          png = blob.to_png(xdim: 7, ydim: 7)

          # puts png.bytes {|b| print b.to_s(16) + ' '}
          # puts png.bytes {|b| print b.to_s(2) + ' '}

          f.write png
          puts "generate: #{filename}.png"
          filenames << "#{filename}.png"
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
