//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

// This data structure drives code generation
struct Arity {
    let value: Int
    let testValue: Int
    let name: String
}

enum FormattingPurpose {
    case forTemplateDeclaration
    case forWrappedFunctionClosure
    case forBoundFunctionArgs
    case forMethodArgsAsIntDecl
    case forArgsSum
}

func getCommaSeparatedString(count: Int, formattingPurpose: FormattingPurpose) -> String {
    guard count > 0 else {
        fatalError()
    }
    let argIndices = [Int](0...(count - 1))
    switch formattingPurpose {
    case .forTemplateDeclaration:
        // example: "A0, A1, A2, A3, ...."
        return argIndices.map({(element: Int) in String.init(format: "A%d", element)}).joined(separator: ", ")
    case .forWrappedFunctionClosure:
        // example: "arg0: A0, arg1: A1, arg2: A2, ..."
        return argIndices.map({(element: Int) in String.init(format: "arg%d: A%d", element, element)}).joined(separator: ", ")
    case .forBoundFunctionArgs:
        //example: "arg0, arg1, arg2, arg3, ..."
        return argIndices.map({(element: Int) in String.init(format: "arg%d", element)}).joined(separator: ", ")
    case .forMethodArgsAsIntDecl:
        // example: "arg0: Int, arg1: Int, arg2: Int, ..."
        return argIndices.map({(element: Int) in String.init(format: "arg%d: Int", element)}).joined(separator: ", ")
    case .forArgsSum:
        // example: "arg0 + arg1 + arg2 + arg3 ...."
        return argIndices.map({(element: Int) in String.init(format: "arg%d", element)}).joined(separator: " + ")
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Array {
    func takeAsString(count: Int) -> String {
        if let arityArray = self as? [Arity] {
            return arityArray[1...].prefix(count).map({(element: Arity) in String.init(format: "%d", element.testValue)}).joined(separator: ", ")
        }
        fatalError()
    }

    func takeAsSum(count: Int) -> Int {
        guard let arityArray = self as? [Arity],
            self.count > 1,
            count > 0,
            count <= self.count else {
                fatalError()
        }

        var total = 0
        for index in 1...count {
            total += arityArray[1...][index].testValue
        }
        return total
    }

    func takeAndMakeParamsWithCallable(count: Int) -> String {
        guard let arityArray = self as? [Arity],
            self.count >= count else {
                fatalError()
        }
        if count > 1 {
            var formattedParams =
                arityArray[1...].prefix(count-1).map({(element: Arity) in String.init(format: "%d", element.testValue)}).joined(separator: ", ")
            formattedParams.append(", make_callable(callback)")
            return formattedParams
        } else {
            return "make_callable(callback)"
        }
    }

    func getCallbackArgsForUnaryCallback(count: Int) -> String {
        guard self.count > 1 else {
                fatalError()
        }
        if 1 == count {
            return "arg0"
        } else {
            return getCommaSeparatedString(count: count, formattingPurpose: .forArgsSum)
        }
    }

    func getCallbackArgsForBinaryCallback(count: Int) -> String {
        guard let arityArray = self as? [Arity],
            self.count > 1 else {
                fatalError()
        }
        if 1 == count {
            return "\(arityArray[1...][count].testValue), \(arityArray[1...][count+1].testValue)"
        } else if 2 == count {
            return "arg0, \(arityArray[1...][count].testValue)"
        } else {
            var even = [Int]()
            var odd = [Int]()
            for index in 0..<count-1 {
                if index % 2 == 0 {
                    even.append(index)
                } else {
                    odd.append(index)
                }
            }
            let formattedEven = even.map({(element: Int) in String.init(format: "arg%d", element)}).joined(separator: " + ")
            let formattedOdd = odd.map({(element: Int) in String.init(format: "arg%d", element)}).joined(separator: " + ")
            return String.init(format: "%@, %@", formattedEven, formattedOdd)
        }
    }
}
