class NoticesController < ApplicationController
  before_action :set_notice, only: %i[ show edit update destroy ]

  # DELETE /reports/1 or /reports/1.json
  def destroy
    notice = Notice.new()
    notice.类型 = @notice.类型
    notice.whistleblower = @notice.whistleblower
    notice.manipulator = @notice.manipulator
    notice.内容 = @notice.内容
    notice.原因 = @notice.原因
    if params[:wh状态]
      notice.wh状态 = params[:wh状态]
      notice.ma状态 = @notice.ma状态
    else
      notice.wh状态 = @notice.wh状态
      notice.ma状态 = params[:ma状态]
    end
    @manipulator = Manipulator.find(params[:manipulator_id])
    @notice.destroy
    respond_to do |format|
        if notice.save
          format.html { redirect_to my_page_manipulators_url(@manipulator), message: "Notice was successfully changed." }
          format.json { render :show, status: :ok, location: @notice }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @notice.errors, status: :unprocessable_entity }
        end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notice
    @notice = Notice.find(params[:id])
  end

end
  