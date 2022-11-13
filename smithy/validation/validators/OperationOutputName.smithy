$version: "2.0"

// ============================
// Check Input/Output Names
//
// Checks that Input/Output object names follow a consistent
// pattern. In this case we require the Inputs end with 'Request'
// and that outputs end with 'Response'
// 
// These validators are patterned off of a similar validator in the 
// Smithy example docs here: 
// https://awslabs.github.io/smithy/1.0/spec/core/model-validation.html?highlight=lifecycle
//
// ============================   
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "OperationOutputName",
        message: "This shape is referenced as output but the name does not end with 'Output'",
        configuration: {
            selector: "operation -[output]-> :not([id|name$=Output i])"
        }
    },
]