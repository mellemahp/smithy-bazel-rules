$version: "1.0"

// ============================
// Built In MissingPaginatedTrait Validator 
//
// From Docs:
// ```
// Checks for operations that look like they should 
// be paginated but do not have the paginated trait.
// ```
// 
// Note: from the smithy-linters package
// 
// ============================
metadata validators = [
    { name: "MissingPaginatedTrait" }
]