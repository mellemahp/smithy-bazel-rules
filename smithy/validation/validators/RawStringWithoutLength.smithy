$version: "1.0"

// ==============================
// Check for strings without a length in Inputs 
// 
// Does not apply to strings with enum trait
// ===============================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "RawStringWithoutLength",
        message: """
            String is in an input shape but does not have an minimum or 
            maximum length specified. Add the `@length` trait to the raw 
            string type.
        """,
        configuration: {
            selector: """
            operation -[input]-> structure > member
            :test(member > :is(string))
            :test(member > :not(string[trait|enum]))
            :test(member > :not(string[trait|length]))
            """
        }
    }
]