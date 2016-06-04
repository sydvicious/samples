module ApplicationHelper

  # Hat tip James Brooks - https://coderwall.com/p/jzofog
  def flash_class(level)
    case level
      when 'notice' then 'alert alert-info'
      when 'success' then 'alert alert-success'
      when 'error' then 'alert alert-warning'
      when 'alert' then 'alert alert-error'
    end
  end

end
