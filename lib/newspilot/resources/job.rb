module Newspilot
  class Job
    include Newspilot::Resource

    # label: { 0: 'none', 1: red, 2: orange, 3: yellow, 4: green, 5: blue, 6: purple, 7: gray }

    def shortname
      shortName
    end

    def production_date
      Time.parse(prodDate) unless prodDate == 'future'
    end

    def photo_date
      Time.parse(photoDate) unless photoDate == 'future'
    end

    def created_at
      Time.parse(createdDate) unless createdDate == 'future'
    end

    def created_by
      @created_by ||= User.find(attributes['createdUserId'])
    end

    def place
      geodata['geoDataEntry'].first['name']
    rescue
      ''
    end
    alias_method :location, :place

    def location=(name)
      if geodata['geoDataEntry'].first['name']
        geodata['geoDataEntry'].first['name'] = name
      else
        geodata['geoDataEntry'] = [{ "name" => name, "latitude"=>0.0, "longitude"=>0.0 }]
      end
    end
    alias_method :place=, :location=

    def image_links
      # @image_links ||= Newspilot.get("#{resource_name}/#{id}/imageLinks")
      @image_links ||= JobImageLink.find(job_id: id)
    end

    def images
      @images ||= image_links.map(&:image)
    end

    ## RELATIONS

    # Newspilot-användaren måste ha mer access än vanliga använder för att kunna använda denna
    def users
      @users ||= JobResponsibility.find(job_id: id).map { |r| r.user rescue nil }.compact
    end

    def department
      @department ||= Department.find(attributes['respDepartment'])
    end

    def department_id
      attributes['respDepartment']
    end

    def organization
      @organization ||= Organization.find(attributes['organizationId'])
    end

    def articles
      @articles ||= JobArticles.find(job_id: id)
    end

    def user_data
      @user_data ||= JobUserData.find(job_id: id)
    end

    def sections
      articles.collect { |a| a.section }
    end
  end
end
