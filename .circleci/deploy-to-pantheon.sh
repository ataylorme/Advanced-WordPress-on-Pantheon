#!/bin/bash

set -ex

TERMINUS_DOES_MULTIDEV_EXIST()
{
    # Return 0 if on master since dev always exists
    if [[ ${CIRCLE_BRANCH} == "master" ]]
    then
        return 0;
    fi
    
    # Stash list of Pantheon multidev environments
    PANTHEON_MULTIDEV_LIST="$(terminus multidev:list -n ${TERMINUS_SITE} --format=list --field=Name)"

    while read -r multiDev; do
        if [[ "${multiDev}" == "$1" ]]
        then
            return 0;
        fi
    done <<< "$PANTHEON_MULTIDEV_LIST"

    return 1;
}

if [[ (${CIRCLE_BRANCH} != "master" && -z ${CIRCLE_PULL_REQUEST+x}) || (${CIRCLE_BRANCH} == "master" && -n ${CIRCLE_PULL_REQUEST+x}) ]];
then
    echo -e "CircleCI will only deploy to Pantheon if on the master branch or creating a pull requests.\n"
    exit 0;
fi

if ! TERMINUS_DOES_MULTIDEV_EXIST ${TERMINUS_ENV}
then
    terminus env:wake -n "$TERMINUS_SITE.dev"
    terminus build:env:create -n "$TERMINUS_SITE.dev" "$TERMINUS_ENV" --clone-content --yes
else
    terminus build:env:push -n "$TERMINUS_SITE.$TERMINUS_ENV" --yes
fi

# Update WordPress database
terminus -n wp $TERMINUS_SITE.$TERMINUS_ENV -- core update-db

set +ex
echo 'terminus secrets:set'
terminus secrets:set -n "$TERMINUS_SITE.$TERMINUS_ENV" token "$GITHUB_TOKEN" --file='github-secrets.json' --clear --skip-if-empty
set -ex

# Cleanup old multidevs
terminus build:env:delete:pr -n "$TERMINUS_SITE" --yes
