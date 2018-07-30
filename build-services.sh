#!/bin/bash
# build all dependent services

pushd ../employee-service
sbt clean docker
popd


