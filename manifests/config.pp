# @summary
#   java_ks configuration
#
class java_ks::config (
  $params = {},
) {
  create_resources('java_ks', $params )
}
