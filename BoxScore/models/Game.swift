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
	
	var id: String { record.recordID.recordName }
	
	private var started: Bool = false
	
	@Published var teamScore: Int {
		didSet {
			saveIfStarted()
		}
	}
	@Published var opponentScore: Int {
		didSet {
			saveIfStarted()
		}
	}
	var opponentName: String {
		didSet {
			saveIfStarted()
		}
	}
	var teamId: String
	var playerIdsInGame: [String] {
		didSet {
			saveIfStarted()
		}
	}
	
	var endDate: Date?
	
	var dateText: String? {
		guard let endDate = endDate else { return nil }
		return DATE_FORMATTER.string(from: endDate)
	}
	
	@Published var isComplete: Bool {
		didSet {
			endDate = Date()
			saveIfStarted(instant: true)
		}
	}
	
	private func saveIfStarted(instant: Bool = false) {
		if started {
			CloudManager.shared.addRecordToSave(record: recordToSave(), instantSave: instant)
		}
	}
	
	//These are used on the live game and live game stat view to keep track of a teams current stats
	var statDictionary = [StatType: [Stat]]()
	@Published var statCounter = [StatType: Int]()
	
	//MARK: RecordModel
	
	static func createGame(teamId: String) -> Game {
		return Game(teamId: teamId, record: CKRecord(recordType: GameSchema.TYPE))
	}
	
	func start() {
		started = true
		CloudManager.shared.addRecordToSave(record: recordToSave(), instantSave: true)
	}
	
	private init(teamId: String, playersInGame: [String] = [], hasEnded: Bool? = nil, endDate: Date? = nil, opponentName: String? = nil, opponentScore: Int? = nil, teamScore: Int? = nil, record: CKRecord) {
		self.teamId = teamId
		self.playerIdsInGame = playersInGame
		self.isComplete = hasEnded ?? false
		self.endDate = endDate
		self.teamScore = teamScore ?? 0
		self.opponentScore = opponentScore ?? 0
		self.opponentName = opponentName ?? "Opponent"
		self.record = record
	}
	
	var model: GameCD? = nil
	init(model: GameCD) throws {
		self.model = model
		
		guard let teamId = model.team?.id?.uuidString else { throw BoxScoreError.invalidModelError() }
		
		self.teamId = teamId
		self.isComplete = model.hasEnded
		self.opponentName = model.opponentName ?? "Opponent"
		self.opponentScore = Int(model.opponentScore)
		self.teamScore = Int(model.teamScore)
		self.playerIdsInGame = model.playersInGame?.allObjects.compactMap { $0 as? PlayerCD }.compactMap { $0.id?.uuidString } ?? []
		
		self.record = CKRecord(recordType: GameSchema.TYPE)
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
	
	//MARK: Equatable
	
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
}

class GameList: ObservableObject {
	@Published var games: [Game]
	var statDictionary = [StatType: [Stat]]()
	
	init(_ games: [Game]) {
		self.games = games
	}
	
	init(_ game: Game) {
		self.games = [game]
	}
}
