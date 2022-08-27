import Foundation

@dynamicMemberLookup
public struct WritableProxy<Object> {
    let object: Object

    public subscript <V>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, V>) -> (V) -> Self {
        return { newValue in
            object[keyPath: keyPath] = newValue
            return self
        }
    }

    public func resolve() -> Object {
        object
    }
}

public protocol ReferenceWritableProxy: AnyObject {}

extension ReferenceWritableProxy {
    public var proxy: WritableProxy<Self> { .init(object: self) }
}

extension NSObject: ReferenceWritableProxy {}
