org="https://dev.azure.com/name of organization"
projects="Project name Here"

for p in $projects; do
    url="$org/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    body=$(cat <<EOF
{
    "data": {},
    "name": "SonarQube Connection",
    "type": "SonarQube",
    "url": "https://sonarqube.dns.com.br",
    "authorization": {
        "parameters": {
            "username": "squ_8b0e82ce78bb408375ecd36f21570406956f2c08",
            "password": null
        },
        "scheme": "UsernamePassword"
    },
    "isShared": false,
    "isReady": true,
    "serviceEndpointProjectReferences": [
        {
            "projectReference": {
                "id": "0",
                "name": ""
            },
            "name": "SonarQube Connection"
        }
    ]
}
EOF
)
    pat="PAT HERE"
    auth_header="Authorization: Basic $(echo -n ":$pat" | base64)"

    curl -X POST -H "$auth_header" -H "Content-Type: application/json" -d "$body" "$url"
done