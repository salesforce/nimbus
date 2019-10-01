//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

// This data structure drives code generation
struct Arity {
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

enum FormattingBinaryCallback {
    case forPrimitiveNSArray
    case forPrimitiveNSDictionary
    case forNSArrayPrimitive
    case forNSArrayNSArray
    case forNSArrayNSDictionary
    case forNSDictionaryPrimitive
    case forNSDictionaryNSArray
    case forNSDictionaryNSDictionary
}

enum BinaryCallbackArgPosition {
    case first
    case second
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

    func takeAsSumOfBinaryCallback(position: BinaryCallbackArgPosition, count: Int) -> Int {
        guard let arityArray = self as? [Arity],
            self.count > 1,
            count > 0,
            count <= self.count else {
                fatalError()
        }

        var filteredValues = [Int]()
        for (index, arity) in arityArray[1...].prefix(count).enumerated() {
            if position == .first {
                if index % 2 == 0 {
                    filteredValues.append(arity.testValue)
                }
            } else {
                if index % 2 != 0 {
                    filteredValues.append(arity.testValue)
                }
            }
        }
        return filteredValues.reduce(0, +)
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
        guard let arityArray = self as? [Arity],
            self.count > 1 else {
                fatalError()
        }
        if 1 == count {
            return "\(arityArray[1...][count].testValue)"
        } else if 2 == count {
            return "arg0"
        } else {
            return getCommaSeparatedString(count: count - 1, formattingPurpose: .forArgsSum)
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

    // swiftlint:disable function_body_length cyclomatic_complexity
    func getCallbackArgsForBinaryCallbackWithFoundation(count: Int, formattingPurpose: FormattingBinaryCallback) -> String {
        guard let arityArray = self as? [Arity],
            self.count > 1 else {
                fatalError()
        }
        if formattingPurpose == .forNSArrayNSArray {
            return "arr0, arr1"
        } else if formattingPurpose == .forNSArrayNSDictionary {
            return "arr0, dict1"
        } else if formattingPurpose == .forNSDictionaryNSArray {
            return "dict0, arr1"
        } else if formattingPurpose == .forNSDictionaryNSDictionary {
            return "dict0, dict1"
        } else {
            if 1 == count {
                if formattingPurpose == .forNSArrayPrimitive {
                    return "arr0, \(arityArray[1...][count+1].testValue)"
                } else if formattingPurpose == .forNSDictionaryPrimitive {
                    return "dict0, \(arityArray[1...][count+1].testValue)"
                } else if formattingPurpose == .forPrimitiveNSArray {
                    return "\(arityArray[1...][count].testValue), arr1"
                } else if formattingPurpose == .forPrimitiveNSDictionary {
                    return "\(arityArray[1...][count].testValue), dict1"
                } else {
                    fatalError()
                }
            } else if 2 == count {
                if formattingPurpose == .forNSArrayPrimitive {
                    return "arr0, \(arityArray[1...][count].testValue)"
                } else if formattingPurpose == .forNSDictionaryPrimitive {
                    return "dict0, \(arityArray[1...][count].testValue)"
                } else if formattingPurpose == .forPrimitiveNSArray {
                    return "arg0, arr1"
                } else if formattingPurpose == .forPrimitiveNSDictionary {
                    return "arg0, dict1"
                } else {
                    fatalError()
                }
            } else {
                let forEven = (formattingPurpose == .forPrimitiveNSArray || formattingPurpose == .forPrimitiveNSDictionary)
                let argIndices = [Int](0...(count - 2))
                let filteredIndicies = argIndices.filter { (element: Int) -> Bool in
                    if forEven {
                        if element % 2 == 0 {
                            return true
                        } else {
                            return false
                        }
                    } else {
                        if element % 2 != 0 {
                            return true
                        } else {
                            return false
                        }
                    }
                }

                let formattedArgs = filteredIndicies.map({(element: Int) in String.init(format: "arg%d", element)}).joined(separator: " + ")
                var arg = ""
                if forEven {
                    if formattingPurpose == .forPrimitiveNSArray {
                        arg = "arr1"
                    } else {
                        arg = "dict1"
                    }
                    return String(format: "%@, %@", formattedArgs, arg)
                } else {
                    if formattingPurpose == .forNSArrayPrimitive {
                        arg = "arr0"
                    } else {
                        arg = "dict0"
                    }
                    return String(format: "%@, %@", arg, formattedArgs)
                }
            }
        }
    }
}
