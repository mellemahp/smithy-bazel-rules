$version: "1.0"

namespace example.pagelib

@range(min:0, max:10)
integer PageSize

@pattern("^[A-Za-z0-9 ]+$")
@length(min: 8, max: 10)
string Token

