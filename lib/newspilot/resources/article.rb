module Newspilot
  class Article
    include Newspilot::Resource
    
    def section
      @section ||= Section.find(section_id) unless section_id == 0
    end
  end
end
