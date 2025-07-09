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

# Start the Rails server and bind it to 0.0.0.0
CMD ["rails", "server", "-b", "0.0.0.0"]