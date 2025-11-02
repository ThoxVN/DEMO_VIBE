import { LightningElement, track, wire } from 'lwc';
import getTodos from '@salesforce/apex/TodoController.getTodos';
import createTodo from '@salesforce/apex/TodoController.createTodo';
import toggleComplete from '@salesforce/apex/TodoController.toggleComplete';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TodoListCmp extends LightningElement {
    @track rows = [];
    newName = '';
    newDescription = '';

    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text', editable: false },
        { label: 'Description', fieldName: 'Description__c', type: 'text', wrapText: true },
        { label: 'Completed', fieldName: 'Completed__c', type: 'boolean' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Complete', name: 'complete' },
                    { label: 'Uncomplete', name: 'uncomplete' }
                ]
            }
        }
    ];

    @wire(getTodos)
    wiredTodos({ data, error }) {
        if (data) {
            this.rows = data;
        } else if (error) {
            this.toast('Error', this.normalizeError(error), 'error');
        }
    }

    refreshList = async () => {
        try {
            const result = await getTodos();
            this.rows = result;
        } catch (e) {
            this.toast('Error', this.normalizeError(e), 'error');
        }
    };

    handleRowAction = async (event) => {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        try {
            if (actionName === 'complete') {
                await toggleComplete({ todoId: row.Id, isCompleted: true });
                this.toast('Success', 'Marked as completed', 'success');
            } else if (actionName === 'uncomplete') {
                await toggleComplete({ todoId: row.Id, isCompleted: false });
                this.toast('Success', 'Marked as uncompleted', 'success');
            }
            await this.refreshList();
        } catch (e) {
            this.toast('Error', this.normalizeError(e), 'error');
        }
    };

    handleNameChange(e) {
        this.newName = e.target.value;
    }
    handleDescChange(e) {
        this.newDescription = e.target.value;
    }

    handleAdd = async () => {
        try {
            await createTodo({ name: this.newName, description: this.newDescription });
            this.newName = '';
            this.newDescription = '';
            this.toast('Success', 'Todo created', 'success');
            await this.refreshList();
        } catch (e) {
            this.toast('Error', this.normalizeError(e), 'error');
        }
    };

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    normalizeError(e) {
        if (!e) return 'Unknown error';
        if (Array.isArray(e.body)) {
            return e.body.map(err => err.message).join(', ');
        } else if (e.body && typeof e.body.message === 'string') {
            return e.body.message;
        }
        return e.message || JSON.stringify(e);
    }
}
