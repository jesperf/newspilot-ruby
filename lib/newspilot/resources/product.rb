# encoding: utf-8
module Newspilot
  class Product
    include Newspilot::Resource

    def shortname
      attributes['shortName']
    end
  end
end
