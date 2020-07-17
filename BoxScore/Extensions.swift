//
//  Extensions.swift
//  StatTracker
//
//  Created by Kent Brady on 7/7/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
	func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
		if conditional {
			return AnyView(content(self))
		} else {
			return AnyView(self)
		}
	}
}

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
	
	func safeDivide(by number: Double) -> Double {
		if number == 0 {
			return 0
		}
		
		return self / number
	}
	
	func safeDivide(by number: Int) -> Double {
		safeDivide(by: Double(number))
	}
}

extension Int {
	var asDouble: Double { Double(self) }
	
	var asString: String { String(self) }
	
	func safeDivide(by number: Int) -> Double {
		Double(self).safeDivide(by: number)
	}
}

extension Bool {
	static func fromInt(_ int: Int?) -> Bool {
		return int != 0
	}
	
	var asInt: Int {
		return self ? 1 : 0
	}
}

extension String: Identifiable {
	public var id: String {
		return self.description
	}
}

extension Array where Element: Stat {
	func sumPoints() -> Int {
		return self.reduce(into: 0) { $0 += ($1.shotWasMake ? $1.pointsOfShot ?? 0 : 0) }
	}
}
