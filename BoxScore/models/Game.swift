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

class Game: ObservableObject, Equatable {
	
	@Published var teamScore: Int {
		didSet {
			save()
		}
	}
	@Published var opponentScore: Int {
		didSet {
			save()
		}
	}
	var opponentName: String {
		didSet {
			save()
		}
	}
	
	var positionA: Player? {
		   didSet {
			   save()
		   }
	   }
	var positionB: Player? {
		   didSet {
			   save()
		   }
	   }
	var positionC: Player? {
		   didSet {
			   save()
		   }
	   }
	var positionD: Player? {
		   didSet {
			   save()
		   }
	   }
	var positionE: Player? {
		   didSet {
			   save()
		   }
	   }
	
	var playersInGame: [Player] {
		[positionA, positionB, positionC, positionD, positionE].compactMap { $0 }
	}
	
	var endDate: Date?
	var startDate: Date?
	
	var dateText: String? {
		guard let endDate = endDate else { return nil }
		return DATE_FORMATTER.string(from: endDate)
	}
	
	@Published var isComplete: Bool {
		didSet {
			guard isComplete else { return }
			endDate = Date()
			positionA = nil
			positionB = nil
			positionC = nil
			positionD = nil
			positionE = nil
			save()
		}
	}
	
	private func save() {
		model.endDate = endDate
		model.hasEnded = isComplete
		model.opponentName = opponentName
		model.opponentScore = Int16(opponentScore)
		model.teamScore = Int16(teamScore)
		model.positionA = positionA?.model
		model.positionE = positionE?.model
		model.positionD = positionD?.model
		model.positionC = positionC?.model
		model.positionB = positionB?.model
		
		AppDelegate.instance.saveContext()
	}
	
	//These are used on the live game and live game stat view to keep track of a teams current stats
	var statDictionary = [StatType: [Stat]]()
	@Published var statCounter = [StatType: Int]()
	
	//MARK: RecordModel
	
	static func createGame(team: Team) -> Game {
		let model = GameCD(context: AppDelegate.context)
		let id = UUID()
		model.id = id
		model.opponentName = "Opponent"
		
		model.team = team.model
		model.startDate = Date()
		
		return Game(opponentName: "Opponent", model: model, id: id.uuidString)
	}
	
	private init(hasEnded: Bool? = nil, endDate: Date? = nil, opponentName: String, opponentScore: Int? = nil, teamScore: Int? = nil, model: GameCD, id: String, posA: Player? = nil, posB: Player? = nil, posC: Player? = nil, posD: Player? = nil, posE: Player? = nil) {
		self.isComplete = hasEnded ?? false
		self.endDate = endDate
		self.teamScore = teamScore ?? 0
		self.opponentScore = opponentScore ?? 0
		self.opponentName = opponentName
		self.id = id
		self.model = model
		self.startDate = Date()
		positionA = posA
		positionB = posB
		positionC = posC
		positionD = posD
		positionE = posE
	}
	
	let id: String
	let model: GameCD
	init(model: GameCD) throws {
		guard let id = model.id else { throw BoxScoreError.invalidModelError() }
		
		self.isComplete = model.hasEnded
		self.opponentName = model.opponentName ?? "Opponent"
		self.opponentScore = Int(model.opponentScore)
		self.teamScore = Int(model.teamScore)
		self.startDate = model.startDate
		self.endDate = model.endDate
		
		self.model = model
		self.id = id.uuidString
		
		func position(for model: PlayerCD?) -> Player? {
			if let model = model {
				return try? Player(model: model)
			}
			
			return nil
		}
		
		positionA = position(for: model.positionA)
		positionB = position(for: model.positionB)
		positionC = position(for: model.positionC)
		positionD = position(for: model.positionD)
		positionE = position(for: model.positionE)
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
