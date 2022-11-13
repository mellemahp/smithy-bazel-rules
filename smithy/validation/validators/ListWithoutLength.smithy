$version: "2.0"

// ==============================
// Check for lists without a length triat specified in Inputs 
// 
// ===============================
metadata validators = [
    {
        name: "EmitEachSelector",
        id: "ListWithoutLength",
        message: """
            List object is in an input shape but does not have a 
            length specified. Add a `@length` trait to the list
            structure
        """,
        configuration: {
            selector: """
            operation -[input]-> structure > member
            :test(member > :is(list))
            :test(member > :not(list[length]))
            """
        }
    }
]