//
//  Matrix.swift
//  WidgetPaint
//
//  Created by Craig Hockenberry on 8/26/23.
//

import Foundation
import SwiftUI

@Observable class MatrixNode: Identifiable, Equatable, CustomStringConvertible {
	let id: UUID
	var state: Int {
		didSet {
			print("set \(id) state to \(state)")
		}
	}
	
	var description: String {
		"\(id) = \(state)"
	}
	
	static func == (lhs: MatrixNode, rhs: MatrixNode) -> Bool {
		let result = lhs.id == rhs.id && lhs.state == rhs.state
		//debugLog("node \(lhs.description), \(rhs.description) equality = \(result)")
		return result
	}

	init(state: Int) {
		self.id = UUID()
		self.state = state
	}

	var color: Color {
		switch state {
		case 0: return .white
		case 1: return .black
		case 2: return .gray
		case 3: return .red
		case 4: return .green
		case 5: return .blue
		default: return .clear
		}
	}
}

@Observable class MatrixRow: Identifiable, Equatable {

	let id: UUID
	var matrixColumns: [MatrixNode]
	
	init(matrixColumns: [MatrixNode]) {
		self.id = UUID()
		self.matrixColumns = matrixColumns
	}
	
	static func == (lhs: MatrixRow, rhs: MatrixRow) -> Bool {
		lhs.id == rhs.id && lhs.matrixColumns == rhs.matrixColumns
	}
	
}

@Observable class Matrix: Equatable, CustomStringConvertible {
	
	static let defaultRows = 8
	static let defaultColumns = 8
	
	var id: UUID
	var title: String
	var rows: Int
	var columns: Int
	var matrixRows: [MatrixRow]
	
	init(title: String = "", rows: Int = defaultRows, columns: Int = defaultColumns) {
		self.id = UUID()
		self.rows = rows
		self.columns = columns
		self.title = title
		self.matrixRows = (0..<rows).map { _ in
			let matrixColumns = (0..<columns).map { _ in
				MatrixNode(state: 0)
			}
			return MatrixRow(matrixColumns: matrixColumns)
		}
		
		for matrixRow in self.matrixRows {
			for matrixColumn in matrixRow.matrixColumns {
				self.trackChange(node: matrixColumn)
			}
		}
	}

	var description: String {
		"id = \(id), title = '\(title)', rows = \(rows), columns = \(columns)"
	}
	
	// NOTE: This is very helpful for understanding how change tracking works:
	// https://talk.objc.io/episodes/S01E362-swift-observation-access-tracking
	func trackChange(node: MatrixNode) {
		withObservationTracking {
			let _ = node.state
		} onChange: {
			// NOTE: This callback occurs _before_ the value has changed. Also, if multiple properties are
			// being tracked, there can be overlapping calls:
			// https://mas.to/@nickmain/110999592457944760#.
			print("\(self.id) ---- matrix observation tracking changed \(node.state)")
			self.trackChange(node: node)
		}
	}
	
	static func == (lhs: Matrix, rhs: Matrix) -> Bool {
		lhs.id == rhs.id && lhs.rows == rhs.rows
	}

	func node(id: UUID) -> MatrixNode? {
		for matrixRow in self.matrixRows {
			for matrixColumn in matrixRow.matrixColumns {
				if matrixColumn.id == id {
					return matrixColumn
				}
			}
		}
		
		return nil
	}

}
