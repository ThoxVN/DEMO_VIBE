@IsTest
private class TodoControllerTest {
    // Utility to create sample Todos
    private static List<Todo__c> makeTodos(Integer count, Boolean completed) {
        List<Todo__c> todos = new List<Todo__c>();
        for (Integer i = 0; i < count; i++) {
            todos.add(new Todo__c(
                Name = 'Todo ' + i,
                Description__c = 'Desc ' + i,
                Completed__c = completed
            ));
        }
        insert todos;
        return todos;
    }

    @IsTest
    static void testCreateTodo_success() {
        Test.startTest();
        Id newId = TodoController.createTodo('My Todo', 'My Desc');
        Test.stopTest();

        System.assertNotEquals(null, newId, 'New Todo Id should not be null');
        Todo__c t = [SELECT Id, Name, Description__c, Completed__c FROM Todo__c WHERE Id = :newId LIMIT 1];
        System.assertEquals('My Todo', t.Name, 'Name should match');
        System.assertEquals('My Desc', t.Description__c, 'Description should match');
        System.assertEquals(false, t.Completed__c, 'Completed should default to false');
    }

    @IsTest
    static void testCreateTodo_validation() {
        Test.startTest();
        try {
            TodoController.createTodo(null, 'x');
            System.assert(false, 'Expected exception for blank name');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Name is required'), 'Should throw name required');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetTodos_ordersAndLimits() {
        // Create multiple Todos, both completed and not
        List<Todo__c> t1 = makeTodos(3, false);
        List<Todo__c> t2 = makeTodos(2, true);

        Test.startTest();
        List<Todo__c> results = TodoController.getTodos();
        Test.stopTest();

        System.assert(results.size() >= 5, 'Should return inserted records');
        // Verify fields are accessible
        Todo__c any1 = results[0];
        System.assertNotEquals(null, any1.Id);
        // CreatedDate is selected so should be accessible without extra query
        System.assertNotEquals(null, any1.CreatedDate);
    }

    @IsTest
    static void testToggleComplete_true() {
        Todo__c t = new Todo__c(Name = 'To Toggle', Description__c = 'x', Completed__c = false);
        insert t;

        Test.startTest();
        TodoController.toggleComplete(t.Id, true);
        Test.stopTest();

        Todo__c refreshed = [SELECT Completed__c FROM Todo__c WHERE Id = :t.Id];
        System.assertEquals(true, refreshed.Completed__c, 'Should be completed after toggle true');
    }

    @IsTest
    static void testToggleComplete_false() {
        Todo__c t = new Todo__c(Name = 'To Toggle 2', Description__c = 'x', Completed__c = true);
        insert t;

        Test.startTest();
        TodoController.toggleComplete(t.Id, false);
        Test.stopTest();

        Todo__c refreshed = [SELECT Completed__c FROM Todo__c WHERE Id = :t.Id];
        System.assertEquals(false, refreshed.Completed__c, 'Should be not completed after toggle false');
    }

    @IsTest
    static void testCompleteTodo_single() {
        Todo__c t = new Todo__c(Name = 'Single Complete', Description__c = 'x', Completed__c = false);
        insert t;

        Test.startTest();
        TodoController.completeTodo(t.Id);
        Test.stopTest();

        Todo__c refreshed = [SELECT Completed__c FROM Todo__c WHERE Id = :t.Id];
        System.assertEquals(true, refreshed.Completed__c, 'Should be completed by completeTodo');
    }

    @IsTest
    static void testCompleteTodosBulk() {
        List<Todo__c> todos = makeTodos(4, false);

        Test.startTest();
        TodoController.completeTodosBulk(new List<Id>{ todos[0].Id, todos[1].Id, todos[2].Id });
        Test.stopTest();

        Map<Id, Todo__c> refreshed = new Map<Id, Todo__c>([
            SELECT Id, Completed__c FROM Todo__c WHERE Id IN :new List<Id>{ todos[0].Id, todos[1].Id, todos[2].Id }
        ]);
        System.assertEquals(true, refreshed.get(todos[0].Id).Completed__c);
        System.assertEquals(true, refreshed.get(todos[1].Id).Completed__c);
        System.assertEquals(true, refreshed.get(todos[2].Id).Completed__c);
        // untouched record remains false
        Todo__c lastOne = [SELECT Completed__c FROM Todo__c WHERE Id = :todos[3].Id];
        System.assertEquals(false, lastOne.Completed__c, 'Unspecified record should remain unchanged');
    }

    @IsTest
    static void testNegative_nullIds() {
        // toggleComplete with null
        try {
            Test.startTest();
            TodoController.toggleComplete(null, true);
            Test.stopTest();
            System.assert(false, 'Expected exception when todoId is null for toggleComplete');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('todoId is required'));
        }

        // completeTodo with null
        try {
            Test.startTest();
            TodoController.completeTodo(null);
            Test.stopTest();
            System.assert(false, 'Expected exception when todoId is null for completeTodo');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('todoId is required'));
        }

        // bulk with null or empty should not throw
        Test.startTest();
        TodoController.completeTodosBulk(null);
        TodoController.completeTodosBulk(new List<Id>());
        Test.stopTest();
    }
}