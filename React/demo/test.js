var Header = React.createClass({

    /**
     * @return {object}
     */
    render: function () {
        return (
            <header id="header">
                <h1>todos</h1>
                <TodoTextInput
                    id="new-todo"
                    placeholder="What needs to be done?"
                    onSave={this._onSave}
                    />
            </header>
        );
    },

    _onSave: function (text) {
        if (text.trim()) {
            TodoActions.create(text);
        }
    }
});


var TodoActions = {

    /**
     * @param  {string} text
     */
    create: function (text) {
        AppDispatcher.dispatch({
            actionType: TodoConstants.TODO_CREATE,
            text: text
        });
    }
};

AppDispatcher.register(function (action) {
    var text;

    switch (action.actionType) {
        case TodoConstants.TODO_CREATE:
            text = action.text.trim();
            if (text !== '') {
                create(text);
            }
            TodoStore.emitChange();
            break;
// ...
    }
    )
    ;

    function create(text) {
        // Hand waving here -- not showing how this interacts with XHR or persistent
        // server-side storage.
        // Using the current timestamp + random number in place of a real id.
        var id = (+new Date() + Math.floor(Math.random() * 999999)).toString(36);
        _todos[id] = {
            id: id,
            complete: false,
            text: text
        };
    }

    AppDispatcher.register(function (action) {
        var text;

        switch (action.actionType) {
            case TodoConstants.TODO_CREATE:
                text = action.text.trim();
                if (text !== '') {
                    create(text);
                }
                TodoStore.emitChange();
                break;
// ...
        }
        )
        ;