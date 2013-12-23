require 'sinatra'
require 'qr_sina'

get '/' do
  @data = []
  img_path = "img/"
  public_img_path = "public/#{img_path}"

  urls = params["data"].nil? ? "" : params["data"]
  urls.each_line do |line|
    line = line.chomp
    next if line == ""

    line_sha1 = QrSina::sha1_digest(line)
    if Dir.glob("#{public_img_path}#{line_sha1}*").size == 0 then
      filename = QrSina::barcode(:png, line, "#{public_img_path}")
      use_cache = false
    else
      filename = "#{line_sha1}.png"
      use_cache = true
    end
 
    @data << {:url => line,
              :path => "#{img_path}#{filename}",
              :use_cache => use_cache}
  end

  erb :index
end

delete '/delete' do
  img_path = "img/"
  public_img_path = "public/#{img_path}"

  FileUtils.rm(Dir.glob("#{public_img_path}*"))
  redirect '/'
end

__END__

@@index
<html>
<head><title>qr</title></head>
<body>
  <h1>QR_Sinatra</h1>
  <h2>DataInput</h2>
  <form action="./" method="get">
    <textarea name="data" row="5" cols="40"></textarea>
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
  <form action="./delete" method="post">
    <input type="hidden" name="_method" value="delete" />
    <input type="submit" value="cache delete"/>
  </form>
 </body>
</html>
