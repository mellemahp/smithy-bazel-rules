$version: "1.0"

// ==============================
// Check for strings without a regex pattern in Inputs 
// 
// ===============================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "RawStringWithoutPattern",
        message: """
            Integer is in an input shape but does not have a regex 
            pattern specified. Please add an @pattern trait to the raw
            string type. 
        """,
        configuration: {
            selector: """
            operation -[input]-> structure > member
            :test(member > :is(string))
            :test(member > :not(string[trait|enum]))
            :test(member > :not(string[trait|pattern]))
            """
        }
    }
]