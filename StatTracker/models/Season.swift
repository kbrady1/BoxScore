//
//  Season.swift
//  StatTracker
//
//  Created by Kent Brady on 7/3/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
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
