$version: "2.0"

// ============================
// Check Input/Output Names
//
// Checks that Input object names follow a consistent
// pattern. In this case we require the Inputs end with 'Request'
// 
// This validator is patterned off of a similar validator in the 
// Smithy example docs here: 
// https://awslabs.github.io/smithy/1.0/spec/core/model-validation.html?highlight=lifecycle
//
// ============================   
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "OperationInputName",
        message: "This shape is referenced as input but the name does not end with 'Request'",
        configuration: {
            selector: "operation -[input]-> :not([id|name$=Input i])"
        }
    }
]