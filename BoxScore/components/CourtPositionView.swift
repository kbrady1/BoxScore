//
//  CourtPositionView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

private let DISTANCE_TO_REGISTER: CGFloat = 60
private let COURT_PADDING: CGFloat = 32

enum MoveDirection: String {
	case left, right, up, down
}

class ObservablePlayer: ObservableObject {
	@Published var player: Player? = nil
	
	init(player: Player? = nil) {
		self.player = player
	}
}

struct CourtPositionView: View {
	@EnvironmentObject var game: LiveGame
	@EnvironmentObject var settings: StatSettings
	@State var position: CGPoint
	
	var courtWidth: CGFloat { UIScreen.main.bounds.width }
	
	@State private var offset = CGSize.zero
	@State private var offsetPosition = CGSize.zero
	@State private var size = CGSize.zero
	@ObservedObject var player: ObservablePlayer = ObservablePlayer()
	@State private var dragDirection: MoveDirection? = nil
	@State private var showingAlert = false {
		didSet {
			if !showingAlert {
				self.statType = nil
			}
		}
	}
	
	var hasPlayer: Bool { player.player != nil }
	var defaultSize: CGSize {
		self.hasPlayer ? CGSize(width: 75, height: 75) : CGSize(width: 45, height: 45)
	}
	@State var statType: StatType? = nil
	
	/*
	- position never changes, it is the start position as input.
	- position - offset position = location in relation to court view
	- use courtWidth to create a square to calculate the height or width limit
	*/
	
	var body: some View {
		let moveGesture = DragGesture()
			.onChanged { (gesture) in
				if self.canUpdateLocation(for: gesture.translation) {
					self.offset = CGSize(
						width: gesture.translation.width + self.offsetPosition.width,
						height: gesture.translation.height + self.offsetPosition.height
					)
				}
			}
			.onEnded { (gesture) in
				if self.canUpdateLocation(for: gesture.translation) {
					self.offset = CGSize(
						width: gesture.translation.width + self.offsetPosition.width,
						height: gesture.translation.height + self.offsetPosition.height
					)
				}
				self.offsetPosition = self.offset
			}
		let doubleTap = TapGesture(count: 2)
			.onEnded { (gesture) in
				DispatchQueue.main.async {
					self.game.swapPlayers(fromBench: nil, toLineUp: self.player.player)
					self.player.player = nil
				}
			}
		let statGesture = DragGesture(minimumDistance: 5)
			.onChanged { (gesture) in
				if self.dragDirection != nil {
					self.rubberband(withTranslation: gesture.translation)
				} else {
					let xChange = gesture.translation.width
					let yChange = gesture.translation.height
					let maxChange = max(xChange, abs(xChange), abs(yChange), yChange)
					
					if xChange == maxChange {
						self.dragDirection = .right
					} else if -xChange == maxChange {
						self.dragDirection = .left
					} else if yChange == maxChange {
						self.dragDirection = .down
					} else if -yChange == maxChange {
						self.dragDirection = .up
					}
				}
			}
			.onEnded { (gesture) in
				//Pop back to place
				self.endDrag()
			}
				
		return ZStack {
			if !hasPlayer {
				Circle()
					.fill(LinearGradient(gradient: Gradient(colors: [.gray, Color(UIColor.secondarySystemBackground)]), startPoint: .bottom, endPoint: .topTrailing))
					.frame(width: defaultSize.width, height: defaultSize.height)
			} else {
				if statType != nil {
					VStack {
						if dragDirection == .up { Spacer() }
						HStack {
							if dragDirection == .left { Spacer() }
							Text(statType?.abbreviation() ?? "")
								.bold()
								.font(.callout)
								.foregroundColor(Color.white)
								.padding(.all, 4.0)
							if dragDirection == .right { Spacer() }
						}
						if dragDirection == .down { Spacer() }
					}
				}
				
				VStack {
					if dragDirection == .down { Spacer() }
					HStack {
						if dragDirection == .right { Spacer() }
						PlayerInGameView(game: game, player: player.player!, height: defaultSize.height)
							.contextMenu {
								ForEach(settings.allStats, id: \.0) { (typePair) in
									Button(action: {
										self.statType = typePair.1
										self.showingAlert = true
									}) {
										Text(typePair.1.rawValue.capitalized)
									}
								}
							}
						if dragDirection == .left { Spacer() }
					}
					if dragDirection == .up { Spacer() }
				}
			}
		}
		.onAppear {
			if self.dragDirection == nil {
				self.size = self.defaultSize
			}
		}
		.sheet(isPresented: $showingAlert) {
			StatInputView(player: self.player.player!,
						  stat: StatInput(type: self.statType ?? .shot,
										  player: self.player.player!.model,
										  game: self.game.game.model,
										  team: self.game.team.model),
						  game: self.game)
		}
		.frame(width: size.width, height: size.height)
		.background(game.team.secondaryColor.cornerRadius(60))
		.offset(offset)
		.position(position)
		.onDrop(of: ["player"], isTargeted: nil) { (providers) -> Bool in
			providers.first?.loadObject(ofClass: DraggablePlayerReference.self, completionHandler: { (reading, error) in
				DispatchQueue.main.async {
					self.addPlayer(reading as? DraggablePlayerReference, game: self.game)
				}
			})

			return true
		}
		.if(!hasPlayer) { $0.gesture(moveGesture) }
		.if(hasPlayer) { $0.gesture(doubleTap) }
		.if(hasPlayer) { $0.gesture(statGesture) }
	}
	
