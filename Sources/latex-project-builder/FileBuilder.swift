//
//  FileBuilder.swift
//  latex-project-builder
//
//  Created by haritowa on 3/30/18.
//

import Foundation

struct FileBuilder {
    enum Error: Swift.Error {
        case sourceFileNotFound(url: URL)
        case accomodationNotFound(url: URL)
        case cantCreateFile(url: URL)
    }
    
    static func urlToInputMapper(prefix: String, url: URL) -> String {
        return "\\input{\(prefix)\(url.lastPathComponent)}"
    }
    
    static func urlToInputMapper(for url: URL) -> String {
        return urlToInputMapper(prefix: "", url: url)
    }
    
    static func urlToInputMapper(prefix: String) -> (URL) -> String {
        return { urlToInputMapper(prefix: prefix, url: $0) }
    }
    
    private static func generateIncludeCommand(for fileManager: FileManager, url: URL) throws -> String {
        guard fileManager.fileExists(atPath: url.path) else { throw Error.accomodationNotFound(url: url) }
        return urlToInputMapper(for: url)
    }
    
    static func build(for fileManager: FileManager, sourceFile: URL, preface: [URL] = [], postface: [URL] = []) throws -> URL {
        guard fileManager.fileExists(atPath: sourceFile.path) else { throw Error.sourceFileNotFound(url: sourceFile) }
        
        let prefaceString = try preface.reduce("") { (acc, url) in acc + (try generateIncludeCommand(for: fileManager, url: url)) }
        let postfaceString = try postface.reduce("") { (acc, url) in acc + (try generateIncludeCommand(for: fileManager, url: url)) }
        
        let originalContent = try String(contentsOf: sourceFile)
        let resultContent = "\(prefaceString)\n\(originalContent)\n\(postfaceString)"
        
        let sourceFolder = sourceFile.deletingLastPathComponent().path
        let newFileName = sourceFile.deletingPathExtension().lastPathComponent + "-compiled.tex"
        
        let newFilePath = "\(sourceFolder)/\(newFileName)"
        let resultURL = URL(fileURLWithPath: newFilePath)
        
        guard fileManager.createFile(atPath: newFilePath, contents: resultContent.data(using: .utf8), attributes: nil) else {
            throw Error.cantCreateFile(url: resultURL)
        }
        
        return resultURL
    }
}
