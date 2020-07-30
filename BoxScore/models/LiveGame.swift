//
//  LiveGame.swift
//  BoxScore
//
//  Created by Kent Brady on 7/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import Combine

class LiveGame: ObservableObject {
	@Published var game: Game
	@Published var team: Team
	
	@Published var posA: Player? = nil {
		willSet {
			checkForDuplicates(player: newValue)
		}
		didSet {
			game.positionA = posA
		}
	}
	@Published var posB: Player? = nil {
		willSet {
			checkForDuplicates(player: newValue)
		}
		didSet {
			game.positionB = posB
		}
	}
	@Published var posC: Player? = nil {
		willSet {
			checkForDuplicates(player: newValue)
		}
		didSet {
			game.positionC = posC
		}
	}
	@Published var posD: Player? = nil {
		willSet {
			checkForDuplicates(player: newValue)
		}
		didSet {
			game.positionD = posD
		}
	}
	@Published var posE: Player? = nil {
		willSet {
			checkForDuplicates(player: newValue)
		}
		didSet {
			game.positionE = posE
		}
	}
	
	@Published var playersOnBench: [Player] = []
	@Published var statViewModel: StatViewModel
	
	var cancellable: AnyCancellable?
	
	var opponentScoreOptions: [(String, Int)] {
		//Return -1, 1
		[
			("-1", -1),
			("+1", 1),
			("+2", 2),
			("+3", 3)
		].filter { $0.1 + game.opponentScore >= 0 }
	}
		
	init(team: Team, game: Game) {
		self.game = game
		self.team = team
		
		posA = game.positionA
		posB = game.positionB
		posC = game.positionC
		posD = game.positionD
		posE = game.positionE
		playersOnBench = team.players.filter { !game.playersInGame.contains($0) }
		
		statViewModel = StatViewModel(game: game.model)
		
		cancellable = self.game.objectWillChange.sink(receiveValue: { (_) in
			self.objectWillChange.send()
		})
		
		self.game.statDictionary = statViewModel.fetch().0.stats
		self.game.statDictionary.keys.forEach {
			if let count = self.game.statDictionary[$0]?.count, count > 0 {
				self.game.statCounter[$0] = count
			}
		}
		
		if let score = self.game.statDictionary[.shot]?.sumPoints() {
			self.game.teamScore = score
		}
	}
	
	//MARK: Methods
	
	func updatePlayersOnBench() {
		playersOnBench = team.players.filter { !game.playersInGame.contains($0) }
	}
	
	func recordStat(_ stat: StatInput) {
		stat.joinedStats.forEach {
			self.recordStat($0)
		}
		
		let recordedStat = stat.toStat()
		
		game.statDictionary[recordedStat.type] = (game.statDictionary[recordedStat.type] ?? []) + [recordedStat]
		//Update values
		game.statCounter[recordedStat.type] = (game.statCounter[recordedStat.type] ?? 0) + 1
		
		if recordedStat.type == .shot && recordedStat.shotWasMake {
			game.teamScore += recordedStat.pointsOfShot ?? 0
		}
		
		AppDelegate.instance.saveContext()
	}
	
	private func checkForDuplicates(player: Player?) {
		guard let player = player else { return }
		if posA == player {
			posA = nil
		}
		if posB == player {
			posB = nil
		}
		if posC == player {
			posC = nil
		}
		if posD == player {
			posD = nil
		}
		if posE == player {
			posE = nil
		}
	}
}
