#!/bin/sh

rm -rf build
mkdir build
docker run -v $(pwd)/build:/container/build latex-project-builder
exit
