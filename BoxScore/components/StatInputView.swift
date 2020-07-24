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
	@State var player: Player
	@State var stat: StatInput
	@ObservedObject var game: LiveGame
	
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
	//Use this for coordination on this same view
	@State private var shotLocation: CGPoint = .zero
	
	//Use this for saving to use on other views with increased accuracy
	@State private var adjustedShotLocation: CGPoint = .zero {
		didSet {
			stat.shotLocation = adjustedShotLocation
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
			VStack(spacing: 24) {
				VStack {
					PlayerView(player: player, color: Color(UIColor.secondarySystemGroupedBackground))
						.frame(width: 80, height: 80)
					Text("Add \(stat.type.rawValue.capitalized)")
						.font(.system(size: 45))
						.bold()
				}
					
				if stat.type == .shot {
					//Add Court, ability to drop pin on shot location
					VStack {
						InstructionView(number: "1", title: "Tap Shot Location", accentColor: game.team.secondaryColor)
						ZStack {
							GeometryReader { geometry in
								Image("half_court")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.foregroundColor(Color(.stat_court_color))
								.frame(minWidth: 100, maxWidth: .infinity)
								.gesture(DragGesture(minimumDistance: 0)
									.onEnded { (gesture) in
										//Save the shot location for use on this screen
										self.shotLocation = gesture.predictedEndLocation
										
										//Save the adjust shot location to standardize these coordinates
										self.adjustedShotLocation = CGPoint(x: (gesture.predictedEndLocation.x / geometry.size.width),
																			y: (gesture.predictedEndLocation.y / geometry.size.height))
									}
								)
							}
							.frame(minHeight: 200, idealHeight: 300, maxHeight: 350)

							if shotLocation != .zero {
								CircleView(color: $game.team.primaryColor)
									.frame(width: 20, height: 20)
									.position(shotLocation)
							}
						}
					}
					VStack(spacing: 8.0) {
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
										$0.background(DefaultCircleView(color: Color(UIColor.secondarySystemGroupedBackground), shadow: false))
									}
									.onTapGesture { self.otherPlayer = nil }
									.animation(.default)
								
								ForEach(game.playersInGame, id: \.number) { (player) in
									PlayerView(player: player, shadow: false)
										.if(self.otherPlayer == player) {
											$0.background(CircleView(color: self.$game.team.primaryColor, shadow: false))
										}
										.if(self.otherPlayer != player) {
											$0.background(DefaultCircleView(color: Color(UIColor.tertiarySystemGroupedBackground), shadow: false))
										}
										.onTapGesture { self.otherPlayer = player }
										.animation(.default)
								}
							}
							.padding(.leading, 10)
							.frame(height: 100)
						}
					}
					//Until I add predictive shot point analysis, this has to always be shown for statistical accuracy
//					if shotWasMake {
						VStack(spacing: 8.0) {
							InstructionView(number: "4", title: "Points", accentColor: game.team.secondaryColor)
							HStack(spacing: 16.0) {
								pointView(points: 1)
								pointView(points: 2)
								pointView(points: 3)
							}
						}
//					}
				}
				if stat.type == .rebound {
					VStack(spacing: 8.0) {
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
					VStack(spacing: 24) {
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
							.frame(minWidth: 0, maxWidth: 500)
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
			$0.background(DefaultCircleView(color: Color(UIColor.secondarySystemGroupedBackground), shadow: false))
		}
		.animation(.default)
		.onTapGesture {
			self.pointsOfShot = points
		}
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
