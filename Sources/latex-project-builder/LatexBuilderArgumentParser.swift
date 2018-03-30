//
//  FileBuilder.swift
//  latex-project-builder
//
//  Created by haritowa on 3/30/18.
//

import Utility

enum Argument: String {
    case rootDirectory
    case relativeSectionsDirectory // Relative to root
    case preambleCustomizationsPath
    case additionalInputs // Input latex files, that goes before sections
    
    var name: String {
        return "--\(self.rawValue)"
    }
    
    var shortName: String {
        let result: String
        
        switch self {
        case .rootDirectory: result = "-r"
        case .relativeSectionsDirectory: result = "-s"
        case .preambleCustomizationsPath: result = "-p"
        case .additionalInputs: result = "-i"
        }
        
        return result
    }
    
    var description: String {
        let result: String
        
        switch self {
        case .rootDirectory: result = "Root tex files directory(tex by default)"
        case .relativeSectionsDirectory: result = "Sections directory inside root directory(sections by default)"
        case .preambleCustomizationsPath: result = "Preamble customization file inside root directory(preamble-customization.tex by default)"
        case .additionalInputs: result = "Additional input files, that goes before sections, default are: title, abstract, table_of_contents, abbreviations"
        }
        
        return result
    }
    
    var completion: ShellCompletion? {
        switch self {
        case .preambleCustomizationsPath: return .filename
        default: return nil
        }
    }
}

final class LatexBuilderArgumentParser {
    private let argumentParser: ArgumentParser
    
    private let rootDirectoryParameter: OptionArgument<String>
    private let relativeSectionsDirectoryParameter: OptionArgument<String>
    private let preambleCustomizationsPathParameter: OptionArgument<String>
    private let additionalInputsParameter: OptionArgument<[String]>
    
    private var result: ArgumentParser.Result?
    
    static func add(argument: Argument, parser: ArgumentParser) -> OptionArgument<String> {
        return parser.add(
            option: argument.name,
            shortName: argument.shortName,
            kind: String.self,
            usage: nil,
            completion: argument.completion
        )
    }
    
    static func add(argument: Argument, parser: ArgumentParser) -> OptionArgument<[String]> {
        return parser.add(
            option: argument.name,
            shortName: argument.shortName,
            kind: [String].self,
            usage: nil,
            completion: argument.completion
        )
    }
    
    init() {
        argumentParser = ArgumentParser(commandName: "build", usage: "build [--rootDirectory tex --relativeSectionsDirectory sections --preambleCustomizationsPath preamble-customization.tex -- additionalInputs: ]", overview: "", seeAlso: nil)
        
        rootDirectoryParameter = LatexBuilderArgumentParser.add(argument: .rootDirectory, parser: argumentParser)
        relativeSectionsDirectoryParameter = LatexBuilderArgumentParser.add(argument: .relativeSectionsDirectory, parser: argumentParser)
        preambleCustomizationsPathParameter = LatexBuilderArgumentParser.add(argument: .preambleCustomizationsPath, parser: argumentParser)
        additionalInputsParameter = LatexBuilderArgumentParser.add(argument: .additionalInputs, parser: argumentParser)
    }
    
    func parse(args: [String]) throws {
        result = try argumentParser.parse(args)
    }
    
    private func getResult() -> ArgumentParser.Result {
        guard let result = result else { fatalError("Use parse before get invocation") }
        return result
    }
    
    func get(for argument: Argument) -> String {
        let result = getResult()
        
        switch argument {
        case .rootDirectory: return result.get(rootDirectoryParameter) ?? "tex"
        case .preambleCustomizationsPath: return result.get(preambleCustomizationsPathParameter) ?? "preamble-customization.tex"
        case .relativeSectionsDirectory: return result.get(relativeSectionsDirectoryParameter) ?? "sections"
        default: fatalError("User get(for:) -> [String]? for additionalInputs parameters")
        }
    }
    
    func get(for argument: Argument) -> [String] {
        let result = getResult()
        
        switch argument {
        case .additionalInputs: return result.get(additionalInputsParameter) ?? ["title", "abstract", "table_of_contents", "abbreviations"]
        default: fatalError("User get(for:) -> String? for \(argument.name) parameters")
        }
    }
}
