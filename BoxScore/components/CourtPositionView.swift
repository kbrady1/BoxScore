//
//  CourtPositionView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI
import AVFoundation

private let DISTANCE_TO_REGISTER: CGFloat = 60

enum MoveDirection: String {
	case left, right, up, down
}

struct CourtPositionView: View {
	@EnvironmentObject var game: Game
	@EnvironmentObject var settings: StatSettings
	@State var position: CGPoint
	
	@State private var offset = CGSize.zero
	@State private var offsetPosition = CGSize.zero
	@State private var size = CGSize.zero
	@State var player: Player? = nil
	@State private var dragDirection: MoveDirection? = nil
	@State private var showingAlert = false {
		didSet {
			if !showingAlert {
				self.statType = nil
			}
		}
	}
	
	var hasPlayer: Bool { player != nil }
	var defaultSize: CGSize {
		self.hasPlayer ? CGSize(width: 80, height: 80) : CGSize(width: 50, height: 50)
	}
	@State var statType: StatType? = nil
	
	@State private var clickSound: AVAudioPlayer?
	
	var body: some View {
		let moveGesture = DragGesture()
			.onChanged { (gesture) in
				self.offset = CGSize(
					width: gesture.translation.width + self.offsetPosition.width,
					height: gesture.translation.height + self.offsetPosition.height
				)
			}
			.onEnded { (gesture) in
				self.offset = CGSize(
					width: gesture.translation.width + self.offsetPosition.width,
					height: gesture.translation.height + self.offsetPosition.height
				)
				self.offsetPosition = self.offset
			}
		let doubleTap = TapGesture(count: 2)
			.onEnded { (gesture) in
				DispatchQueue.main.async {
					self.game.swapPlayers(fromBench: nil, toLineUp: self.player)
					self.player = nil
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
					.fill(LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .bottom, endPoint: .topTrailing))
					.frame(width: 50, height: 50)
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
						PlayerInGameView(player: player!)
						.if(hasPlayer) {
							$0.contextMenu {
								ForEach(settings.statsNotInDirection, id: \.0) { (typePair) in
									Button(action: {
										self.statType = typePair.1
										self.showingAlert = true
									}) {
										Text(typePair.1.rawValue.capitalized)
									}
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
			StatInputView(stat: Stat(type: self.statType ?? .shot, player: self.player!), game: self.game)
		}
		.frame(width: size.width, height: size.height)
		.background(game.team.secondaryColor.cornerRadius(60))
		.offset(offset)
		.position(position)
		.onDrop(of: ["player"], isTargeted: nil) { (providers) -> Bool in
			providers.first?.loadObject(ofClass: DraggablePlayerReference.self, completionHandler: { (reading, error) in
				DispatchQueue.main.async {
					self.addPlayer(reading as? DraggablePlayerReference)
				}
			})
			
			return true
		}
		.if(!hasPlayer) { $0.gesture(moveGesture) }
		.if(hasPlayer) { $0.gesture(doubleTap) }
		.if(hasPlayer) { $0.gesture(statGesture) }
	}
	
	func addPlayer(_ playerReference: DraggablePlayerReference?) {
		if let player = game.playersOnBench.first(where: { $0.id == playerReference?.id }) {
			game.swapPlayers(fromBench: player, toLineUp: self.player)
			self.player = player
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
		if let path = Bundle.main.path(forResource: "click.m4a", ofType: nil) {
				clickSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
			
				clickSound?.play()
		}
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

struct CourtPositionView_Previews: PreviewProvider {
    static var previews: some View {
        let view = CourtPositionView(position: CGPoint(x: 0, y: 0))
			.environmentObject(Game.previewData)
			.previewLayout(.fixed(width: 120, height: 120))
		
		return view
    }
}
