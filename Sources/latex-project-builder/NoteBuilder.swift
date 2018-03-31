//
//  NoteBuilder.swift
//  latex-project-builder
//
//  Created by haritowa on 3/30/18.
//

import Foundation

struct NoteBuilder {
    enum Error: Swift.Error {
        case cantFindPreamble
        case cantCreateResultFile
        case cantFindContentForSection(URL)
        case sectionsFolderDoesNotExist
    }
    
    let fileManager: FileManager
    
    private func generatePreamble(rootDirectory: URL, customizationFileName: String) throws -> URL {
        let currentDirectory = rootDirectory.path
        
        let preamblePath = currentDirectory + "/preamble.tex"
        let customizationFilePath = currentDirectory + "/" + customizationFileName
        
        guard fileManager.fileExists(atPath: preamblePath) else {
            throw Error.cantFindPreamble
        }
        
        let preambleURL = URL(fileURLWithPath: preamblePath)
        guard fileManager.fileExists(atPath: customizationFilePath) else {
            return preambleURL
        }
        
        return try FileBuilder.build(for: fileManager, sourceFile: preambleURL, postface: [URL(fileURLWithPath: customizationFilePath)])
    }
    
    private func getMacrosURL(for folder: URL) -> URL? {
        let macrosURL = folder.appendingPathComponent("macros.tex")
        guard fileManager.fileExists(atPath: macrosURL.path) else {
            return nil
        }
        
        return macrosURL
    }
    
    private func isDirectory(input: URL) -> Bool {
        var isDirectory: ObjCBool = false
        _ = fileManager.fileExists(atPath: input.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    private func subsectionFileFilter(input: URL) throws -> Bool {
        let filename = input.lastPathComponent
        return !isDirectory(input: input) && filename.hasPrefix("subsection_") && filename.hasSuffix(".tex")
    }
    
    private func buildSection(at path: URL) throws -> URL {
        let contentURL = path.appendingPathComponent("content.tex")
        guard fileManager.fileExists(atPath: contentURL.path) else {
            throw Error.cantFindContentForSection(path)
        }
        
        let macrosURL = getMacrosURL(for: path)
        let subsections = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey])
            .filter(subsectionFileFilter)
        
        return try FileBuilder.build(for: fileManager, sourceFile: contentURL, preface: [macrosURL].compactMap { $0 }, postface: subsections)
    }
    
    private func buildSections(sectionsPath: URL) throws -> (compiledSections: [URL], warnings: [String]) {
        guard fileManager.fileExists(atPath: sectionsPath.path) else {
            throw Error.sectionsFolderDoesNotExist
        }
        
        let sections = try fileManager.contentsOfDirectory(at: sectionsPath, includingPropertiesForKeys: [.isDirectoryKey])
            .filter(isDirectory)
        
        var warnings = [String]()
        var compiledSections = [URL]()
        
        for section in sections {
            do {
                try compiledSections.append(buildSection(at: section))
            } catch (Error.cantFindContentForSection) {
                warnings.append("Skip \(section.lastPathComponent), can not find content.tex")
            }
        }
        
        return (compiledSections, warnings)
    }
    
    private func compilledSectionUrlToInputMapper(for url: URL) -> String {
        let componentsCount = url.pathComponents.count
        let folderPath = "\(url.pathComponents[componentsCount - 3])/\(url.pathComponents[componentsCount - 2])/"
        return FileBuilder.urlToInputMapper(prefix: folderPath, url: url)
    }
    
    private func buildAdditionalInputs(rootDirectory: URL, inputs: [String]) -> (result: String, warnings: [String]) {
        var result = ""
        var warnings = [String]()
        
        for input in inputs {
            let inputWithExtension = input.hasSuffix(".tex") ? input : input + ".tex"
            let inputURL = rootDirectory.appendingPathComponent(inputWithExtension)
            
            if fileManager.fileExists(atPath: inputURL.path) {
                result += FileBuilder.urlToInputMapper(for: inputURL) + "\n"
            } else {
                warnings.append("Can't find additional file \(inputWithExtension)")
            }
        }
        
        return (result, warnings)
    }
    
    func build(rootDirectory: URL, sectionsDirectory: String, preambleCustomizationFileName: String, additionalInputs: [String]) throws -> (result: URL, warnings: [String]) {
        let preamble = try FileBuilder.urlToInputMapper(for: generatePreamble(rootDirectory: rootDirectory, customizationFileName: preambleCustomizationFileName))
        let macros = getMacrosURL(for: rootDirectory).map(FileBuilder.urlToInputMapper) ?? ""
        
        let (sections, sectionsWarnings) = try buildSections(sectionsPath: rootDirectory.appendingPathComponent(sectionsDirectory))
        let sectionsString = sections.map(compilledSectionUrlToInputMapper).reduce("") { "\($0)\n  \($1)" }
        
        let (inputs, inputsWarnings) = buildAdditionalInputs(rootDirectory: rootDirectory, inputs: additionalInputs)
        
        let document =
        """
        \(preamble)
        \(macros)
        \\begin{document}
        \(inputs)
        \(sectionsString)
        \\end{document}
        """
        
        let resultFile = rootDirectory.appendingPathComponent("compiled.tex")
        guard fileManager.createFile(atPath: resultFile.path, contents: document.data(using: .utf8)) else {
            throw Error.cantCreateResultFile
        }
        
        return (resultFile, sectionsWarnings + inputsWarnings)
    }
}
