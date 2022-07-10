
import SwiftUI
import DragAndDrop

struct TodoListItem: Identifiable, Dragable {
    let id: Int
    let title: String
    
}

extension TodoListItem: Equatable {
    static func == (lhs: TodoListItem, rhs: TodoListItem) -> Bool {
        lhs.id == rhs.id
    }
}
