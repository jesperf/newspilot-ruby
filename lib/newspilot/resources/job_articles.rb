# encoding: utf-8
module Newspilot
  class JobArticles
    include Newspilot::Resource

    # OVERRIDE DEFAULT - Special case
    def self.construct_from_response(payload, headers)
      resource_body = payload
      resource_body.delete('link')
      Article.new resource_body, headers
    end

    def self.find(job_id: id)
      response = Newspilot.get(collection_with_id(job_id))
      JSON.parse(response.body)['article'].map { |attributes| construct_from_response attributes, response.headers }
    end

    def self.collection_with_id(id)
      "jobs/#{id}/articles"
    end
  end
end
