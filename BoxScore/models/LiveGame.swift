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
	
	@Published var playersInGame: [Player] {
		didSet {
			game.playerIdsInGame = playersInGame.map { $0.id }
		}
	}
	@Published var playersOnBench: [Player]
	@Published var statCounter = [StatType: Int]()
	
	var cancellable: AnyCancellable?
	
	init(team: Team, game: Game?) {
		self.game = game ?? Game.createGame(teamId: team.id)
		self.team = team
		
		let playersInGame = game?.playerIdsInGame.compactMap { (id) in
			team.players.first { $0.id == id }
		} ?? []
		self.playersInGame = playersInGame
		self.playersOnBench = team.players.filter { !playersInGame.contains($0) }
		
		cancellable = self.game.objectWillChange.sink(receiveValue: { (_) in
			self.objectWillChange.send()
		})
	}
	
	//MARK: Methods
	
	func createOrStart() {
		let playersInGame = game.playerIdsInGame.compactMap { (id) in
			team.players.first { $0.id == id }
		}
		self.playersInGame = playersInGame
		self.playersOnBench = team.players.filter { !playersInGame.contains($0) }
		
		game.start()
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
		
//		if statDictionary[stat.type] == nil {
//			statDictionary[stat.type] = []
//		}
//
//		statDictionary[stat.type]?.append(stat)
//		statCounter[stat.type] = (statCounter[stat.type] ?? 0) + 1
//
//		switch stat.type {
//		case .shot:
//			if stat.shotWasMake {
//				teamScore += stat.pointsOfShot ?? 0
//			}
//		default:
//			//Do nothing
//			break
//		}
	}
	
}
