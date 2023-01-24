# @summary
#   java_ks configuration
#
# @param params
#   A hash containing the parameters required for the java config.
#
class java_ks::config (
  Hash $params = {},
) {
  create_resources('java_ks', $params )
}
