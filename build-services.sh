#!/bin/bash
# build all dependent services

pushd ../employee-service
sbt clean docker
popd

pushd ../event-service
mvn clean package docker:build
popd
