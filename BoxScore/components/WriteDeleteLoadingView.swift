//
//  WriteDeleteLoadingView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/16/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

class LoadingView: ObservableObject {
	@Binding var visible: Bool
	var onComplete:	 ((RecordModel) -> ())?
	
	init(visible: Binding<Bool>, onComplete: ((RecordModel) -> ())? = nil) {
		self._visible = visible
		self.onComplete = onComplete
	}
	
	func wrapperView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
		VStack {
			Spacer()
			content()
			Spacer()
			
		}
		.padding()
		.frame(width: 250, height: 250, alignment: .center)
		.background(BlurView(style: .systemUltraThinMaterial))
		.cornerRadius(24.0)
	}
	
	func loadingView() -> some View {
		return Text("Loading...")
		.font(.title)
		.multilineTextAlignment(.center)
	}
	
	func errorView(_ error: DisplayableError) -> some View {
		hideLoader(false)
		
		return Text(error.readableMessage)
		.font(.title)
		.multilineTextAlignment(.center)
	}
	
	func hideLoader(_ andDismiss: Bool, withItem item: RecordModel? = nil) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.visible = false
			
			if andDismiss, let item = item {
				self.onComplete?(item)
			}
		}
	}
	
	func successView(text: String, item: RecordModel?) -> some View {
		hideLoader(true, withItem: item)
		
		return Text(text)
		.font(.title)
		.multilineTextAlignment(.center)
	}
}
