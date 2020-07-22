//
//  LiveGameCourtView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/17/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

//TODO: Add undo option for stats

struct LiveGameCourtView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var season: Season
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var game: LiveGame
	
	@State private var showActionSheet: Bool = false
	@State private var showStatModal: Bool = false
	
	@State private var positionA: CourtPositionView? = nil
	@State private var positionB: CourtPositionView? = nil
	@State private var positionC: CourtPositionView? = nil
	@State private var positionD: CourtPositionView? = nil
	@State private var positionE: CourtPositionView? = nil
	
    var body: some View {
		ZStack {
			VStack {
				VStack(spacing: 24) {
					HStack {
						VStack {
							Text("\(self.season.team.name)")
								.font(.caption)
								.offset(x: 0, y: 10)
							Text(String(self.game.game.teamScore))
								.foregroundColor(self.season.team.primaryColor)
								.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
						}
						.frame(width: 90)
						Spacer()
						Text("Game Score")
							.font(.title)
							.scaledToFit()
						Spacer()
						VStack {
							Text(self.game.game.opponentName)
								.font(.caption)
								.offset(x: 0, y: 10)
							Button(String(self.game.game.opponentScore)) {
								self.game.game.opponentScore += 1
							}
							.contextMenu {
								ForEach(self.game.opponentScoreOptions, id: \.1) { (scorePair) in
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
						.frame(width: 90)
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
					.padding(.bottom)
				}
				.background(BlurView(style: .prominent))
				.background(self.game.team.primaryColor.cornerRadius(18))
				.cornerRadius(16)
				.shadow(color: Color.black.opacity(0.2), radius: 6.0)
				.padding(8.0)
				
				self.addCourtView()
			}
			.offset(x: 0, y: -60)
			.edgesIgnoringSafeArea(.bottom)
			
			VStack {
				Spacer()
				ZStack {
					BlurView(style: .systemUltraThinMaterial)
						.cornerRadius(16.0)
						.shadow(color: Color.black.opacity(0.2), radius: 6.0)
						.edgesIgnoringSafeArea(.bottom)
					VStack(spacing: 0) {
						Bench() { (player) in
							[self.positionA, self.positionB, self.positionC, self.positionD, self.positionE]
								.compactMap { $0 }
								.first { $0.player.player == nil }?
								.addPlayer(DraggablePlayerReference(id: player.id), game: self.game)
						}
						
						HStack {
							Button(action: {
								self.showStatModal.toggle()
							}) {
								FloatButtonView(text: Binding.constant("Stats"), backgroundColor: self.season.team.primaryColor)
							}
							.sheet(isPresented: self.$showStatModal) {
								LiveGameStatView()
									.environmentObject(self.game)
									.environmentObject(self.game.team)
							}
							Button(action: {
								//End game
								self.showActionSheet.toggle()
							}) {
								FloatButtonView(text: Binding.constant("End Game"), backgroundColor: self.season.team.secondaryColor)
							}
							.actionSheet(isPresented: self.$showActionSheet) {
								ActionSheet(title: Text("Confirm End Game?"), message: Text("By ending the game you will no longer be able to add stats to this game. This action cannot be undone."), buttons: [
									ActionSheet.Button.cancel(),
									ActionSheet.Button.destructive(Text("End Game"), action: {
										self.season.completeGame()
										self.presentationMode.wrappedValue.dismiss()
									})
								])
							}
						}.padding()
					}
				}
					.frame(height: 180)
			}
		}
		.onDisappear {
			self.reorderLineup()
		}
		.onAppear {
			self.setUpCourtPositions()
			
			self.game.setUp()
			self.season.currentGame = self.game.game
		}
	}
	
	private func addCourtView() -> some View {
		return ZStack {
			Image("full_court")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(Color(.live_court_color))
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
		
		positionA = CourtPositionView(position: CGPoint(x: 200, y: 250), player: playerAt(index: 0))
		positionB = CourtPositionView(position: CGPoint(x: 300, y: 80), player: playerAt(index: 1))
		positionC = CourtPositionView(position: CGPoint(x: 150, y: 80), player: playerAt(index: 2))
		positionD = CourtPositionView(position: CGPoint(x: 50, y: 150), player: playerAt(index: 3))
		positionE = CourtPositionView(position: CGPoint(x: 320, y: 150), player: playerAt(index: 4))
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
				.padding(.vertical, 8.0)
			}
			.padding(.leading, 10)
			.frame(minHeight: 100)
		}
	}
}

extension StatType: Identifiable {
	public var id: String {
		return self.rawValue
	}
}
