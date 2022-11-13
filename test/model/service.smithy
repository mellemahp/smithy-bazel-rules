$version: "2.0"

namespace example.weather

use aws.protocols#restJson1

@restJson1
@paginated(inputToken: "nextToken", outputToken: "nextToken",
           pageSize: "pageSize")
service Weather {
    version: "2006-03-01",
    resources: [City],
    operations: [GetCurrentTime]
}
