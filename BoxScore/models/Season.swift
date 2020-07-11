//
//  Season.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation

class Season: ObservableObject {
	@Published var team: Team
	@Published var previousGames: [Game]
	@Published var currentGame: Game? {
		didSet {
			currentlyInGame = currentGame != nil
		}
	}
	@Published var currentlyInGame: Bool = false
	
	init(team: Team, currentGame: Game? = nil, previousGames: [Game] = []) {
		self.team = team
		self.previousGames = previousGames
		self.currentGame = currentGame
		self.currentlyInGame = currentGame != nil
	}
	
	func completeGame() {
		guard let currentGame = currentGame else { return }
		
		currentGame.isComplete = true
		previousGames.insert(currentGame, at: 0)
		self.currentGame = nil
	}
	
	func withGames(games: [Game]) -> Season {
		//Only update if we have new games
		var allGames = previousGames
		if let currentGame = currentGame {
			allGames.append(currentGame)
		}
		
		if !(games.count == allGames.count) {
			previousGames = games.filter { $0.isComplete }
			currentGame = games.first { !$0.isComplete }
		}
		
		return self
	}
}

extension Season {
	static var testData: Season {
		return Season(
			team: Team.testData,
			currentGame: Game.statTestData,
			previousGames: [
				Game.testGame(opponentScore: 32),
				Game.testGame(opponentScore: 45),
				Game.testGame(opponentScore: 55)
			]
		)
	}
}
