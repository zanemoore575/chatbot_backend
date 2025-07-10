# syntax=docker/dockerfile:1
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory
WORKDIR /myapp

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application code
COPY . .

# Make our startup script executable
COPY render-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/render-start.sh

# Set the entrypoint to our script. This runs every time the container starts.
ENTRYPOINT ["render-start.sh"]

# Set the default command to run after the entrypoint.
# This will be passed to our script as "$@".
CMD ["bundle", "exec", "rails", "server"]
