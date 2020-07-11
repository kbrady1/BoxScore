//
//  Extensions.swift
//  StatTracker
//
//  Created by Kent Brady on 7/7/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation

extension Double {
	var asString: String { String(self) }
	
	var asInt: Int { Int(self) }
	
	func formatted(decimal places: Int, dropZeroes: Bool = true) -> String {
		var stringVal = String(format: "%.\(places)f", self)
		
		//if everything after period is 0, remove those digits (and period)
		let split = stringVal.split(maxSplits: 1, omittingEmptySubsequences: true) { $0 == "." }
		if split.last?.allSatisfy({ $0 == "0" }) ?? false {
			stringVal.removeLast((split.last?.count ?? 0) + 1)
		}
		
		return stringVal
	}
}

extension Int {
	var asDouble: Double { Double(self) }
	
	var asString: String { String(self) }
}

extension Bool {
	static func fromInt(_ int: Int?) -> Bool {
		return int != 0
	}
	
	var asInt: Int {
		return self ? 1 : 0
	}
}
