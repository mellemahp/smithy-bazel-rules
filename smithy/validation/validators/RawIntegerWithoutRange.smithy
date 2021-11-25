$version: "1.0"

// ==============================
// Check for integers without a ranges in Inputs 
// 
// ===============================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "RawIntegerWithoutRange",
         message: """
            Integer is in an input shape but does not have an minimum or 
            maximum range specified. Add the `@range` trait.
        """,
        configuration: {
            selector: """
            operation -[input]-> structure > member
            :test(member > :is(integer))
            :test(member > :not(integer[trait|range]))
            """
        }
    }
]