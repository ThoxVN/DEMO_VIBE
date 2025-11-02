declare module "@salesforce/apex/TodoController.getTodos" {
  export default function getTodos(): Promise<any>;
}
declare module "@salesforce/apex/TodoController.createTodo" {
  export default function createTodo(param: {name: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/TodoController.completeTodo" {
  export default function completeTodo(param: {todoId: any}): Promise<any>;
}
declare module "@salesforce/apex/TodoController.toggleComplete" {
  export default function toggleComplete(param: {todoId: any, isCompleted: any}): Promise<any>;
}
declare module "@salesforce/apex/TodoController.completeTodosBulk" {
  export default function completeTodosBulk(param: {todoIds: any}): Promise<any>;
}
