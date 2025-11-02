public with sharing class TodoController {
    @AuraEnabled(cacheable=true)
    public static List<Todo__c> getTodos() {
        return [
            SELECT Id, Name, Description__c, Completed__c, CreatedDate, LastModifiedDate
            FROM Todo__c
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static Id createTodo(String name, String description) {
        if (String.isBlank(name)) {
            throw new AuraHandledException('Name is required');
        }
        Todo__c t = new Todo__c(
            Name = name,
            Description__c = description
        );
        insert t;
        return t.Id;
    }

    @AuraEnabled
    public static void completeTodo(Id todoId) {
        if (todoId == null) {
            throw new AuraHandledException('todoId is required');
        }
        Todo__c t = new Todo__c(Id = todoId, Completed__c = true);
        update t;
    }

    @AuraEnabled
    public static void toggleComplete(Id todoId, Boolean isCompleted) {
        if (todoId == null) {
            throw new AuraHandledException('todoId is required');
        }
        Todo__c t = new Todo__c(Id = todoId, Completed__c = isCompleted);
        update t;
    }

    @AuraEnabled
    public static void completeTodosBulk(List<Id> todoIds) {
        if (todoIds == null || todoIds.isEmpty()) return;
        List<Todo__c> updates = new List<Todo__c>();
        for (Id tid : todoIds) {
            updates.add(new Todo__c(Id = tid, Completed__c = true));
        }
        update updates;
    }
}
