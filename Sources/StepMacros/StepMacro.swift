import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

import SwiftSyntax
import SwiftSyntaxMacros

//public struct StepMacro: BodyMacro {
//    public static func expansion(
//        of node: AttributeSyntax,
//        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [CodeBlockItemSyntax] {
//        guard
//            let functionDecl = declaration.as(FunctionDeclSyntax.self),
//            let body = functionDecl.body
//        else {
//            throw MacroError.message("Expected a function declaration with a body.")
//        }
//
//        if let newBody = AutoGuardSelfRewriter().rewrite(body).as(CodeBlockSyntax.self) {
//            return Array(newBody.statements)
//        } else {
//            throw MacroError.message("Failed to rewrite function body.")
//        }
//    }
//}
//
//final class AutoGuardSelfRewriter: SyntaxRewriter {
//    var shouldInsertGuardSelf: Bool? = nil
//
//    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
//        guard
//            let signature = node.signature,
//            let capture = signature.capture
//        else {
//            return super.visit(node)
//        }
//
//        let containsWeakSelfCapture = capture.items.contains {
//            $0.specifier?.specifier.text == "weak" &&
//            $0.expression.as(DeclReferenceExprSyntax.self)?.baseName.text == "self"
//        }
//
//        if containsWeakSelfCapture {
//            shouldInsertGuardSelf = true
//        }
//
//        return super.visit(node)
//    }
//
//    override func visit(_ node: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
//        guard shouldInsertGuardSelf == true else {
//            return super.visit(node)
//        }
//
//        shouldInsertGuardSelf = nil
//
//        let guardStmt = GuardStmtSyntax(
//            conditions: [
//                ConditionElementSyntax(
//                    condition: .optionalBinding(
//                        OptionalBindingConditionSyntax(
//                            bindingSpecifier: .keyword(.let),
//                            pattern: IdentifierPatternSyntax(identifier: .keyword(.`self`))
//                        )
//                    )
//                )
//            ],
//            body: CodeBlockSyntax(statements: [
//                CodeBlockItemSyntax(item: .stmt(StmtSyntax(ReturnStmtSyntax())))
//            ])
//        )
//
//        return [CodeBlockItemSyntax(item: .stmt(StmtSyntax(guardStmt)))] + node
//    }
//}
//
//enum MacroError: Error, CustomStringConvertible {
//    case message(String)
//
//    var description: String {
//        switch self {
//        case .message(let msg):
//            return msg
//        }
//    }
//}
//-----------

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
        return [
            """
            execution.effectuate(checking: StepID(crossModuleFileDesignation: #file, functionSignature: #function)) {
            \(declaration.body!.statements, location: context.location(of: declaration.body!.statements, at: .beforeLeadingTrivia, filePathMode: .filePath), lineOffset: 1)
            }
            """
        ]
    }
    
}
