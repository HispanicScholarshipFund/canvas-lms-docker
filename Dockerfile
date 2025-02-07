# syntax=docker/dockerfile:1

ARG NODE_VERSION=22
ARG RUBY_VERSION=3.3
ARG CANVAS_HOME=/opt/canvas

FROM node:${NODE_VERSION}-alpine AS node

FROM ruby:${RUBY_VERSION}-alpine AS builder

ARG YARN_VERSION=1.22.22
ARG GIT_BRANCH=prod
ARG CANVAS_HOME

COPY --link --from=node /usr/local/bin/node /usr/local/bin/
COPY --link --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN <<EOF
ln -s /usr/local/bin/node /usr/local/bin/nodejs
ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

apk add --no-cache \
    alpine-sdk \
    bash \
    libidn-dev \
    libpq-dev \
    shared-mime-info \
    sqlite-dev \
    tzdata \
    xmlsec-dev \
    yaml-dev \
    file

npm update -g npm
npm install -g yarn@${YARN_VERSION}
EOF

ADD --link https://api.github.com/repos/HispanicScholarshipFund/canvas-lms/git/refs/heads/${GIT_BRANCH} /dev/null
RUN git clone -b ${GIT_BRANCH} --depth 1 https://github.com/HispanicScholarshipFund/canvas-lms.git ${CANVAS_HOME}

WORKDIR ${CANVAS_HOME}

RUN <<EOF
    pwd
    cd vendor
    git clone https://github.com/instructure/QTIMigrationTool.git QTIMigrationTool
    ls 
    cd QTIMigrationTool
    chmod +x migrate.py
    cd ../..
EOF


RUN <<EOF
yarn config set network-timeout 600000
yarn config set network-concurrency 1
yarn install --pure-lockfile

# https://github.com/sparklemotion/sqlite3-ruby/issues/434
bundle config set force_ruby_platform true
# Building the version 0.10.2 or earlier of "nokogiri-xmlsec-instructor" fails bacause the error "'XMLSEC_CRYPTO' undeclared" occurs.
# So, update "nokogiri-xmlsec-instructor" to the version 0.10.3 or later.
# https://github.com/instructure/nokogiri-xmlsec-instructure/pull/20
bundle update --conservative nokogiri-xmlsec-instructure
bundle install
bundle exec rake canvas:compile_assets_dev

rm -rf \
    .git \
    .github \
    .storybook \
    .vscode \
    build \
    doc \
    docker-compose \
    hooks \
    inst-cli \
    jest \
    log/* \
    node_modules \
    patches \
    tmp/* \
    ui \
    ui-build
rm \
    .codeclimate.yml \
    .dependency-cruiser.js \
    .devcontainer.json \
    .dive-ci \
    .dockerignore \
    .editorconfig \
    .git-blame-ignore-revs \
    .gitignore \
    .gitmessage \
    .groovylintrc.json \
    .i18nignore \
    .i18nrc \
    .irbrc \
    .lintstagedrc.js \
    .npmrc \
    .nvmrc \
    .prettierrc \
    .rspec \
    .rubocop.yml \
    .sentryignore \
    .stylelintrc \
    CONTRIBUTING.md \
    COPYRIGHT \
    Dockerfile* \
    Jenkinsfile* \
    LICENSE \
    README.md \
    SECURITY.md \
    code_of_conduct.md \
    config/*.yml.* \
    docker-compose* \
    eslint.config*.js \
    gulpfile.js \
    issue_template.md \
    jest.config.js \
    karma.conf.js \
    package.json \
    renovate.json \
    rspack.config.js \
    tsconfig.json \
    vitest.*.ts \
    yarn.lock
EOF

COPY --link canvas ${CANVAS_HOME}

FROM ruby:${RUBY_VERSION}-alpine AS runner

ARG CANVAS_HOME
ARG CANVAS_GROUP_ID=1000
ARG CANVAS_USER_ID=1000
ARG CANVAS_USER=canvas

ENV RUBYLIB=${CANVAS_HOME}

RUN <<EOF
apk add --no-cache \
    brotli-libs \
    git \
    libidn \
    libpq \
    shared-mime-info \
    sqlite-libs \
    tzdata \
    xmlsec \
    yaml \
    file 

addgroup -g ${CANVAS_GROUP_ID} ${CANVAS_USER}
adduser -D -G ${CANVAS_USER} -u ${CANVAS_USER_ID} -h ${CANVAS_HOME} ${CANVAS_USER}
EOF

COPY --link --from=builder --chown=${CANVAS_USER_ID} ${GEM_HOME} ${GEM_HOME}
COPY --link --from=builder --chown=${CANVAS_USER_ID} ${CANVAS_HOME} ${CANVAS_HOME}

WORKDIR ${CANVAS_HOME}

RUN apk update && apk add --update --no-cache \
    python3 \
    py3-pip \
    py3-virtualenv && \
    ln -sf python3 /usr/bin/python

RUN pip3 install lxml --break-system-packages

USER ${CANVAS_USER}

EXPOSE 3001

CMD [ "bundle", "exec", "rails", "server", "-p", "3001", "-b", "0.0.0.0" ]
