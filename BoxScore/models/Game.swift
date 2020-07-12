//
//  Game.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CoreGraphics
import CloudKit

extension DateFormatter {
	static func defaultDateFormat(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = format
		return formatter
	}
}

private let DATE_FORMATTER = DateFormatter.defaultDateFormat("MMM dd, yyyy")

class Game: ObservableObject, Equatable, RecordModel {

	init(team: Team) {
		self.team = team
		self.playersInGame = []
		self.playersOnBench = team.players
		self.endDate = Date()
		self.opponentName = "Opponent"
		self.teamId = team.id
		
		self.record = CKRecord(recordType: GameSchema.TYPE)
		self.playerIdsInGame = []
		self.teamScore = 0
		self.opponentScore = 0
	}
	
	var id: String { record.recordID.recordName }
	
	@Published var teamScore: Int {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	@Published var opponentScore: Int {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	var opponentName: String {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	var teamId: String
	var playerIdsInGame: [String] {
		didSet {
			CloudManager.shared.addRecordToSave(record: recordToSave())
		}
	}
	
	var endDate: Date?
	@Published var team: Team
	@Published var playersInGame: [Player]
	@Published var playersOnBench: [Player]
	
	var dateText: String? {
		guard let endDate = endDate else { return nil }
		return DATE_FORMATTER.string(from: endDate)
	}
	
	@Published var hasBegun: Bool = false {
		didSet {
			//Once the game starts, move any team players not on the floor to the bench
			playersOnBench = team.players.filter { !playersInGame.contains($0) }
		}
	}
	@Published var isComplete: Bool = false
	
	var statDictionary = [StatType: [Stat]]()
	@Published var statCounter = [StatType: Int]()
	
	//MARK: RecordModel
	
	static func createGame(teamId: String) -> Game {
		return Game(teamId: teamId, record: CKRecord(recordType: GameSchema.TYPE))
	}
	
	func start() {
		hasBegun = true
		CloudManager.shared.addRecordToSave(record: recordToSave())
	}
	
	init(teamId: String, playersInGame: [String] = [], hasEnded: Bool? = nil, endDate: Date? = nil, opponentName: String? = nil, opponentScore: Int? = nil, teamScore: Int? = nil, record: CKRecord) {
		self.teamId = teamId
		self.playerIdsInGame = playersInGame
		self.isComplete = hasEnded ?? false
		self.endDate = endDate
		self.teamScore = teamScore ?? 0
		self.opponentScore = opponentScore ?? 0
		self.opponentName = opponentName ?? "Opponent"
		self.record = record
		
		self.team = Team()
		self.playersInGame = []
		self.playersOnBench = []
	}
	
	required convenience init(record: CKRecord) throws {
		guard let teamId = record.value(forKey: GameSchema.TEAM) as? CKRecord.Reference else { throw BoxScoreError.invalidModelError() }
		
		self.init(teamId: teamId.recordID.recordName,
				  playersInGame: ((record.value(forKey: GameSchema.PLAYERS_IN_GAME) as? [CKRecord.Reference]) ?? []).map { $0.recordID.recordName } ,
				  hasEnded: Bool.fromInt(record.value(forKey: GameSchema.HAS_ENDED) as? Int),
				  endDate: record.value(forKey: GameSchema.DATE) as? Date,
				  opponentName: record.value(forKey: GameSchema.OPPONENT) as? String,
				  opponentScore: record.value(forKey: GameSchema.OPPONENT_SCORE) as? Int,
				  teamScore: record.value(forKey: GameSchema.SCORE) as? Int,
				  record: record)
	}
	
	var record: CKRecord
	
	func recordToSave() -> CKRecord {
		record.setValue(CKRecord.Reference(recordID: CKRecord.ID(recordName: teamId), action: .deleteSelf), forKey: GameSchema.TEAM)
		record.setValue(opponentName, forKey: GameSchema.OPPONENT)
		record.setValue(opponentScore, forKey: GameSchema.OPPONENT_SCORE)
		record.setValue(teamScore, forKey: GameSchema.SCORE)
		record.setValue(endDate, forKey: GameSchema.DATE)
		record.setValue(isComplete, forKey: GameSchema.HAS_ENDED)
		record.setValue(playerIdsInGame.map { CKRecord.Reference(recordID: CKRecord.ID(recordName: $0), action: .deleteSelf) }, forKey: GameSchema.PLAYERS_IN_GAME)
		
		return record
	}
	
	func swapPlayers(fromBench benchPlayer: Player?, toLineUp playerOnCourt: Player?) {
		if let benchPlayer = benchPlayer,
			let benchIndex = playersOnBench.firstIndex(of: benchPlayer) {
			
			playersOnBench.remove(at: benchIndex)
			playersInGame.append(benchPlayer)
			
			if let playerOnCourt = playerOnCourt {
				playersOnBench.insert(playerOnCourt, at: benchIndex)
			}
		} else if let playerOnCourt = playerOnCourt,
			let courtIndex = playersInGame.firstIndex(of: playerOnCourt) {
			//If benchPlayer was nil and playerOnCourt isn't
			playersInGame.remove(at: courtIndex)
			playersOnBench.insert(playerOnCourt, at: 0)
		}
	}
	
	func recordStat(_ stat: Stat) {
		stat.joinedStats.forEach {
			self.recordStat($0)
		}
		
		if statDictionary[stat.type] == nil {
			statDictionary[stat.type] = []
		}
		
		statDictionary[stat.type]?.append(stat)
		statCounter[stat.type] = (statCounter[stat.type] ?? 0) + 1
		
		switch stat.type {
		case .shot:
			if stat.shotWasMake {
				teamScore += stat.pointsOfShot ?? 0
			}
		default:
			//Do nothing
			break
		}
	}
	
	//MARK: Equatable
	
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
}

extension Game {
	static var previewData: LiveGame {
		return LiveGame(team: Team.testData, game: Game(team: Team.testData))
	}
	
	static var statTestData: Game {
		let team = Team.testData
		
		let game = Game(team: team)
		
		[team.kukoc, team.pippen, team.longley,
		 team.jordan, team.harper, team.rodman,
		 team.kerr, team.burrell, team.buechler,
		 team.wennington]
			.reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
			.forEach { game.recordStat($0) }
		
		game.opponentScore = 86
		return game
	}
	
	static func testGame(opponentScore: Int) -> Game {
		let team = Team.testData
		
		let game = Game(team: team)
		[team.kukoc, team.pippen, team.buechler,
		 team.wennington]
			.reduce(into: [Stat]()) { $0.append(contentsOf: $1) }
			.forEach { game.recordStat($0) }
		
		game.opponentScore = opponentScore
		return game
	}
}

class GameList: ObservableObject {
	@Published var games: [Game]
	
	init(_ games: [Game]) {
		self.games = games
	}
	
	init(_ game: Game) {
		self.games = [game]
	}
}
