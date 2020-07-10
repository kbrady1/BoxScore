//
//  Game.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import CoreGraphics

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
	init(team: Team) {
		self.team = team
		self.playersInGame = []
		self.playersOnBench = team.players
		self.date = Date()
		self.id = UUID().uuidString
	}
	
	let id: String
	
	@Published var teamScore = 0
	@Published var opponentScore = 0
	
	var date: Date
	@Published var team: Team
	@Published var playersInGame: [Player]
	@Published var playersOnBench: [Player]
	
	var dateText: String {
		return DATE_FORMATTER.string(from: date)
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
	
	func restart() {
		statDictionary.removeAll()
		statCounter.removeAll()
		isComplete = false
		hasBegun = false
		playersInGame = []
		playersOnBench = team.players
		teamScore = 0
		opponentScore = 0
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
	
	//MARK: Equatable
	
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
	
	//MARK: Hashable
	
	
}

extension Game {
	static var previewData: Game {
		return Game(team: Team.testData)
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
