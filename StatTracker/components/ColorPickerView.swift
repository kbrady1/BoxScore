//
//  ColorPickerView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/13/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

private let LINEAR_GRADIENT_HEIGHT: CGFloat = 300

struct ColorPickerView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	
	private let hues = Array(0...359).map { Color(UIColor(hue: CGFloat($0) / 359.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)) }
	private var currentColor: Color {
		Color(UIColor(hue: adjustDrag() / LINEAR_GRADIENT_HEIGHT, saturation: 1.0, brightness: adjustShade() / LINEAR_GRADIENT_HEIGHT, alpha: 1.0))
	}
	
	@State private var offset: CGSize = .zero
	@State private var startLocation: CGFloat = LINEAR_GRADIENT_HEIGHT / 2
	
	@State private var offsetRight: CGSize = .zero
	@State private var startLocationRight: CGFloat = LINEAR_GRADIENT_HEIGHT / 2
	
	@Binding var chosenColor: Color
	@State private var circleBackground = Color.clear
	
	
	var body: some View {
		NavigationView {
			VStack(spacing: 80) {
				RoundedRectangle(cornerRadius: 16)
					.foregroundColor(currentColor)
					.frame(width: 150, height: 150)
					.shadow(radius: 8)
					.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 4))
				HStack(spacing: 80) {
					ZStack(alignment: .top) {
						LinearGradient(gradient: Gradient(colors: hues), startPoint: .top, endPoint: .bottom)
							.frame(width: 20, height: LINEAR_GRADIENT_HEIGHT, alignment: .leading)
							.cornerRadius(5)
							.shadow(radius: 8)
							.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 4.0))
						CircleView(color: $circleBackground)
							.frame(width: 36, height: 36)
							.offset(x:0.0, y: self.adjustDrag() - 18)
							.gesture(DragGesture().onChanged { (gesture) in
								self.offset = CGSize(width: self.offset.width, height: gesture.translation.height)
								self.startLocation = gesture.startLocation.y
								self.chosenColor = self.currentColor
							})
						
					}
					ZStack(alignment: .top) {
						LinearGradient(gradient: Gradient(colors: [.black, .white]), startPoint: .top, endPoint: .bottom)
							.frame(width: 20, height: LINEAR_GRADIENT_HEIGHT, alignment: .leading)
							.cornerRadius(5)
							.shadow(radius: 8)
							.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 4.0))
						CircleView(color: $circleBackground)
							.frame(width: 36, height: 36)
							.offset(x:0.0, y: self.adjustShade() - 18)
							.gesture(DragGesture().onChanged { (gesture) in
								self.offsetRight = CGSize(width: self.offsetRight.width, height: gesture.translation.height)
								self.startLocationRight = gesture.startLocation.y
								self.chosenColor = self.currentColor
							})
						
					}
				}
			}
			.navigationBarTitle("", displayMode: .inline)
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}, label: {
				Text("Done")
					.bold()
			}))
			
		}
	}
	
	private func adjustDrag() -> CGFloat {
		return min(max(0, startLocation + offset.height), LINEAR_GRADIENT_HEIGHT)
	}
	
	private func adjustShade() -> CGFloat {
		return min(max(0, startLocationRight + offsetRight.height), LINEAR_GRADIENT_HEIGHT)
	}
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
		ColorPickerView(chosenColor: Binding.constant(Color.blue))
    }
}
