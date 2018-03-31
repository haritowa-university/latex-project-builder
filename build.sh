#!/bin/sh

rm -rf build
mkdir build
docker build -t latex-project-builder .
docker run -v $(pwd)/build:/container/build latex-project-builder
exit
