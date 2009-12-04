module Editable
  def editable_by?(user)
    user != nil && user.is_a?(User) && (self.user_id == user.id || user.admin?)
  end
end