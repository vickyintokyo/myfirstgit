require 'gmail'

username = 'test60482@gmail.com'
password = 'testing123'

gmail = Gmail.connect(username, password)
# play with your gmail...
puts 'i could get in'
gmail.logout

gmail.deliver do
  to "test60482@gmail.com"
  subject "Having fun in Puerto Rico!"
  puts '1'
  text_part do
    body "Text of plaintext message."
  end
  puts '2'
  html_part do
    content_type 'text/html; charset=UTF-8'
    body "<p>Text of <em>html</em> message.</p>"
  end
  puts '3'
  #add_file "/path/to/some_image.jpg"
end
