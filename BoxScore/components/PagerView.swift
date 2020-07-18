//
//  PagerView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/18/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct PagerView<Content: View>: View {
	
    let pageCount: Int
    @Binding var currentIndex: Int
	var highlightColor: Color
    let content: Content

	init(pageCount: Int, currentIndex: Binding<Int>, highlightColor: Color, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
		self.highlightColor = highlightColor
    }
	
	@GestureState private var translation: CGFloat = 0

	//TODO: Add an indicator?
	var body: some View {
		GeometryReader { geometry in
			VStack {
				HStack(spacing: 0) {
					self.content.frame(width: geometry.size.width)
				}
				.frame(width: geometry.size.width, alignment: .leading)
				.offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
				.offset(x: self.translation)
				.animation(.interactiveSpring())
				.gesture(
					DragGesture().updating(self.$translation) { value, state, _ in
						state = value.translation.width
					}.onEnded { value in
						let offset = (value.translation.width * 1.8) / geometry.size.width
						let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
						self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
					}
				)
				
				HStack {
					ForEach((0..<self.pageCount).map { $0 }) { (num) in
						BlurView(style: .prominent)
							.if(num == self.currentIndex) {
								$0.background(self.highlightColor)
						}
						.if(num != self.currentIndex) {
							$0.background(Color(UIColor.secondarySystemBackground))
						}
						.clipShape(Circle())
						.frame(width: 8, height: 8)
					}
				}
			}
		}
	}
}
