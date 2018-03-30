//
//  FileBuilder.swift
//  latex-project-builder
//
//  Created by haritowa on 3/30/18.
//

import Foundation
import Basic
import Utility

//let parser = LatexBuilderArgumentParser()
//try parser.parse(args: Array(CommandLine.arguments.dropFirst()))

let fileManager = FileManager.default
//let url = URL(string: fileManager.currentDirectoryPath + "/content.tex")!
let url = URL(fileURLWithPath: "/Users/antonkharchenko/Development/University/Practice/latex-project-builder/.build/x86_64-apple-macosx10.10/debug/content.tex")

let preface1 = URL(string: fileManager.currentDirectoryPath + "/pr1.tex")!
let preface2 = URL(string: fileManager.currentDirectoryPath + "/pr2.tex")!

let postface1 = URL(string: fileManager.currentDirectoryPath + "/ps1.tex")!
let postface2 = URL(string: fileManager.currentDirectoryPath + "/ps2.tex")!

print(try FileBuilder.build(for: fileManager, sourceFile: url, preface: [preface1, preface2], postface: [postface2, postface1]))
