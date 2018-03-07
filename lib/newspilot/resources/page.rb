# encoding: utf-8
module Newspilot
  class Page
    include Newspilot::Resource

    def thumbnail
      Newspilot.get("pages/#{id}/thumbnail").body
    end

    def preview
      Newspilot.get("pages/#{id}/preview").body
    end
  end
end
