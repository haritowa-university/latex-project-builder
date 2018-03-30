import Foundation
import Basic
import Utility

let parser = LatexBuilderArgumentParser()
try parser.parse(args: Array(CommandLine.arguments.dropFirst()))
