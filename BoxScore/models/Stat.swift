//
//  Stat.swift
//  StatTracker
//
//  Created by Kent Brady on 5/12/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CoreGraphics
import CloudKit

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
	
	static func fromString(_ str: String?) throws -> StatType {
		guard let str = str, let statType = StatType(rawValue: str) else {
			throw BoxScoreError.invalidModelError(message: "Received Invalid Stat Type")
		}
		
		return statType
	}
}

///This allows for the extra logic of creating new stats, and prevents those from being saved to the db until ready to add
class StatInput {
	init(type: StatType, player: PlayerCD, game: GameCD, team: TeamCD) {
		self.type = type
		self.game = game
		self.player = player
		self.team = team
	}
	
	var type: StatType
	var joinedStats = [StatInput]()
	
	@Published var shotWasMake: Bool = false
	
	//This is a standardized location for distance percentage from origin
	var shotLocation: CGPoint?
	var assistedBy: Player? {
		didSet {
			guard let assistedBy = assistedBy else { return }
			joinedStats.append(StatInput(type: .assist, player: assistedBy.model, game: game, team: team))
		}
	}
	@Published var pointsOfShot: Int?
	var rebounder: Player? {
		didSet {
			guard let rebounder = rebounder else { return }
			let stat = StatInput(type: .rebound, player: rebounder.model, game: game, team: team)
			stat.offensiveRebound = true
			joinedStats.append(stat)
		}
	}
	
	var offensiveRebound: Bool = false
	
	let game: GameCD
	let team: TeamCD
	let player: PlayerCD
	
	func toStat() -> Stat {
		let id = UUID()
		let model = StatCD(context: AppDelegate.context)
		
		model.game = game
		model.player = player
		model.team = team
		model.id = id
		model.reboundTypeOffensive = offensiveRebound
		model.shotTypeLocation = shotLocation?.toString()
		model.shotTypeMake = shotWasMake
		model.shotTypePoints = Int16(pointsOfShot ?? 0)
		model.statType = type.rawValue
		
		return Stat(player: player,
					statType: type,
					offensiveRebound: offensiveRebound,
					shotLocation: shotLocation,
					shotMake: shotWasMake,
					shotPoints: pointsOfShot,
					id: id.uuidString,
					model: model)
	}
}

class Stat: Identifiable {
	
	var type: StatType
	var shotWasMake: Bool = false
	//This is a standardized location for distance percentage from origin (0-100)
	var shotLocation: CGPoint?
	var pointsOfShot: Int?
	var offensiveRebound: Bool = false
	
	let id: String
	let model: StatCD
	let player: PlayerCD
	
	//MARK: RecordModel Properties
	
	fileprivate init(player: PlayerCD, statType: StatType, offensiveRebound: Bool?, shotLocation: CGPoint?, shotMake: Bool?, shotPoints: Int?, id: String, model: StatCD) {
		self.player = player
		
		self.type = statType
		self.offensiveRebound = offensiveRebound ?? false
		self.shotLocation = shotLocation
		self.shotWasMake = shotMake ?? false
		self.pointsOfShot = shotPoints
		
		self.id = id
		self.model = model
	}
	
	convenience init(model: StatCD) throws {
		guard let id = model.id,
			let player = model.player else { throw BoxScoreError.invalidModelError() }
				
		self.init(player: player,
				  statType: try StatType.fromString(model.statType),
				  offensiveRebound: model.reboundTypeOffensive,
				  shotLocation: try model.shotTypeLocation?.toPoint(),
				  shotMake: model.shotTypeMake,
				  shotPoints: Int(model.shotTypePoints),
				  id: id.uuidString,
				  model: model
		)
	}
}

fileprivate extension CGPoint {
	static func from(_ stringList: [String]) throws -> CGPoint {
		let points = stringList.compactMap { Double($0) }
		guard points.count == 2 else {
			throw BoxScoreError.invalidModelError()
		}
		
		return CGPoint(x: points[0], y: points[1])
	}
	
	func toString() -> String {
		"\(self.x)-\(self.y)"
	}
}

fileprivate extension String {
	func toPoint() throws -> CGPoint {
		try CGPoint.from(self.split(separator: "-").map { "\($0)" })
	}
}
