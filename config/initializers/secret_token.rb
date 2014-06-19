# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

# old, probably compromised
# Oclcmap::Application.config.secret_key_base = 'c299a10c8e368618039ce5834a7d9d1558a711a1749ccee67b65aed7aa730d7c0555417e04037c0e27100d163f676815975c27de355446e986769e9801e9a9a5'

begin
    token_file = Rails.root.to_s + "/secret_token"
    to_load = open(token_file).read
    Oclcmap::Application.configure do
        config.secret_token = to_load
    end
rescue LoadError, Errno::ENOENT => e
    raise "Secret token couldn't be loaded! Error: #{e}"
end