"""
Sample record:

{
    "clientIp": "143.177.52.190",
    "headers": {
        "x-forwarded-for": [
            {
                "key": "X-Forwarded-For",
                "value": "143.177.52.190"
            }
        ],
        "user-agent": [
            {
                "key": "User-Agent",
                "value": "Amazon CloudFront"
            }
        ],
        "via": [
            {
                "key": "Via",
                "value": "2.0 07bdbf68839b59462a12375dff97561e.cloudfront.net (CloudFront)"
            }
        ],
        "host": [
            {
                "key": "Host",
                "value": "example.com.ar"
            }
        ]
    },
    "method": "GET",
    "origin": {
        "custom": {
            "customHeaders": {
                "x-redirect-type": [
                    {
                        "key": "X-Redirect-Type",
                        "value": "alias"
                    }
                ]
            },
            "domainName": "example.com.ar",
            "keepaliveTimeout": 5,
            "path": "",
            "port": 443,
            "protocol": "https",
            "readTimeout": 30,
            "sslProtocols": [
                "TLSv1.2"
            ]
        }
    },
    "querystring": "",
    "uri": "/77dd7ce8-aad5-46e8-afd9-01e45a789305"
}
"""  # noqa: E501


status_descriptions = {
    301: "Moved Permanently",
    302: "Found",
    307: "Temporary Redirect",
}


def read_aliases() -> dict:
    with open("aliases") as f:
        return dict(alias.strip().split(":") for alias in f.readlines())  # type: ignore


aliases = read_aliases()


def handle(event, context):
    """Redirect users to the right domain

    Handles two types of redirections, depending on the "X-Redirect-Type" header.

    `redirect`: we do a redirection from a subdomain to the canonical website
    domain. That is, from "*.example.com" and "example.com" to "www.example.com".

    `alias`: then we're handling an alias domain redirection.  These are,
    specifically, redirections from `www.example.com.ar` to `www.example.com`.

    Always includes HSTS headers (super important for the bare domain!).
    """

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#example-origin-request
    request = event["Records"][0]["cf"]["request"]

    # Keep the entire URI and querystring.
    uri = request["uri"] if request["uri"] else "/"
    if request["querystring"]:
        uri += "?" + request["querystring"]

    # Base host is injected by the cloudfront distribution. This is the origin
    # server configured in the distribution, NOT what the user requested.
    base_host = request["origin"]["custom"]["domainName"]

    custom_headers = request["origin"]["custom"]["customHeaders"]
    redirect_type = custom_headers["x-redirect-type"][0]["value"]
    if redirect_type == "alias":
        target_host = aliases[base_host]
        status_code = 307
        max_age = 86400
    else:  # redirect
        target_host = base_host
        status_code = 301
        max_age = 31536000

    response = {
        "headers": {
            # Always enable HSTS:
            "strict-transport-security": [
                {
                    "key": "Strict-Transport-Security",
                    "value": "max-age=63072000; includeSubDomains; preload",
                },
            ],
            # Redirection:
            "location": [
                {
                    "key": "Location",
                    "value": f"https://www.{target_host}{uri}",
                }
            ],
            # Downstream caching:
            "cache-control": [
                {
                    "key": "Cache-Control",
                    "value": f"max-age={max_age}",
                }
            ],
        },
        "status": str(status_code),
        "statusDescription": status_descriptions[status_code],
    }

    return response
