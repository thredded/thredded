# frozen_string_literal: true

# Stores `request.fullpath` in the session under the `:stored_location_fullpath` key
# at the beginning of every request.
# To disable for a controller, set `self.store_location_fullpath = true` on the class level.
module StoreLocationFullpath
  extend ActiveSupport::Concern

  included do
    class_attribute :store_location_fullpath,
                    instance_accessor: false,
                    instance_predicate: false
    self.store_location_fullpath = true

    before_action :store_location_fullpath!
  end

  protected

  # Deletes the stored location_fullpath and returns the deleted value.
  # @return [String, nil] the value of the stored location_fullpath.
  def clear_stored_location_fullpath!
    session.delete(:stored_location_fullpath)
  end

  private

  def store_location_fullpath!
    return unless self.class.store_location_fullpath
    session[:stored_location_fullpath] = request.fullpath
  end

  def stored_location_fullpath
    session[:stored_location_fullpath]
  end
end
