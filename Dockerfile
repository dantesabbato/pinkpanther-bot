FROM ruby:3.3
ENV TZ=Europe/Moscow
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install
COPY . .
ENV REDIS_URL=redis://redis:6379/0
CMD ["bash", "-c", "bundle exec rake db:migrate && bin/bot & bundle exec sidekiq -C config/sidekiq.yml"]
