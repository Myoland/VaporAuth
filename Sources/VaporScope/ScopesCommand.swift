//
//  File.swift
//  
//
//  Created by AFuture D. on 2022/7/20.
//

import Foundation
import Vapor

/// Print Route and Scope
///
/// Vappr run scope
public final class ScopesCommand: Command {
    public struct Signature: CommandSignature {
        public init() { }
    }
    
    public var help: String {
        return "Displays all routes' required scopes."
    }
    
    init() { }
    
    public func run(using context: CommandContext, signature: Signature) throws {
        let routes = context.application.routes
        let pathSeparator = "/".consoleText()
        let rows = routes.all.map { route -> [[ConsoleText]] in

            var lines: [[ConsoleText]] = []
            let desp = "\(route.responder)"
            let regex = "(?<=ScopeHelper\\(scopes: \\[\\\")[\\w].*?(?=\\\"\\])"
            let matchs = RegularExpression(regex: regex, validateString: desp)
            for (idx, match) in matchs.enumerated() {
                var column: [ConsoleText] = []
                column.append(route.method.string.consoleText())
                if route.path.isEmpty {
                    column.append(pathSeparator)
                } else {
                    column.append(route.path
                        .map { pathSeparator + $0.consoleText() }
                        .reduce("".consoleText(), +)
                    )
                }
                if idx != 0 {
                    column = ["".consoleText(), "".consoleText()]
                }
                column.append(match.consoleText())
                lines.append(column)
            }
            
            return lines
        }
        .reduce([], +)
        context.console.outputASCIITable(rows)
    }
}

extension PathComponent {
    func consoleText() -> ConsoleText {
        switch self {
        case .constant:
            return description.consoleText()
        default:
            return description.consoleText(.info)
        }
    }
}

extension Console {
    func outputASCIITable(_ rows: [[ConsoleText]]) {
        var columnWidths: [Int] = []
        
        // calculate longest columns
        for row in rows {
            for (i, column) in row.enumerated() {
                if columnWidths.count <= i {
                    columnWidths.append(0)
                }
                if column.description.count > columnWidths[i] {
                    columnWidths[i] = column.description.count
                }
            }
        }
        
        func hr() {
            var text: ConsoleText = ""
            for columnWidth in columnWidths {
                text += "+"
                text += "-"
                for _ in 0..<columnWidth {
                    text += "-"
                }
                text += "-"
            }
            text += "+"
            self.output(text)
        }
        
        for row in rows {
            if row[0].fragments[0].string.isEmpty != true {
                hr()
            }
            var text: ConsoleText = ""
            for (i, column) in row.enumerated() {
                text += "| "
                text += column
                for _ in 0..<(columnWidths[i] - column.description.count) {
                    text += " "
                }
                text += " "
            }
            text += "|"
            self.output(text)
        }
        
        hr()
    }
}

func RegularExpression (regex:String,validateString:String) -> [String]{
    do {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
        let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))
        
        var data:[String] = Array()
        for item in matches {
            let string = (validateString as NSString).substring(with: item.range)
            data.append(string)
        }
        
        return data
    }
    catch {
        return []
    }
}
