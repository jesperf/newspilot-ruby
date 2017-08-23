module Newspilot
  class JobResponsibility
    include Newspilot::Resource

    def user_id
      attributes['userId']
    end

    def user_role_id
      attributes['userRoleId']
    end

    def user_role
      attributes['userRole']
    end

    def user
      @user ||= User.find(user_id)
    end

    # OVERRIDE DEFAULT - Special case
    def self.construct_from_response(payload, headers)
      resource_body = payload
      resource_body.delete('link')
      new resource_body, headers
    end

    def self.find(job_id: id)
      response = Newspilot.get(collection_with_id(job_id))
      JSON.parse(response.body)['responsibility'].map { |attributes| construct_from_response attributes, response.headers }
    end

    def self.collection_with_id(id)
      "jobs/#{id}/responsibilities"
    end
  end
end
