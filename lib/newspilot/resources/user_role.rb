module Newspilot
  class UserRole
    include Newspilot::Resource

    attr_reader :np_type, :name, :shortname, :description

    def name
      attributes['name']
    end

    def shortname
      attributes['shortName']
    end

    def description
      attributes['description']
    end
  end
end
