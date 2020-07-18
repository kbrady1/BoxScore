//
//  LiveGameCourtView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/17/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

private let SCORE_BOARD_HEIGHT: CGFloat = 125

struct LiveGameCourtView: View {
	@EnvironmentObject var season: Season
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var game: LiveGame
	
	@State private var positionA: CourtPositionView? = nil
	@State private var positionB: CourtPositionView? = nil
	@State private var positionC: CourtPositionView? = nil
	@State private var positionD: CourtPositionView? = nil
	@State private var positionE: CourtPositionView? = nil
	
    var body: some View {
		ZStack(alignment: .top) {
			ZStack {
				Rectangle()
					.stroke(Color.clear, lineWidth: 0)
					.background(season.team.primaryColor)
					.frame(minWidth: 0, maxWidth: .infinity)
					.frame(height: SCORE_BOARD_HEIGHT + 85 + UIApplication.safeAreaOffset)
					.shadow(radius: 5)
					.edgesIgnoringSafeArea(.top)
			}
			VStack {
				VStack {
					HStack {
						VStack {
							Text("\(self.season.team.name)")
								.font(.caption)
								.offset(x: 0, y: 10)
							Text(String(game.game.teamScore))
								.foregroundColor(self.season.team.primaryColor)
								.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
						}
						Spacer()
						Text("Game Score")
							.font(.largeTitle)
							.scaledToFit()
						Spacer()
						VStack {
							Text("Opponent")
								.font(.caption)
								.offset(x: 0, y: 10)
							Button(String(game.game.opponentScore)) {
								self.game.game.opponentScore += 1
							}
							.contextMenu {
								ForEach(game.opponentScoreOptions, id: \.1) { (scorePair) in
									Button(action: {
										self.game.game.opponentScore += scorePair.1
									}) {
										Text(scorePair.0)
									}
								}
							}
							.foregroundColor(self.season.team.primaryColor)
							.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
						}
					}
					.padding(.horizontal)
					HStack(spacing: 16) {
						ForEach(StatType.all.filter { $0 != .shot }) { (stat) in
							VStack {
								Text(stat.abbreviation())
									.font(.callout)
								Text("\(self.game.game.statCounter[stat] ?? 0)")
									.bold()
									.font(.headline)
							}
						}
					}
				}
				.frame(minWidth: 0, maxWidth: .infinity)
				.frame(height: SCORE_BOARD_HEIGHT)
				.background(BlurView(style: .systemChromeMaterial))
				
				self.addCourtView()
				Spacer()
				Bench() { (player) in
					//Action to perform on double tap of bench item, adds player to game if spot available
					[self.positionA, self.positionB, self.positionC, self.positionD, self.positionE]
						.compactMap { $0 }
						.first { $0.player.player == nil }?
						.addPlayer(DraggablePlayerReference(id: player.id), game: self.game)
				}
			}
		}
		.onDisappear {
			self.reorderLineup()
		}
		.onAppear {
			self.setUpCourtPositions()
		}
	}
	
	private func addCourtView() -> some View {
		let image = Image("BasketballCourt")
			.resizable()
			.frame(minWidth: 300, maxWidth: .infinity)
			.frame(height: 300)
		
		return ZStack {
			//TODO: Add geometry reader here to make sure court position views are not dragged outside of court
			image
			if positionA != nil {
				positionA
			}
			if positionB != nil {
				positionB
			}
			if positionC != nil {
				positionC
			}
			if positionD != nil {
				positionD
			}
			if positionE != nil {
				positionE
			}
		}
	}
	
	private func setUpCourtPositions() {
		func playerAt(index: Int) -> ObservablePlayer {
			if game.playersInGame.count - 1 >= index {
				return ObservablePlayer(player: game.playersInGame[index])
			}
			
			return ObservablePlayer()
		}
		
		positionA = CourtPositionView(position: CGPoint(x: 200, y: 340), player: playerAt(index: 0))
		positionB = CourtPositionView(position: CGPoint(x: 300, y: 150), player: playerAt(index: 1))
		positionC = CourtPositionView(position: CGPoint(x: 150, y: 150), player: playerAt(index: 2))
		positionD = CourtPositionView(position: CGPoint(x: 50, y: 300), player: playerAt(index: 3))
		positionE = CourtPositionView(position: CGPoint(x: 320, y: 300), player: playerAt(index: 4))
	}
	
	private func reorderLineup() {
		var updatedLineup = [Player]()
		
		func addIfThere(view: CourtPositionView?) {
			if let player = view?.player.player {
				updatedLineup.append(player)
			}
		}
		
		[positionA, positionB, positionC, positionD, positionE].forEach {
			addIfThere(view: $0)
		}
		
		season.currentGame?.playersInGame = updatedLineup
	}
}

struct Bench: View {
	@EnvironmentObject var game: LiveGame
	
	var action: (Player) -> ()
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 16) {
				ForEach(game.playersOnBench) { (player) in
					PlayerInGameView(game: self.game, player: player)
						.onTapGesture(count: 2) {
							self.action(player)
					}
				}
			}
			.padding(.leading, 10)
			.frame(height: 120)
		}
	}
}

extension StatType: Identifiable {
	public var id: String {
		return self.rawValue
	}
}
