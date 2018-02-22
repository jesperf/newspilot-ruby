module Newspilot
  class JobUserData
    include Newspilot::Resource

   def self.find(job_id: id)
      response = Newspilot.get(collection_with_id(job_id))

      raw_data = JSON.parse(response.body)['data']
      data = parse_xml(raw_data).map {|a| { "#{a.name}": a.children[0].text } }.inject(:merge)
      # data = data. if data
      data.stringify_keys! if data

      construct_from_response data ? data : {}, response.headers
    end

    def self.collection_with_id(id)
      "jobs/#{id}/userData"
    end

    private

    def self.parse_xml(data)
      Nokogiri::XML(data).xpath("//userdata/*")
    end
  end
end
