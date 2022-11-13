$version: "2.0"

namespace example.weather

use example.weather#PageSize
use example.weather#Token

resource City {
    identifiers: { cityId: CityId },
    read: GetCity,
    list: ListCities,
    resources: [Forecast],
}

resource Forecast {
    identifiers: { cityId: CityId },
    read: GetForecast,
}

// "pattern" is a trait.
@pattern("^[A-Za-z0-9 ]+$")
@length(min: 8, max: 10)
string CityId

@readonly
@http(
    method: "GET", 
    uri: "/city/{cityId}"
)
operation GetCity {
    input: GetCityInput,
    output: GetCityOutput,
    errors: [NoSuchResourceException]
} 

@input
structure GetCityInput {
    // "cityId" provides the identifier for the resource and
    // has to be marked as required.
    @required
    @httpLabel
    cityId: CityId
}

@output
structure GetCityOutput {
    // "required" is used on output to indicate if the service
    // will always provide a value for the member.
    @required
    name: String,

    @required
    coordinates: CityCoordinates,
}

// This structure is nested within GetCityResponse.
structure CityCoordinates {
    @required
    latitude: Float,

    @required
    longitude: Float,
}

// "error" is a trait that is used to specialize
// a structure as an error.
@error("client")
@httpError(404)
structure NoSuchResourceException {
    @required
    resourceType: String
}

// The paginated trait indicates that the operation may
// return truncated results.
@readonly
@paginated(items: "items")
@http(
    method: "GET", 
    uri: "/cities"
)
operation ListCities {
    input: ListCitiesInput,
    output: ListCitiesOutput
}

@input
structure ListCitiesInput {
    @httpQuery("nextToken")
    nextToken: Token,

    @httpQuery("pageSize")
    pageSize: PageSize
}

@output
structure ListCitiesOutput {
    nextToken: String,

    @required
    items: CitySummaries,
}

// CitySummaries is a list of CitySummary structures.
list CitySummaries {
    member: CitySummary
}

@mixin
structure NamedMixin {
    @required
    name: String
}

// CitySummary contains a reference to a City.
@references([{resource: City}])
structure CitySummary with [NamedMixin]{
    @required
    cityId: CityId,
}

@readonly
@http(
    method: "GET", 
    uri: "/time"
)
operation GetCurrentTime {
    output: GetCurrentTimeOutput
}

@output
structure GetCurrentTimeOutput {
    @required
    time: Timestamp
}

@readonly
@http(
    method: "GET", 
    uri: "/forecast/{cityId}"
)
operation GetForecast {
    input := {
        @required
        @httpLabel
        cityId: CityId,
    },
    output: GetForecastOutput
}

@output
structure GetForecastOutput {
    chanceOfRain: Float
}