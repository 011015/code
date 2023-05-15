class ApplicationController < ActionController::Base
    add_flash_types :message
    helper_method :current_manipulatorid
    helper_method :current_manipulatortype
    helper_method :unread_count

    def current_manipulatorid
      @current_manipulatorid ||= Manipulator.find(session[:current_manipulatorid]) if session[:current_manipulatorid]
    end

    def current_manipulatortype
      @current_manipulatortype ||= session[:current_manipulatortype] if session[:current_manipulatortype]
    end

    def unread_count
      count = 0
      @current_manipulatorid.notices.each do |notice|
        if count > 99
          break
        end
        if notice.wh状态 == "未读"
          count = count + 1
        end
      end
      @current_manipulatorid.messages.each do |message|
        if count > 99
          break
        end
        if message.ma状态 == "未读"
          count = count + 1
        end
      end
      if count > 99
        count = "99+"
      end
      @unread_count = count
    end
end
