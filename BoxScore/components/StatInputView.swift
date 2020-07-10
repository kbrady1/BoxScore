//
//  StatInputView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/12/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct StatInputView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	//TODO: These should be observed objects
	@State var stat: Stat
	@State var game: Game
	
	@State private var shotWasMake: Bool = false {
		didSet {
			stat.shotWasMake = shotWasMake
		}
	}
	@State private var otherPlayer: Player? = nil {
		didSet {
			if shotWasMake {
				stat.assistedBy = otherPlayer
			} else {
				stat.rebounder = otherPlayer
			}
		}
	}
	@State private var pointsOfShot: Int? = nil {
		didSet {
			stat.pointsOfShot = pointsOfShot
		}
	}
	@State private var shotLocation: CGPoint = .zero {
		didSet {
			stat.shotLocation = shotLocation
		}
	}
	@State private var offensiveRebound: Bool = false {
		didSet {
			stat.offensiveRebound = offensiveRebound
		}
	}
	
	@State private var timer: Timer?
	@State private var timeUntilDismissal: Int? = nil
	
    var body: some View {
		return ScrollView(.vertical, showsIndicators: true) {
			Spacer().frame(height: 15)
			VStack(spacing: 16) {
				VStack {
					PlayerView(player: stat.player)
						.frame(width: 80, height: 80)
						.background(Color.white)
						.clipShape(Circle())
						.shadow(radius: 6)
					Text("Add \(stat.type.rawValue.capitalized)")
						.font(.system(size: 45))
						.bold()
				}
					
				if stat.type == .shot {
					//Add Court, ability to drop pin on shot location
					VStack {
						InstructionView(number: "1", title: "Tap Shot Location", accentColor: game.team.secondaryColor)
						ZStack {
							Image("BasketballCourt")
								.resizable()
								.frame(minWidth: 300, maxWidth: .infinity)
								.frame(minHeight: 200, maxHeight: 200)
								.gesture(DragGesture(minimumDistance: 0)
									.onEnded { (gesture) in
										self.shotLocation = gesture.startLocation
									}
								)
								
							if shotLocation != .zero {
								CircleView(color: $game.team.primaryColor)
									.frame(width: 20, height: 20)
									.position(shotLocation)
							}
						}
					}
					VStack {
						InstructionView(number: "2", title: "Make or Miss", accentColor: game.team.secondaryColor)
						HStack {
							Button(action: {
								self.shotWasMake = true
							}) {
								Text("Make")
									.bold()
									.font(.system(size: 28))
									.padding(.horizontal)
									.padding(.vertical, 6.0)
									.background(!shotWasMake ? Color.clear : game.team.primaryColor)
									.foregroundColor(!shotWasMake ? game.team.primaryColor : Color.white)
									.cornerRadius(8.0)
									.shadow(radius: 4.0)
									.animation(.default)
							}
							Button(action: {
								self.shotWasMake = false
							}) {
								Text("Miss")
									.bold()
									.font(.system(size: 28))
									.padding(.horizontal)
									.padding(.vertical, 6.0)
									.background(shotWasMake ? Color.clear : game.team.primaryColor)
									.foregroundColor(shotWasMake ? game.team.primaryColor : Color.white)
									.cornerRadius(8.0)
									.shadow(radius: 4.0)
								.animation(.default)
							}
						}
					}
					VStack {
						HStack {
							Text("3")
								.font(.caption)
								.foregroundColor(.white)
								.padding(6.0)
								.background(game.team.secondaryColor)
								.clipShape(Circle())
							Text(shotWasMake ? "Assisted By" : "Rebounded By")
								.font(.caption)
						}
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: 16) {
								Text("None")
									.frame(width: 80, height: 80)
								.if(self.otherPlayer == nil) {
									$0.background(CircleView(color: self.$game.team.primaryColor, shadow: false))
								}
								.if(self.otherPlayer != nil) {
									$0.background(DefaultCircleView(shadow: false))
								}
								.onTapGesture { self.otherPlayer = nil }
								.animation(.default)
								
								ForEach(game.playersInGame, id: \.number) { (player) in
									PlayerView(player: player, shadow: false)
										.if(self.otherPlayer == player) {
											$0.background(CircleView(color: self.$game.team.primaryColor, shadow: false))
										}
										.if(self.otherPlayer != player) {
											$0.background(DefaultCircleView(shadow: false))
										}
										.onTapGesture { self.otherPlayer = player }
										.animation(.default)
								}
							}
							.padding(.leading, 10)
							.frame(height: 100)
						}
					}
					if shotWasMake {
						VStack {
							InstructionView(number: "4", title: "Points", accentColor: game.team.secondaryColor)
							HStack {
								pointView(points: 1)
								pointView(points: 2)
								pointView(points: 3)
							}
						}
					}
				}
				if stat.type == .rebound {
					VStack {
						InstructionView(number: "1", title: "Offensive or Defensive", accentColor: game.team.secondaryColor)
						HStack {
							Button(action: {
								self.offensiveRebound = true
							}) {
								Text("Offensive")
									.bold()
									.font(.system(size: 28))
									.padding(.horizontal)
									.padding(.vertical, 6.0)
									.background(!offensiveRebound ? Color.clear : game.team.primaryColor)
									.foregroundColor(!offensiveRebound ? game.team.primaryColor : Color.white)
									.cornerRadius(8.0)
									.shadow(radius: 4.0)
									.animation(.default)
							}
							Button(action: {
								self.offensiveRebound = false
							}) {
								Text("Defensive")
									.bold()
									.font(.system(size: 28))
									.padding(.horizontal)
									.padding(.vertical, 6.0)
									.background(offensiveRebound ? Color.clear : game.team.primaryColor)
									.foregroundColor(offensiveRebound ? game.team.primaryColor : Color.white)
									.cornerRadius(8.0)
									.shadow(radius: 4.0)
									.animation(.default)
							}
						}
					}
				}
				if timeUntilDismissal != nil {
					VStack {
						Text("Dismissing in...")
						Text("\(timeUntilDismissal ?? 0)")
							.bold()
							.font(.system(size: 64))
							.padding(24.0)
					}
				}
				VStack {
					
					Button(action: {
						self.game.recordStat(self.stat)
						self.presentationMode.wrappedValue.dismiss()
					}) {
						Text("Confirm")
							.bold()
							.frame(minWidth: 0, maxWidth: .infinity)
							.font(.system(size: 28))
							.padding(.vertical, 8)
							.background(game.team.primaryColor)
							.foregroundColor(Color.white)
							.cornerRadius(16)
							.shadow(radius: 4)
					}
						.padding(.horizontal)
						.padding(.top, 8)
						.disabled(self.shotLocation == .zero && self.stat.type == .shot)
						.saturation(self.shotLocation == .zero && self.stat.type == .shot ? 0.1 : 1.0)
					
				}
			}
			.padding(8.0)
		}
		.onAppear {
			if !self.stat.type.requiresPopUp() {
				self.timeUntilDismissal = 3
				self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
					self.timeUntilDismissal! -= 1
					
					if self.timeUntilDismissal ?? 0 < 1 {
						self.game.recordStat(self.stat)
						self.presentationMode.wrappedValue.dismiss()
					}
				}
			}
		}
		.onDisappear {
			self.timer?.invalidate()
		}
    }
	
	private func pointView(points: Int) -> some View {
		Text(String(points))
		.font(.system(size: 20))
		.bold()
		.frame(width: 80, height: 80)
		.if(self.pointsOfShot == points) {
			$0.background(CircleView(color: $game.team.primaryColor, shadow: false))
		}
		.if(self.pointsOfShot != points) {
			$0.background(DefaultCircleView(shadow: false))
		}
		.animation(.default)
		.onTapGesture {
			self.pointsOfShot = points
		}
	}
}

struct StatInputView_Previews: PreviewProvider {
    static var previews: some View {
		let game = Game.previewData
		let stat = Stat(type: .shot, player: game.team.players[0])
		return StatInputView(stat: stat, game: game)
			.previewLayout(.fixed(width: 300, height: 600))
    }
}

struct InstructionView: View {
	@State var number: String
	@State var title: String
	@State var accentColor: Color
	
	var body: some View {
		HStack {
			Text(number)
				.font(.caption)
				.foregroundColor(.white)
				.padding(6.0)
				.background(accentColor)
				.clipShape(Circle())
			Text(title)
				.font(.caption)
		}
	}
}