	func addPlayer(_ playerReference: DraggablePlayerReference?, game: LiveGame) {
		if let player = game.playersOnBench.first(where: { $0.id == playerReference?.id }) {
			game.swapPlayers(fromBench: player, toLineUp: self.player.player)
			self.player.player = player
		}
	}
	
	private func trackStat() {
		if showingAlert == false {
			giveFeedback()
			showingAlert = true
		}
		
		endDrag()
	}
	
	private func giveFeedback() {
		UIImpactFeedbackGenerator().impactOccurred()
	}
	
	private func canUpdateLocation(for translation: CGSize) -> Bool {
		let newWidth = translation.width + self.offsetPosition.width
		let newHeight = translation.height + self.offsetPosition.height
		
		let newX = self.position.x + newWidth
		let newY = self.position.y + newHeight
		
		//Only move the view if within bounds
		return newX > COURT_PADDING &&
			newX + COURT_PADDING < self.courtWidth &&
			newY > COURT_PADDING &&
			newY + COURT_PADDING < self.courtWidth
	}
	
	private func endDrag() {
		withAnimation(.spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0.5)) {
			self.offset = self.offsetPosition
			self.size = self.defaultSize
			self.dragDirection = nil
		}
	}
	
	private func rubberband(withTranslation translation: CGSize) {
		guard let direction = dragDirection else { return }
		
		statType = settings.getStat(for: direction)
		switch direction {
		case .right:
			//If we are moving right, and the
			if translation.width < 5.0 {
				dragDirection = nil
			} else {
				let adjustedOffset = logOffsetValue(translation.width)
				size = CGSize(width: defaultSize.width + adjustedOffset, height: size.height)
				offset = CGSize(width: adjustedOffset / 2 + offsetPosition.width, height: offsetPosition.height)
				
				if adjustedOffset > DISTANCE_TO_REGISTER { trackStat() }
			}
		case .left:
			if translation.width > -5.0 {
				dragDirection = nil
			} else {
				let adjustedOffset = logOffsetValue(-translation.width)
				size = CGSize(width: defaultSize.width + adjustedOffset, height: size.height)
				offset = CGSize(width: -adjustedOffset / 2 + offsetPosition.width, height: offsetPosition.height)
				
				if adjustedOffset > DISTANCE_TO_REGISTER { trackStat() }
			}
		case .up:
			if translation.height > -5.0 {
				dragDirection = nil
			} else {
				let adjustedOffset = logOffsetValue(-translation.height)
				size = CGSize(width: size.width, height: defaultSize.height + adjustedOffset)
				offset = CGSize(width: offsetPosition.width, height: -adjustedOffset / 2 + offsetPosition.height)
				
				if adjustedOffset > DISTANCE_TO_REGISTER { trackStat() }
			}
		case .down:
			if translation.height < 5.0 {
				dragDirection = nil
			} else {
				let adjustedOffset = logOffsetValue(translation.height)
				size = CGSize(width: size.width, height: defaultSize.height + adjustedOffset)
				offset = CGSize(width: offsetPosition.width, height: adjustedOffset / 2 + offsetPosition.height)
				
				if adjustedOffset > DISTANCE_TO_REGISTER { trackStat() }
			}
		}
	}
	
	private func logOffsetValue(_ offset: CGFloat) -> CGFloat {
		return (DISTANCE_TO_REGISTER * 0.8) * (1 + log10(offset / (DISTANCE_TO_REGISTER * 0.8)))
	}
}
