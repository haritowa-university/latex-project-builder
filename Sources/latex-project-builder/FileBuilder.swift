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
        return "\\input{\(prefix)\(url.deletingPathExtension().lastPathComponent)}"
    }
    
    static func urlToInputMapper(for url: URL) -> String {
        return urlToInputMapper(prefix: "", url: url)
    }
    
    static func urlToInputMapper(prefix: String) -> (URL) -> String {
        return { urlToInputMapper(prefix: prefix, url: $0) }
    }
    
    private static func generateIncludeCommand(for fileManager: FileManager, url: URL, sourceFilePathPrefix: String) throws -> String {
        guard fileManager.fileExists(atPath: url.path) else { throw Error.accomodationNotFound(url: url) }
        return urlToInputMapper(prefix: sourceFilePathPrefix, url: url)
    }
    
    private static func relaxClearPage(for content: String) -> String {
        guard !content.isEmpty else { return content }
        return
            """
            \\begingroup
            \\let\\clearpage\\relax
            \(content)
            \\endgroup
            """
    }
    
    static func build(for fileManager: FileManager, sourceFile: URL, sourceFilePathPrefix: String, preface: [URL] = [], postface: [URL] = [], prefaceShouldRelaxClearpage: Bool = false, postfaceShouldRelaxClearpage: Bool = false) throws -> URL {
        guard fileManager.fileExists(atPath: sourceFile.path) else { throw Error.sourceFileNotFound(url: sourceFile) }
        
        var prefaceString = try preface.reduce("") { (acc, url) in acc + (try generateIncludeCommand(for: fileManager, url: url, sourceFilePathPrefix: sourceFilePathPrefix)) }
        var postfaceString = try postface.reduce("") { (acc, url) in acc + (try generateIncludeCommand(for: fileManager, url: url, sourceFilePathPrefix: sourceFilePathPrefix)) }
        
        if prefaceShouldRelaxClearpage {
            prefaceString = FileBuilder.relaxClearPage(for: prefaceString)
        }
        
        if postfaceShouldRelaxClearpage {
            postfaceString = FileBuilder.relaxClearPage(for: postfaceString)
        }
        
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
