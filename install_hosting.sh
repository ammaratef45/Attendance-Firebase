#!/usr/bin/env sh

cd AngularDart

rm -rf build

pub global run webdev build

cd ..

firebase deploy --only hosting