//
//  Game.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import Foundation
import CoreGraphics

class Game: ObservableObject {
	init(team: Team) {
		self.team = team
		self.playersInGame = []
		self.playersOnBench = team.players
	}
	
	@Published var teamScore = 0
	@Published var opponentScore = 0
	
	@Published var team: Team
	@Published var playersInGame: [Player]
	@Published var playersOnBench: [Player]
	
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
}

extension Game {
	static var previewData: Game {
		return Game(team: Team.testData)
	}
}
