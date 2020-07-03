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
	@Published var currentGame: Game?
	
	init(team: Team, currentGame: Game? = nil, previousGames: [Game] = []) {
		self.team = team
		self.previousGames = previousGames
		self.currentGame = currentGame
	}
}
