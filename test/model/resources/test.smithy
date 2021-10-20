$version: "1.0"

namespace example.weather

use example.pagelib#PageSize
use example.pagelib#Token

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
    input: GetCityRequest,
    output: GetCityResponse,
    errors: [NoSuchResource]
}

structure GetCityRequest {
    // "cityId" provides the identifier for the resource and
    // has to be marked as required.
    @required
    @httpLabel
    cityId: CityId
}

structure GetCityResponse {
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
structure NoSuchResource {
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
    input: ListCitiesRequest,
    output: ListCitiesResponse
}

structure ListCitiesRequest {
    @httpQuery("nextToken")
    nextToken: Token,

    @httpQuery("pageSize")
    pageSize: PageSize
}

structure ListCitiesResponse {
    nextToken: String,

    @required
    items: CitySummaries,
}

// CitySummaries is a list of CitySummary structures.
list CitySummaries {
    member: CitySummary
}

// CitySummary contains a reference to a City.
@references([{resource: City}])
structure CitySummary {
    @required
    cityId: CityId,

    @required
    name: String,


}

@readonly
@http(
    method: "GET", 
    uri: "/time"
)
operation GetCurrentTime {
    output: GetCurrentTimeResponse
}

structure GetCurrentTimeResponse {
    @required
    time: Timestamp
}

@readonly
@http(
    method: "GET", 
    uri: "/forecast/{cityId}"
)
operation GetForecast {
    input: GetForecastRequest,
    output: GetForecastResponse
}

// "cityId" provides the only identifier for the resource since
// a Forecast doesn't have its own.
structure GetForecastRequest {
    @required
    @httpLabel
    cityId: CityId,
}

structure GetForecastResponse {
    chanceOfRain: Float
}