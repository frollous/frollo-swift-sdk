import Foundation

/**
 A type-erased `Decodable` value.
 
 The `AnyDecodable` type forwards decoding responsibilities
 to an underlying value, hiding its specific underlying type.
 
 You can decode mixed-type values in dictionaries
 and other collections that require `Decodable` conformance
 by declaring their contained type to be `AnyDecodable`:
 
     let json = """
     {
         "boolean": true,
         "integer": 1,
         "double": 3.14159265358979323846,
         "string": "string",
         "array": [1, 2, 3],
         "nested": {
             "a": "alpha",
             "b": "bravo",
             "c": "charlie"
         }
     }
     """.data(using: .utf8)!
 
     let decoder = JSONDecoder()
     let dictionary = try! decoder.decode([String: AnyCodable].self, from: json)
 */
public struct AnyDecodable: Decodable {
    public let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

#if swift(>=4.2)
@usableFromInline
protocol _AnyDecodable {
    var value: Any { get }
    init<T>(_ value: T?)
}

#else
protocol _AnyDecodable {
    var value: Any { get }
    init<T>(_ value: T?)
}
#endif

extension AnyDecodable: _AnyDecodable {}

extension _AnyDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
}

extension AnyDecodable: Equatable {
    public static func == (lhs: AnyDecodable, rhs: AnyDecodable) -> Bool {
        switch (lhs.value, rhs.value) {
            case is (NSNull, NSNull), is (Void, Void):
                return true
            case (let lhs as Bool, let rhs as Bool):
                return lhs == rhs
            case (let lhs as Int, let rhs as Int):
                return lhs == rhs
            case (let lhs as Int8, let rhs as Int8):
                return lhs == rhs
            case (let lhs as Int16, let rhs as Int16):
                return lhs == rhs
            case (let lhs as Int32, let rhs as Int32):
                return lhs == rhs
            case (let lhs as Int64, let rhs as Int64):
                return lhs == rhs
            case (let lhs as UInt, let rhs as UInt):
                return lhs == rhs
            case (let lhs as UInt8, let rhs as UInt8):
                return lhs == rhs
            case (let lhs as UInt16, let rhs as UInt16):
                return lhs == rhs
            case (let lhs as UInt32, let rhs as UInt32):
                return lhs == rhs
            case (let lhs as UInt64, let rhs as UInt64):
                return lhs == rhs
            case (let lhs as Float, let rhs as Float):
                return lhs == rhs
            case (let lhs as Double, let rhs as Double):
                return lhs == rhs
            case (let lhs as String, let rhs as String):
                return lhs == rhs
            case (let lhs as [String: AnyDecodable], let rhs as [String: AnyDecodable]):
                return lhs == rhs
            case (let lhs as [AnyDecodable], let rhs as [AnyDecodable]):
                return lhs == rhs
            default:
                return false
        }
    }
}

extension AnyDecodable: CustomStringConvertible {
    public var description: String {
        switch value {
            case is Void:
                return String(describing: nil as Any?)
            case let value as CustomStringConvertible:
                return value.description
            default:
                return String(describing: value)
        }
    }
}

extension AnyDecodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
            case let value as CustomDebugStringConvertible:
                return "AnyDecodable(\(value.debugDescription))"
            default:
                return "AnyDecodable(\(description))"
        }
    }
}
