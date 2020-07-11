//
//  Stat.swift
//  StatTracker
//
//  Created by Kent Brady on 5/12/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CoreGraphics

enum StatType: String {
	case shot, rebound, steal, turnover, block, assist, foul
	
	static var all: [StatType] {
		return [.shot, .rebound, .steal, .turnover, .block, .assist,  .foul]
	}
	
	func requiresPopUp() -> Bool {
		switch self {
		case .shot, .rebound:
			return true
		default:
			return false
		}
	}
	
	func abbreviation() -> String {
		switch self {
		case .shot:
			return "SHOT"
		case .rebound:
			return "REB"
		case .steal:
			return "STL"
		case .turnover:
			return "TO"
		case .block:
			return "BLK"
		case .assist:
			return "AST"
		case .foul:
			return "FOUL"
		}
	}
}

class Stat: Identifiable {
	init(type: StatType, player: Player) {
		self.type = type
		self.player = player
	}
	
	var type: StatType
	var player: Player
	var joinedStats = [Stat]()
	
	@Published var shotWasMake: Bool = false
	
	//This is a standardized location for distance percentage from origin
	var shotLocation: CGPoint?
	var assistedBy: Player? {
		didSet {
			guard let assistedBy = assistedBy else { return }
			joinedStats.append(Stat(type: .assist, player: assistedBy))
		}
	}
	@Published var pointsOfShot: Int?
	var rebounder: Player? {
		didSet {
			guard let rebounder = rebounder else { return }
			let stat = Stat(type: .rebound, player: rebounder)
			stat.offensiveRebound = true
			joinedStats.append(stat)
		}
	}
	
	var offensiveRebound: Bool = false
}

extension Stat {
	//These are simply for easy of creating test data
	
	static func nStats(for player: Player, n: Int, ofType type: StatType) -> [Stat] {
		Array(0..<n).map { (_) in
			Stat(type: type, player: player)
		}
	}
	
	static func nRebounds(for player: Player, n: Int, offensive: Bool) -> [Stat] {
		Stat.nStats(for: player, n: n, ofType: .rebound).map {
			$0.offensiveRebound = offensive
			return $0
		}
	}
	
	static func nShots(for player: Player, n: Int, make: Bool, points: Int) -> [Stat] {
		Stat.nStats(for: player, n: n, ofType: .shot).map {
			$0.pointsOfShot = points
			$0.shotWasMake = make
			$0.shotLocation = CGPoint(x: Int.random(in: 0..<300), y: Int.random(in: 0..<200))
			
			return $0
		}
	}
}
