# encoding: utf-8
module Newspilot
  class JobImageLink
    include Newspilot::Resource

    def image_id
      attributes['imageId']
    end

    def image
      @image ||= Image.find(image_id)
    end

    # OVERRIDE DEFAULT - Special case
    def self.construct_from_response(payload, headers)
      resource_body = payload
      resource_body.delete('link')
      new resource_body, headers
    end

    def self.find(job_id: id)
      response = Newspilot.get(collection_with_id(job_id))
      JSON.parse(response.body)['imageLink'].map { |attributes| construct_from_response attributes, response.headers }
    end

    def self.collection_with_id(id)
      "jobs/#{id}/imageLinks"
    end
  end
end
