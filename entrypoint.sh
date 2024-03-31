#!/bin/sh

git config --global --add safe.directory /github/workspace

yarn
yarn run postinstall
yarn build:prod
yarn run package
