
export COMPOSE_ENV_FILES=.env
docker compose run --rm app bundle exec rake db:initial_setup
