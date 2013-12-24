# coding: utf-8
require "qr_sina/version"

require "barby"
require "barby/barcode/qr_code"
require "barby/outputter/ascii_outputter"
require "barby/outputter/png_outputter"
require "rqrcode"

require "digest/sha1"

module QrSina
  extend self

  def barcode(type, data, out_path="./")
    data = "http://google.com" if data.nil? or data == ""

    code = Barby::QrCode.new(data.force_encoding("cp852"))
    case type
    when :png
      puts "--", "#{data} is", code.encoding, "--"
      blob = Barby::PngOutputter.new(code)
      # bin    : 89 50 4E 47 0D 0A 1A 0A
      # not bin: 89 50 4E 47 0D 0D 0A 1A 0D 0A
      filename = sha1_digest(data)
      File.open("#{out_path}#{filename}.png", 'wb') do |f|
        png = blob.to_png({:xdim => 7, :ydim => 7})

        #puts png.bytes {|b| print b.to_s(16) + " "}
        #puts png.bytes {|b| print b.to_s(2) + " "}

        f.write png
        "#{filename}.png"
      end
    when :ascii
      code.to_ascii
    end
  end

  def sha1_digest(data)
    Digest::SHA1.hexdigest(data)
  end
end

if $0 == __FILE__ then
  QrSina::barcode(:png, nil)
  # puts QrSina::barcode(:ascii)
end
