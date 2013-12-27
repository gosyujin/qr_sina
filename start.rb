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

  case params['split']
  when 'on' then
    str.each_line do |line|
      line = line.chomp
      next if line == ''

      @data << generate_qrcode(line, exist_cache(line))
    end
  else
    @data << generate_qrcode(str, exist_cache(str))
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

def generate_qrcode(str, use_cache)
  if use_cache
    str_sha1 = sha1(str)
    filename = "#{str_sha1}.png"
  else
    filename = QrSina.barcode(:png, str, "#{@img_path}/")
  end

  { url: str, path: "img/#{filename}", use_cache: use_cache }
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
    <input type="checkbox" name="split" />split
    <input type="submit" value="submit"/>
  </form>

  <h2>Barcode</h2>
  <% @data.each do |data| %>
     <% url = data[:url] %>
     <% path = data[:path] %>
     <% use_cache = data[:use_cache] %>
     <img src='<%= path %>' /><br />
     <p>img path: <%= path %></p>
     <p>use cache?: <%= use_cache %></p>
     <a href='<%= url %>'><%= url %></a>
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
