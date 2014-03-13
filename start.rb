# coding: utf-8
require 'sinatra'
require 'qr_sina'

before do
  @img_path = 'public/img'
  @data = []
  @list = Dir.glob("#{@img_path}/*")
end

get '/' do
  erb:index
end

post '/' do
  str = params['data'].nil? ? '' : params['data']
  # Invalid number or nil = 0
  limit = params['limit'].to_i == 0 ? 1024 : params['limit'].to_i

  @data = []
  case params['split']
  when 'on' then
    str.each_line do |line|
      line = line.chomp
      next if line == ''

      @data << generate_qrcode(line, exist_cache(line), limit)[0]
    end
  else
    @data = generate_qrcode(str, exist_cache(str), limit)
  end
  erb :index
end

delete '/delete' do
  FileUtils.rm(Dir.glob("#{@img_path}/*"))
  redirect '/'
end

def sha1(str)
  QrSina.sha1_digest(str)
end

def exist_cache(str)
  str_sha1 = sha1(str)
  if Dir.glob("#{@img_path}/#{str_sha1}*").size == 0
    false
  else
    true
  end
end

def generate_qrcode(str, use_cache, limit)
  filenames = []
  if use_cache
    str_sha1 = sha1(str)
    filenames << { path: "#{str_sha1}_0.png", data: str }
  else
    filenames = QrSina.barcode(:png, str, "#{@img_path}/", limit)
  end

puts filenames
  hash = []
  filenames.each do |f|
    hash << { url: f[:data], path: "img/#{f[:path]}", use_cache: use_cache }
  end
puts hash
  hash
end

__END__

@@index
<html>
<head><title>qr</title></head>
<body>
  <h1>QR_Sinatra</h1>
  <h2>DataInput</h2>
  <form action="./" method="post">
    <textarea name="data" row="5" cols="40"></textarea>
    limit<input type="text" name="limit" />
    split<input type="checkbox" name="split" />
    <input type="submit" value="submit" />
  </form>

  <h2>Barcode</h2>
  <% @data.each do |data| %>
     <% url = data[:url] %>
     <% path = data[:path] %>
     <% use_cache = data[:use_cache] %>
     <img src='<%= path %>' /><br />
     <p>img path: <%= path %></p>
     <p>use cache?: <%= use_cache %></p>
     <pre><%= url %></pre>
     <hr />
  <% end %>

  <h2>Cache List</h2>
  <ul>
  <% @list.each do |qr| %>
    <li><%= File.basename(qr) %></li>
  <% end %>
  </ul>

  <form action="./delete" method="post">
    <input type="hidden" name="_method" value="delete" />
    <input type="submit" value="cache delete"/>
  </form>
 </body>
</html>
