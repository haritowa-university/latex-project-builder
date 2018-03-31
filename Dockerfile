from ibmcom/swift-ubuntu
workdir /container
add . /container
run swift build -c release
CMD ["cp", ".build/release/latex-project-builder", "build/latex-project-builder"]
