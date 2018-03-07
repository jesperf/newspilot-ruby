# encoding: utf-8
module Newspilot
  class User
    include Newspilot::Resource

    attr_reader :np_type, :name, :shortname, :description

    def name
      "#{attributes['firstName']} #{attributes['lastName']}"
    end

    def shortname
      attributes['shortName']
    end

    def role
      @role ||= UserRole.find(attributes['userRoleId'])
    end

    def role_id
      attributes['userRoleId']
    end
  end
end
