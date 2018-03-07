# encoding: utf-8
module Newspilot
  class Organization
    include Newspilot::Resource

    def shortname
      attributes['shortName']
    end
  end
end
