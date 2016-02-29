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
      @users ||= attributes['responsibleUsers'].flatten.slice(1).map { |v| User.find(v['userId']) rescue nil }.compact
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
    
    def sections
      articles.collect { |a| a.section }
    end
  end
end
