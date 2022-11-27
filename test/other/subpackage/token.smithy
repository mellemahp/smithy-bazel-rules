$version: "1.0"

namespace example.weather

@pattern("^[A-Za-z0-9 ]+$")
@length(min: 8, max: 10)
string Token
