FROM ruby:3.2.2

# Install essential packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set up app directory
WORKDIR /myapp
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Expose port 3000
EXPOSE 3000