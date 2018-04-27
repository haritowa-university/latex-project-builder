//
//  FileBuilder.swift
//  latex-project-builder
//
//  Created by haritowa on 3/30/18.
//

import Foundation
import Basic
import Utility

let parser = LatexBuilderArgumentParser()
try parser.parse(args: Array(CommandLine.arguments.dropFirst()))

let result = try NoteBuilder(fileManager: .default).build(
    rootDirectory: URL(fileURLWithPath: parser.get(for: .rootDirectory)),
    sectionsDirectory: parser.get(for: .relativeSectionsDirectory),
    preambleCustomizationFileName: parser.get(for: .preambleCustomizationsPath),
    additionalInputs: parser.get(for: .additionalInputs),
    additionalInputsAfterBib: parser.get(for: .additionalInputsAfterBib),
    bibliographyFile: parser.get(for: .bibtexLibraryPath)
)

for warning in result.warnings {
    print("[WARNING]: \(warning)")
}

print("Result is located at \(result.result.path)")
