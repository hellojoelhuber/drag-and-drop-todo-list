
import SwiftUI

struct TodoListItemView: View {
    let todoItem: TodoListItem
    
    var body: some View {
        HStack {
            Text(todoItem.title)
            
            Spacer()
            
            Text("\(todoItem.id)")
        }
        .padding()
        .background(Color.white)
    }
}

struct TodoListItemView_Previews: PreviewProvider {
    struct Preview: View {
        let todoItem = TodoListItem(id: 0, title: "Something")
        
        var body: some View {
            TodoListItemView(todoItem: todoItem)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
