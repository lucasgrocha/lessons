# frozen_string_literal: true

require 'ostruct'

class WrongProviderError < StandardError; end
class MissingProvidersError < StandardError; end
class MultipleProvidersError < StandardError; end

# Returns a Provider based on the order's U.S state abbreviation.
# See the main_spec.rb file for for examples.
#
# Raises one of the above errors if the set of input or output Providers
# is invalid.
#
# Expected object attributes:
#     order.us_state_abbr => 'WA'
#     provider.name => 'Road-Tec'
#
# @param order [OpenStruct] an order object
# @param providers [Array<OpenStruct>] an array of 0 or more Provider objects
# @return OpenStruct provider
def provider_by_state(order:, providers:)
  west_coast_abbr = %w[WA OR CA]

  providers = providers.map(&:name)

  coast_order = (west_coast_abbr - [order.us_state_abbr]).size != west_coast_abbr.size

  raise MissingProvidersError if providers.empty?
  raise MultipleProvidersError if all_providers?(providers)

  if road_tec?(providers) && abc?(providers)
    return OpenStruct.new(name: 'Road-Tec') if coast_order

    OpenStruct.new(name: 'ABC')
  end

  return OpenStruct.new(name: 'ABC') if only_abc?(providers)
  return OpenStruct.new(name: 'Road-Tec') if only_road_tec?(providers) && coast_order

  raise WrongProviderError
end

def all_providers?(providers)
  road_tec?(providers) && abc?(providers) && home_entry?(providers)
end

def road_tec?(providers)
  providers.include?('Road-Tec')
end

def abc?(providers)
  providers.include?('ABC')
end

def only_abc?(providers)
  !all_providers?(providers) && abc?(providers)
end

def only_road_tec?(providers)
  !all_providers?(providers) && road_tec?(providers)
end

def home_entry?(providers)
  providers.include?('Home Entry')
end
