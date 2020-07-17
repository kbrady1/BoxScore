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

class Stat: Identifiable, RecordModel {
	init(type: StatType, playerId: String, gameId: String, teamId: String) {
		self.type = type
		self.teamId = teamId
		self.gameId = gameId
		self.playerId = playerId
		self.record = CKRecord(recordType: StatSchema.TYPE)
	}
	
	var type: StatType
	var teamId: String
	var gameId: String
	var playerId: String
	var joinedStats = [Stat]()
	
	@Published var shotWasMake: Bool = false
	
	//This is a standardized location for distance percentage from origin
	var shotLocation: CGPoint?
	var assistedBy: Player? {
		didSet {
			guard let assistedBy = assistedBy else { return }
			joinedStats.append(Stat(type: .assist, playerId: assistedBy.id, gameId: gameId, teamId: teamId))
		}
	}
	@Published var pointsOfShot: Int?
	var rebounder: Player? {
		didSet {
			guard let rebounder = rebounder else { return }
			let stat = Stat(type: .rebound, playerId: rebounder.id, gameId: gameId, teamId: teamId)
			stat.offensiveRebound = true
			joinedStats.append(stat)
		}
	}
	
	var offensiveRebound: Bool = false
	
	//MARK: RecordModel Properties
	
	init(teamId: String, playerId: String, gameId: String, statType: StatType, offensiveRebound: Bool?, shotLocation: CGPoint?, shotMake: Bool?, shotPoints: Int?, record: CKRecord) {
		self.teamId = teamId
		self.playerId = playerId
		self.gameId = gameId
		self.type = statType
		self.offensiveRebound = offensiveRebound ?? false
		self.shotLocation = shotLocation
		self.shotWasMake = shotMake ?? false
		self.pointsOfShot = shotPoints
		self.record = record
	}
	
	required convenience init(record: CKRecord) throws {
		guard let teamId = record.value(forKey: StatSchema.TEAM_ID) as? CKRecord.Reference,
			let playerId = record.value(forKey: StatSchema.PLAYER_ID) as? CKRecord.Reference,
			let gameId = record.value(forKey: StatSchema.GAME_ID) as? CKRecord.Reference else {
				throw BoxScoreError.invalidModelError()
		}
		
		let point = record.value(forKey: StatSchema.SHOT_LOCATION) as? [Double]
		
		self.init(teamId: teamId.recordID.recordName,
				  playerId: playerId.recordID.recordName,
				  gameId: gameId.recordID.recordName,
				  statType: try StatType.fromString(record.value(forKey: StatSchema.STAT_TYPE) as? String),
				  offensiveRebound: Bool.fromInt(record.value(forKey: StatSchema.REBOUND) as? Int),
				  shotLocation: CGPoint(x: point?.first ?? 0.0,
										y: point?.last ?? 0.0),
				  shotMake: Bool.fromInt(record.value(forKey: StatSchema.SHOT_MAKE) as? Int),
				  shotPoints: record.value(forKey: StatSchema.SHOT_POINTS) as? Int,
				  record: record)
	}
	
	var record: CKRecord
	
	func recordToSave() -> CKRecord {
		record.setValue(CKRecord.Reference(recordID: CKRecord.ID(recordName: gameId), action: .deleteSelf), forKey: StatSchema.GAME_ID)
		record.setValue(CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf), forKey: StatSchema.TEAM_ID)
		record.setValue(CKRecord.Reference(recordID: CKRecord.ID(recordName: playerId), action: .deleteSelf), forKey: StatSchema.PLAYER_ID)
		record.setValue(type.rawValue, forKey: StatSchema.STAT_TYPE)
		record.setValue(offensiveRebound, forKey: StatSchema.REBOUND)
		record.setValue([shotLocation?.x ?? 0.0, shotLocation?.y ?? 0.0].map { Double($0) }, forKey: StatSchema.SHOT_LOCATION)
		record.setValue(shotWasMake, forKey: StatSchema.SHOT_MAKE)
		record.setValue(pointsOfShot, forKey: StatSchema.SHOT_POINTS)
		
		return record
	}
}
