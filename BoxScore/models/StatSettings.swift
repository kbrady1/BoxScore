//
//  StatSettings.swift
//  StatTracker
//
//  Created by Kent Brady on 5/12/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation

let HAS_SEEN_TOUR_KEY = "hasSeenNewUserTour"
let GESTURE_FOR_DIRECTION_KEY = "userSettingGestureForDirection"

class StatSettings: ObservableObject {
	
	init() {
		needsToSeeTour = !UserDefaults.standard.bool(forKey: HAS_SEEN_TOUR_KEY)
	
		leftGesture = Self.getSavedStat(for: .left) ?? .rebound
		rightGesture = Self.getSavedStat(for: .right) ?? .steal
		upGesture = Self.getSavedStat(for: .up) ?? .turnover
		downGesture = Self.getSavedStat(for: .down) ?? .shot
	}
	
	var statByDirection = [MoveDirection: StatType]()
	@Published var needsToSeeTour: Bool
	@Published var leftGesture: StatType {
		didSet {
			save(stat: leftGesture, for: .left)
		}
	}
	@Published var rightGesture: StatType {
		   didSet {
			   save(stat: rightGesture, for: .right)
		   }
	   }
	@Published var upGesture: StatType {
		   didSet {
			   save(stat: upGesture, for: .up)
		   }
	   }
	@Published var downGesture: StatType {
		   didSet {
			   save(stat: downGesture, for: .down)
		   }
	   }
	
	var statsNotInDirection: [(String, StatType)] {
		allStats
			.filter { $0.1 != leftGesture }
			.filter { $0.1 != rightGesture }
			.filter { $0.1 != upGesture }
			.filter { $0.1 != downGesture }
	}
	
	var allStats: [(String, StatType)] {
		StatType.all
			.map { ($0.abbreviation(), $0) }
	}
	
	func getStat(for direction: MoveDirection) -> StatType {
		switch (direction) {
		case .up:
			return upGesture
		case .down:
			return downGesture
		case .left:
			return leftGesture
		case .right:
			return rightGesture
		}
	}
	
	func recordTour() {
		UserDefaults.standard.set(true, forKey: HAS_SEEN_TOUR_KEY)
	}
	
	private static func getSavedStat(for direction: MoveDirection) -> StatType? {
		if let abbreviation = UserDefaults.standard.value(forKey: GESTURE_FOR_DIRECTION_KEY + direction.rawValue) as? String {
			return StatType.all.first { abbreviation == $0.abbreviation() }
		}
		
		return nil
	}
	
	func save(stat: StatType, for direction: MoveDirection) {
		UserDefaults.standard.set(stat.abbreviation(), forKey: GESTURE_FOR_DIRECTION_KEY + direction.rawValue)
	}
}
