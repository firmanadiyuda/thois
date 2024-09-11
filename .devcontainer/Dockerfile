# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.4
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libgphoto2-dev libgphoto2-port12 gphoto2