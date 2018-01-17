import Foundation


/// Attribution to:
/// http://stackoverflow.com/questions/28633703/insertion-order-dictionary-like-javas-linkedhashmap-in-swift
/// With following updates:
/// - Fix syntax from Swift 1.0 to 2.0 to 3.0
/// - Add method to sort the keys
/// - Make the class and methods public to be used in a library providing helper to other components.

// OrderedDictionary behaves like a Dictionary except that it maintains the insertion order of the keys,
// so iteration order matches insertion order.
public struct OrderedDictionary<KeyType:Hashable, ValueType> : CustomStringConvertible {
    fileprivate var _dictionary:Dictionary<KeyType, ValueType>
    fileprivate var _keys:Array<KeyType>

    public init() {
        _dictionary = [:]
        _keys = []
    }

    public init(minimumCapacity:Int) {
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity:minimumCapacity)
        _keys = Array<KeyType>()
    }

    public init(_ dictionary:Dictionary<KeyType, ValueType>) {
        _dictionary = dictionary
        _keys = [KeyType](dictionary.keys)
    }

    public init(_ orderedDictionary: OrderedDictionary<KeyType, ValueType>){
        _dictionary = orderedDictionary._dictionary
        _keys = orderedDictionary._keys
    }

    public subscript(key:KeyType) -> ValueType? {
        get {
            return _dictionary[key]
        }
        set {
            if newValue == nil {
                self.removeValue(forKey: key)
            }
            else {
                let _ = self.updateValue(value: newValue!, forKey: key)
            }
        }
    }

    public mutating func updateValue(value:ValueType, forKey key:KeyType) -> ValueType? {
        let oldValue = _dictionary.updateValue(value, forKey: key)
        if oldValue == nil {
            _keys.append(key)
        }
        return oldValue
    }

    public mutating func removeValue(forKey:KeyType) {
        _keys = _keys.filter { $0 != forKey }
        _dictionary.removeValue(forKey: forKey)
    }

    public mutating func removeAll(keepCapacity:Int) {
        _keys = []
        _dictionary = Dictionary<KeyType,ValueType>(minimumCapacity: keepCapacity)
    }

    public mutating func sortKeys( isOrderedBefore: (KeyType, KeyType) -> Bool) {
        _keys.sort(by: isOrderedBefore)
    }

    public var count: Int { get { return _dictionary.count } }

    // keys isn't lazy evaluated because it's just an array anyway
    public var keys:[KeyType] { get { return _keys } }

    // values is lazy evaluated because of the dictionary lookup and creating a new array
    public var values:AnyIterator<ValueType> {
        get {
            var index = 0
            return AnyIterator({ () -> ValueType? in
                if index >= self._keys.count {
                    return nil
                }
                else {
                    let key = self._keys[index]
                    index += 1
                    return self._dictionary[key]
                }
            })
        }
    }

    public var description : String {
        var result = [String]();
        for (key, val) in self {
            result.append("\"\(key)\" : \"\(val)\"");
        }

        return result.joined(separator: ", ");
    }
}

extension OrderedDictionary : Sequence {
    public func makeIterator() -> AnyIterator<(KeyType, ValueType)> {
        var index = 0
        return AnyIterator({ () -> (KeyType, ValueType)? in
            if index >= self._keys.count {
                return nil
            }
            else {
                let key = self._keys[index]
                index += 1
                return (key, self._dictionary[key]!)
            }
        })
    }
}