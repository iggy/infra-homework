# these are just the same providers as the root module, but we pass them here
# so we can use the beta provider (in addition to the default)
provider "google" {}

provider "google-beta" {}
