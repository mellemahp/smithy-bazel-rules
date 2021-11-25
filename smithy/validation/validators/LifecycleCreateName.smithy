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
// [create] -> Create*
// ==================================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "LifecycleCreateName",
        message: "Lifecycle 'create' operation shape names should start with 'Create'",
        configuration: {
            selector: "operation -[create]-> :not([id|name^=Create i])"
        }
    }
]