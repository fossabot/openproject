module IFCModels
  class IFCModel < ActiveRecord::Base
    acts_as_attachable delete_permission: :manage_ifc_models

    belongs_to :project
    belongs_to :uploader, class_name: 'User', foreign_key: 'uploader_id'

    %i(ifc xkt metadata).each do |name|
      define_method "#{name}_attachment" do
        get_attached_type(name)
      end

      define_method "#{name}_attachment=" do |file|
        if name == :ifc
          # Also delete xkt and metadata
          delete_attachment :xkt
          delete_attachment :metadata
        end

        delete_attachment :ifc
        attach_files('first' => { 'file' => file, 'description' => name })
      end
    end

    private

    ##
    # Delete the given named description
    def get_attached_type(key)
      attachments.find_by_description(key.to_s)
    end

    ##
    # Delete the given named description
    def delete_attachment(key)
      get_attached_type(key)&.destroy
    end
  end
end