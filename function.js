// Note: querystrings are dropped.
function handler(event) {
  var targetDomain = "${new_domain}";  // Filled in by terraform when templating.
  var newUrl = "https://" + targetDomain + event.request.uri;

  return {
    statusCode: 302,
    statusDescription: "Found",
    headers: { location: { value: newUrl } },
  };
}
