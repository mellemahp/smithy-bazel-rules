$version: "1.0"

// ============================
// Built In AbbreviationName Validator 
//
// From Docs:
// ```
// Validates that shape names and member names do not represent
// abbreviations with all uppercase letters. 
// For example, instead of using "XMLRequest" or "instanceID", 
// this validator recommends using "XmlRequest" and "instanceId".
// ```
// 
// Note: from the smithy-linters package
// 
// ============================
metadata validators = [
    { name: "AbbreviationName" }
]