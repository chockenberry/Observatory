//
//  ContentView.swift
//  Observatory
//
//  Created by Craig Hockenberry on 9/4/23.
//

import SwiftUI

struct NodeView: View {
	@Bindable var node: MatrixNode
	
	var dimension: CGFloat = 32
	
	var body: some View {
		Button {
			print("button changing node id = \(node.id)")
			var newState = node.state + 1
			if newState > 5 {
				newState = 0
			}
			node.state = newState
		} label: {
			Circle()
				.fill(node.color.gradient)
				.frame(width: dimension, height: dimension)
		}
	}
}

struct ContentView: View {
	@State private var matrix = Matrix(rows: 4, columns: 4)
	
	let spacing: CGFloat = 2
	let dimension: CGFloat = 64
	
    var body: some View {
        VStack {
			Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
				ForEach(matrix.matrixRows) { matrixRow in
					GridRow {
						ForEach(matrixRow.matrixColumns) { matrixColumn in
							NodeView(node: matrixColumn, dimension: dimension)
								.onChange(of: matrixColumn.state) { oldValue, newValue in
									print("NodeView node changed: \(oldValue) -> \(newValue)")
								}
						}
					}
					.onChange(of: matrixRow.matrixColumns) { oldValue, newValue in
						print("GridRow matrixColumns changed: \(oldValue) -> \(newValue)")
					}
				}
			}
			.onChange(of: matrix.matrixRows) { oldValue, newValue in
				print("Grid matrixRows changed: \(oldValue) -> \(newValue)")
			}
			.onChange(of: matrix) { oldValue, newValue in
				print("Grid matrix changed: \(oldValue) -> \(newValue)")
			}

			
			Text("Click on a circle to change a MatrixNode's state and see how that change is propagated.")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
