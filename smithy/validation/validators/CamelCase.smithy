$version: "2.0"

// ============================
// Built In CamelCase Validator 
//
// From Docs:
// ```
// Validates that shape names and member names adhere to a consistent 
// style of camel casing. By default, this validator will ensure that 
// shape names use UpperCamelCase, trait shape names use lowerCamelCase, 
// and that member names use lowerCamelCase.
// ```
// 
// Note: from the smithy-linters package
// 
// ============================
metadata validators = [
    { name: "CamelCase" }
]