$version: "2.0"

// ============================
// Built In ShouldHaveUsedTimestamp Validator 
//
// From Docs:
// ```
// Looks for shapes that likely represent time, 
// but that do not use a timestamp shape.
// ```
// 
// Note: from the smithy-linters package
// 
// ============================
metadata validators = [
    { name: "ShouldHaveUsedTimestamp" }
]