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
    additionalInputs: parser.get(for: .additionalInputs)
)

print("Result is located at \(result.result.path)")

if let stdout = stdoutStream as? LocalFileOutputByteStream {
    let tc = TerminalController(stream: stdout)

    for warning in result.warnings {
        tc?.write("[WARNING]: \(warning) \n", inColor: .yellow)
    }
}
