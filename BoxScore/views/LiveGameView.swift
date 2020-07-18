//
//  LiveGameView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

private let SCORE_BOARD_HEIGHT: CGFloat = 125

///This view is for active games to track each player's stats
struct LiveGameView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@EnvironmentObject var game: LiveGame
	@EnvironmentObject var settings: StatSettings
	@EnvironmentObject var season: Season
	@EnvironmentObject var viewModel: SeasonViewModel
	
	@State private var positionA: CourtPositionView? = nil
	@State private var positionB: CourtPositionView? = nil
	@State private var positionC: CourtPositionView? = nil
	@State private var positionD: CourtPositionView? = nil
	@State private var positionE: CourtPositionView? = nil
	@State private var showActionSheet: Bool = false
	@State private var showStatModal: Bool = false
	
	@State private var showSaveGameLoader: Bool = false
	
	//TODO: Add undo option for stats
	var body: some View {
		return ZStack {
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
								Text("\(season.team.name)")
									.font(.caption)
									.offset(x: 0, y: 10)
								Text(String(game.game.teamScore))
									.foregroundColor(season.team.primaryColor)
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
									ForEach(self.game.opponentScoreOptions, id: \.1) { (scorePair) in
										Button(action: {
											self.game.game.opponentScore += scorePair.1
										}) {
											Text(scorePair.0)
										}
									}
								}
								.foregroundColor(season.team.primaryColor)
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
					
					addCourtView()
					Spacer()
					Bench() { (player) in
						//Action to perform on double tap of bench item, adds player to game if spot available
						[self.positionA, self.positionB, self.positionC, self.positionD, self.positionE]
							.compactMap { $0 }
							.first { $0.player.player == nil }?
							.addPlayer(DraggablePlayerReference(id: player.id), game: self.game)
					}
					
					HStack {
						Button(action: {
							//Show stat view
							self.showStatModal.toggle()
						}) {
							FloatButtonView(text: Binding.constant("Stats"), backgroundColor: game.team.primaryColor)
						}
						.sheet(isPresented: $showStatModal) {
							LiveGameStatView()
								.environmentObject(self.game)
						}
						Button(action: {
							//End game
							self.showActionSheet.toggle()
						}) {
							FloatButtonView(text: Binding.constant("End Game"), backgroundColor: game.team.secondaryColor)
						}
						.actionSheet(isPresented: $showActionSheet) {
							ActionSheet(title: Text("Confirm End Game?"), message: Text("By ending the game you will no longer be able to add stats to this game. This action cannot be undone."), buttons: [
								ActionSheet.Button.cancel(),
								ActionSheet.Button.destructive(Text("End Game"), action: {
									self.season.completeGame()
									self.showSaveGameLoader = true
								})
							])
						}
					}.padding()
				}
			}
			
			if showSaveGameLoader {
				SaveGameLoadingView(
					viewModel:EditGameViewModel(game: self.game.game),
					loadingView: LoadingView(visible: $showSaveGameLoader) { (_) in
						self.viewModel.skipCall = true
						self.presentationMode.wrappedValue.dismiss()
					}
				)
			}
		}
		.navigationBarTitle("", displayMode: .inline)
		.onAppear {
			self.game.createOrStart()
			self.setUpCourtPositions()
			self.season.currentGame = self.game.game
		}
		.onDisappear {
			self.reorderLineup()
		}
//		.popover(isPresented: $settings.needsToSeeTour) { StatSetupView().environmentObject(self.settings) }
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
		
		game.playersInGame = updatedLineup
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

extension UIApplication {
	static var safeAreaOffset: CGFloat { UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 }
}
