import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

import SwiftSyntax
import SwiftSyntaxMacros

import Foundation

/// An error with a description.
///
/// When printing such an error, its descrition is printed.
struct PipelineStepError: LocalizedError, CustomStringConvertible {

    private let message: String

    public init(_ message: String) {
        self.message = message
    }
    
    public var description: String { message }
    
    public var errorDescription: String? { message }
}

extension SyntaxStringInterpolation {
    
    mutating func appendInterpolation<Node: SyntaxProtocol>(
        _ node: Node,
        location: AbstractSourceLocation?,
        lineOffset: Int? = nil,
        close: Bool = true
    ) {
        if let location {
            let line = if let lineOffset {
                ExprSyntax("\(literal: Int(location.line.as(IntegerLiteralExprSyntax.self)?.literal.text ?? "0")! + lineOffset)")
            } else {
                location.line
            }
            var block = CodeBlockItemListSyntax {
                "#sourceLocation(file: \(location.file), line: \(line))"
                "\(node)"
            }
            if close {
                block.append("\n#sourceLocation()")
            }
            appendInterpolation(block)
        } else {
            appendInterpolation(node)
        }
    }
}

public struct StepMacro: BodyMacro {
    
    public static var formatMode: FormatMode { .disabled }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        if let arguments = node.arguments {
            [
                """
                execution.effectuate(\(raw: arguments), checking: StepID(crossModuleFileDesignation: #file, functionSignature: #function)) {
                \(declaration.body!.statements, location: context.location(of: declaration.body!.statements, at: .beforeLeadingTrivia, filePathMode: .filePath), lineOffset: 1)
                }
                """
            ]
        } else {
            [
                """
                execution.effectuate(checking: StepID(crossModuleFileDesignation: #file, functionSignature: #function)) {
                \(declaration.body!.statements, location: context.location(of: declaration.body!.statements, at: .beforeLeadingTrivia, filePathMode: .filePath), lineOffset: 1)
                }
                """
            ]
        }
    }
    
}
