module Newspilot
  class Image
    include Newspilot::Resource

    # attributes: name, mimetype, fileExt, description, city, country

    def archive_id
      attributes['archiveId']
    end

    def no_archiving
      attributes['noArchiving']
    end

    def author
      User.find(attributes['imageAuthor'])
    end

    def author_name
      attributes['authorName']
    end

    def binary
      Newspilot.get("images/#{id}/binary").body
    end

    def thumbnail
      Newspilot.get_jpeg("images/#{id}/thumbnail").body
    end

    def preview
      Newspilot.get_jpeg("images/#{id}/preview").body
    end

    # def metadata
      # TODO: Not implemented
      # Finns på "images/#{id}/metadata"
    # end

    def created_at
      Time.parse(createdDate)
    end

    def created_by
      # TODO: Access-problem?
      User.find(attributes['createdUserId'])
    end

  end
end
