# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Dummy::Application.config.secret_key_base = ENV['SECRET_KEY_BASE'] || '49ade6ce637f129a386a7a4c662ba034dd49a8f3741f72ddc6dccf77d6171e33939d54489d92372177215b1f2a8e75216e8a732d250b0ca08f56172635db0bfd'
