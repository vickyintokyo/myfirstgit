=begin
require 'aws-sdk-s3'  # v2: require 'aws-sdk'

s3 = Aws::S3::Resource.new(region: 'us-west-2')

s3.buckets.limit(50).each do |b|
  puts "#{b.name}"
end
=end
require 'aws-sdk-ses'  # v2: require 'aws-sdk'
require 'byebug'

# Create client in us-west-2 region
client = Aws::SES::Client.new(region: 'us-west-2')

# Get up to 1000 identities
ids = client.list_identities({
  identity_type: "EmailAddress"
})
ids.identities.each do |email|
  attrs = client.get_identity_verification_attributes({
    identities: [email]
  })
  puts attrs

  status = attrs.verification_attributes[email].verification_status

  # Display email addresses that have been verified
  if status == "Success"
    puts email
  end
end
