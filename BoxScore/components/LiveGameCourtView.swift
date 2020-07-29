//
//  LiveGameCourtView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/17/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

private let LANDSCAPE_WIDTH_LEFT_BAR_FACTOR: CGFloat = 0.4

//TODO: Add undo option for stats
struct LiveGameCourtView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
	@EnvironmentObject var season: Season
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var game: LiveGame
	
	@State private var showActionSheet: Bool = false
	@State private var showStatModal: Bool = false
	
    var body: some View {
		GeometryReader { reader in
			if reader.size.width > reader.size.height {
				//Landscape mode
				HStack {
					//Put court view along right side and scoreboard/buttons along left
					VStack {
						self.scoreBoard()
						ScrollView(.vertical, showsIndicators: false) {
							VStack(spacing: 16) {
								ForEach(self.game.playersOnBench) { (player) in
									PlayerInGameView(game: self.game, player: player)
										.onTapGesture(count: 2) {
											self.benchDoubleTapAction(player: player)
									}
								}
								.padding(.vertical, 8.0)
							}
							.padding(.vertical, 10)
							.frame(minWidth: 100)
						}
						VStack(spacing: 16) {
							self.statsButton()
							self.endGameButton()
						}.padding()
					}
						.frame(width: reader.size.width * LANDSCAPE_WIDTH_LEFT_BAR_FACTOR)
					self.addCourtView()
				}
			} else {
				//Standard View
				ZStack {
					VStack {
						self.scoreBoard()
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
								ScrollView(.horizontal, showsIndicators: false) {
								HStack(spacing: 16) {
									ForEach(self.game.playersOnBench) { (player) in
										PlayerInGameView(game: self.game, player: player)
											.onTapGesture(count: 2) {
												self.benchDoubleTapAction(player: player)
										}
									}
									.padding(.vertical, 8.0)
								}
								.padding(.leading, 10)
								.frame(minHeight: 100)
								}
								
								HStack {
									self.statsButton()
									self.endGameButton()
								}.padding()
							}
						}
							.frame(height: 180)
					}
				}
			}
		}
		.onAppear {
			self.season.currentGame = self.game.game
		}
	}
	
	private func scoreBoard() -> some View {
		VStack {
			HStack {
				VStack {
					Text("\(self.season.team.name)")
						.font(.caption)
						.offset(x: 0, y: 10)
					Text(String(self.game.game.teamScore))
						.foregroundColor(self.season.team.primaryColor)
						.font(.system(size: 60, weight: .bold, design: Font.Design.rounded))
				}
				.frame(minWidth: 90)
				Spacer()
				Text("Game Score")
					.font(.title)
					.allowsTightening(true)
					.minimumScaleFactor(4.0)
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
				.frame(minWidth: 90)
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
					.frame(minWidth: 20)
				}
			}
			.padding(.bottom, 4.0)
		}
		.background(TeamGradientBackground(blur: .prominent, cornerRadius: 18).environmentObject(game.team))
		.cornerRadius(16)
		.shadow(color: Color.black.opacity(0.2), radius: 6.0)
		.padding(8.0)
	}
	
	private func statsButton() -> some View {
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
	}
	
	private func endGameButton() -> some View {
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
	}
		
	private func benchDoubleTapAction(player: Player) {
		if game.posA == nil {
			game.posA = player
		} else if game.posB == nil {
			game.posB = player
		} else if game.posC == nil {
			game.posC = player
		} else if game.posD == nil {
			game.posD = player
		} else if game.posE == nil {
			game.posE = player
		}
		
		game.updatePlayersOnBench()
	}
	
	private func addCourtView() -> some View {
		func observablePlayer(_ player: Player?) -> ObservablePlayer {
			if let player = player {
				return ObservablePlayer(player: player)
			}
			
			return ObservablePlayer()
		}
		
		var width = UIApplication.width
		if UIApplication.width > UIApplication.height {
			width = width * LANDSCAPE_WIDTH_LEFT_BAR_FACTOR
		}
		let height = width * 0.75
		
		return ZStack {
			Image("full_court")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(Color(.live_court_color))
			CourtPositionView(position: CGPoint(x: width * 0.3, y: height * 0.7), player: observablePlayer(game.posA), addPlayer: { (player) in
				self.game.posA = player
				self.game.updatePlayersOnBench()
			}) {
				self.game.posA = nil
				self.game.updatePlayersOnBench()
			}
			CourtPositionView(position: CGPoint(x: width * 0.8, y: height * 0.2), player: observablePlayer(game.posB), addPlayer: { (player) in
				self.game.posB = player
				self.game.updatePlayersOnBench()
			}) {
				self.game.posB = nil
				self.game.updatePlayersOnBench()
			}
			CourtPositionView(position: CGPoint(x: width * 0.5, y: height * 0.3), player: observablePlayer(game.posC), addPlayer: { (player) in
				self.game.posC = player
				self.game.updatePlayersOnBench()
			}) {
				self.game.posC = nil
				self.game.updatePlayersOnBench()
			}
			CourtPositionView(position: CGPoint(x: width * 0.15, y: height * 0.2), player: observablePlayer(game.posD), addPlayer: { (player) in
				self.game.posD = player
				self.game.updatePlayersOnBench()
			}) {
				self.game.posD = nil
				self.game.updatePlayersOnBench()
			}
			CourtPositionView(position: CGPoint(x: width * 0.7, y: height * 0.6), player: observablePlayer(game.posE), addPlayer: { (player) in
				self.game.posE = player
				self.game.updatePlayersOnBench()
			}) {
				self.game.posE = nil
				self.game.updatePlayersOnBench()
			}
		}
	}
}

extension StatType: Identifiable {
	public var id: String {
		return self.rawValue
	}
}
