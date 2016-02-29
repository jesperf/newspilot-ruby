module Newspilot
  class Article
    include Newspilot::Resource
    
    def section
      @section ||= Section.find(section_id)
    end
  end
end
