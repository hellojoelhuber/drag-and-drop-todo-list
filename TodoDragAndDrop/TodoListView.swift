
import SwiftUI
import DragAndDrop

struct TodoListView: View {
    @EnvironmentObject var model: TodoListViewModel
    @State var todoBeingDragged: TodoListItem? = nil
    @Binding var addNewDragging: Bool
    @Binding var todoDragging: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .dropReceiver(for: model.dropReceiverAddNew, model: model)
            VStack {
                Text("To Do List").font(.headline)
                ForEach(model.todoItems) { item in
                    TodoListItemView(todoItem: item)
                        .dragable(object: item,
                                  onDragObject: onDragTodo,
                                  onDropObject: onDropTodo)
                        .zIndex(todoBeingDragged == item ? 1 : 0)
                }
                Spacer()
            }
            .padding()
        }
        .overlay(AddNewOverlay.opacity(addNewDragging ? 1 : 0))
    }
    
    func onDragTodo(item: Dragable, position: CGPoint) -> DragState {
        todoBeingDragged = (item as! TodoListItem)
        todoDragging = true
        if model.getDropableState(at: position) {
            return .accepted
        } else {
            return .unknown
        }
    }
    
    func onDropTodo(item: Dragable, position: CGPoint) -> Bool {
        model.acceptDropAction(for: item as! TodoListItem,
                               at: position)
//        todoDragging = false
        return false
    }
    
    var AddNewOverlay: some View {
        ZStack {
            Color.purple
                .opacity(0.15)
            HStack {
                Image(systemName: "plus.circle")
                Text("Add New!")
            }.font(.system(size: 40))
                .foregroundColor(.blue)
            
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var model = TodoListViewModel()
        @State var addNewDragging: Bool = false
        @State var todoDragging: Bool = false
        
        var body: some View {
            TodoListView(addNewDragging: $addNewDragging,
                         todoDragging: $todoDragging)
                .environmentObject(model)
        }
    }
    static var previews: some View {
        Preview()
    }
}
