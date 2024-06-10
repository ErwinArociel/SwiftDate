import Foundation

// A class to hold associated values
private class AssociatedValue {
    weak var weakValue: AnyObject?
    var strongValue: Any?

    init(_ value: Any?) {
        self.strongValue = value
    }

	init(weak: AnyObject?) {
        self.weakValue = weak
	}

    var value: Any? {
        return weakValue ?? strongValue
}
}

// A dictionary to hold the associated values
private var associatedValues = [String: [ObjectIdentifier: AssociatedValue]]()

internal func getAssociatedValue<T>(key: String, object: AnyObject) -> T? {
    let identifier = ObjectIdentifier(object)
    return associatedValues[key]?[identifier]?.value as? T
}

internal func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: @autoclosure () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

internal func getAssociatedValue<T>(key: String, object: AnyObject, initialValue: () -> T) -> T {
    return getAssociatedValue(key: key, object: object) ?? setAndReturn(initialValue: initialValue(), key: key, object: object)
}

private func setAndReturn<T>(initialValue: T, key: String, object: AnyObject) -> T {
    set(associatedValue: initialValue, key: key, object: object)
    return initialValue
}

internal func set<T>(associatedValue: T?, key: String, object: AnyObject) {
    let identifier = ObjectIdentifier(object)
    if associatedValues[key] == nil {
        associatedValues[key] = [identifier: AssociatedValue(associatedValue)]
    } else {
        associatedValues[key]?[identifier] = AssociatedValue(associatedValue)
    }
}

internal func set<T: AnyObject>(weakAssociatedValue: T?, key: String, object: AnyObject) {
    let identifier = ObjectIdentifier(object)
    if associatedValues[key] == nil {
        associatedValues[key] = [identifier: AssociatedValue(weak: weakAssociatedValue)]
    } else {
        associatedValues[key]?[identifier] = AssociatedValue(weak: weakAssociatedValue)
    }
}

extension String {
    fileprivate var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(hashValue))!
    }
}
