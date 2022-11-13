$version: "2.0"

// ============================
// Built In InputOutputStructureReuse Validator 
//
// From Docs:
// ```
// Detects when a structure is used as both input and output 
// or if a structure is referenced as the input or output 
// for multiple operations.
// ```
// 
// Note: from the smithy-linters package
// 
// ============================
metadata validators = [
    { name: "InputOutputStructureReuse" },
]