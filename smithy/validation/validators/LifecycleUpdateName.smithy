$version: "1.0"

// ==================================
// Check Lifecycle Operation naming 
//
// Checks that your API response and request 
// names match with the lifecycle (CRUD) operations
// you are performing for each route. 
//
// This particular validator is patterned off of the example 
// validator in the smithy docs here: 
// https://awslabs.github.io/smithy/1.0/spec/core/model-validation.html?highlight=lifecycle
// 
// Operations to Verb mapping: 
// --------------------------
// [update] -> Update*
// ==================================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "LifecycleUpdateName",
        message: "Lifecycle 'update' operation shape names should start with 'Update'",
        configuration: {
            selector: "operation -[update]-> :not([id|name^=Update i])"
        }
    }
]