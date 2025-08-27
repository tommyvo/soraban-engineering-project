# frozen_string_literal: true

# Support for ActiveJob test helpers in model specs
require 'active_job/test_helper'

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :model
end
