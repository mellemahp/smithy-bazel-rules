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
// [delete] -> Delete*
// ==================================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "LifecycleDeleteName",
        message: "Lifecycle 'delete' operation shape names should start with 'Delete'",
        configuration: {
            selector: "operation -[delete]-> :not([id|name^=Delete i])"
        }
    }
]