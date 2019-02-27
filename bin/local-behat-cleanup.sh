#!/bin/bash

export SSH_PRIVATE_KEY=$(<ssh_key.txt)
eval $(ssh-agent -s) && ssh-add <(echo "$SSH_PRIVATE_KEY")
export PATH=$PATH:$HOME/bin:$HOME/terminus/bin
export CURRENT_BRANCH=pantheon-context
export CI_PR_URL=https://gitlab.com/ataylorme/ataylor-gitlab-test-11/merge_requests/1
export TERMINUS_ENV=local-behat
export TERMINUS_SITE=ataylor-gitlab-test-11
export TERMINUS_TOKEN=ON6v1TCHRLNuH63aFB5J6g9GL2l5Q0fDV76GW4qk5atgB
export BEHAT_ADMIN_PASSWORD=$(openssl rand -base64 24)
export BEHAT_ADMIN_EMAIL=andrew+local-ci@pantheon.io
export BEHAT_ADMIN_USERNAME=pantheon-ci-testing-local
terminus auth:login --machine-token="$TERMINUS_TOKEN"
git config --global user.email "andrew+local-ci@pantheon.io"
git config --global user.name "Gitlab CI"

./.ci/behat-test-cleanup.sh
