namespace :config do
  desc "generate config/omniauth.yml"
  task create_omniauth: :environment do
    if ENV['CONSUMER_KEY'].nil? or ENV['CONSUMER_SECRET'].nil?
      raise Rake::TaskArgumentError, "please specify CONSUMER_KEY and CONSUMER_SECRET"
    end
    str = 'twitter:
  consumer_key: "__CK__"
  consumer_secret: "__CS__"
'
    str.sub!('__CK__', ENV['CONSUMER_KEY'])
    str.sub!('__CS__', ENV['CONSUMER_SECRET'])
    filename = 'config/test.yml.sample'
    File.open(filename, "w") {|f| f.puts str }
    puts "created #{filename} with your keys."
  end

end
