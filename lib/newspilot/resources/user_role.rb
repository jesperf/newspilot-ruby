module Newspilot
  class UserRole
    include Newspilot::Resource

    attr_reader :np_type, :name, :shortname, :description

    def shortname
      attributes['shortName']
    end
  end
end
