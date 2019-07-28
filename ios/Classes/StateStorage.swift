//
//  StateStorage.swift
//  flutter_native_state
//
//  Created by Hugo Visser on 27/07/2019.
//
import Foundation

public class StateStorage {
    public static let instance = StateStorage()
    
    private var state: [String:Any] = [:]
    
    func update(state: [String: Any]) {
        self.state = state;
    }
    
    func get() -> [String: Any] {
        return self.state
    }
    
    public func save(coder: NSCoder) {
        NSDictionary(dictionary: ["flutter_state" : state]).encode(with: coder)
    }

    public func restore(coder: NSCoder) {
        self.state = NSDictionary(coder: coder)?.value(forKey: "flutter_state") as? [String : Any] ?? [:]
    }
    
    private init() {    
    }
}
