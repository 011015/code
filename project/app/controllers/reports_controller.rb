class ReportsController < ApplicationController
  before_action :set_report, only: %i[ show edit update destroy ]
  before_action :authenticate, only: [ :create ]
  before_action :authenticate_manager, only: [ :index, :update, :destroy ]

  # GET /reports or /reports.json
  def index
    if params[:状态] == nil
      @reports = Report.where({"状态": "待审核"}).all
    else
      @reports = Report.where({"状态": params[:状态]}).all
    end
    # @reports = Report.all
  end

  # GET /reports/1 or /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports or /reports.json
  def create
    @manipulator = @current_manipulatorid
    @song = Song.find(params[:song_id])
    @comment = Comment.find(params[:comment_id])
    if @manipulator == @comment.manipulator
        redirect_to @song, message: "不能举报自己的评论！"
      return
    end
    @report = Report.new(report_params)
    @report.comment = @comment
    @report.manipulator = @manipulator
    @report.状态 = "待审核"

    # 新建通知
    @notice = Notice.new()
    @notice.类型 = "举报"
    @notice.whistleblower = @manipulator
    @notice.manipulator = @comment.manipulator
    @notice.内容 = @report.comment.内容
    @notice.原因 = @report.内容
    @notice.wh状态 = "未读"
    @notice.ma状态 = "未读"

    respond_to do |format|
      if @notice.save and @report.save
        format.html { redirect_to @song, message: "Report was successfully created." }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { redirect_to @song, message: @report.errors }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    respond_to do |format|
      if @report.update({"状态": params[:状态]})
        format.html { redirect_to reports_url, message: "Report was successfully updated." }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1 or /reports/1.json
  def destroy
    # 新建通知
    @notice = Notice.new()
    @notice.whistleblower = @report.manipulator
    @notice.manipulator = @report.comment.manipulator
    @notice.内容 = @report.comment.内容
    @notice.wh状态 = "未读"
    @notice.ma状态 = "未读"
    
    if params[:状态] == "已通过"
      @notice.类型 = "删除"
      @report.comment.destroy
      respond_to do |format|
        if @notice.save
          format.html { redirect_to reports_url, message: "Report was successfully changed." }
          format.json { head :no_content }
        end
      end
    else
      @notice.类型 = "驳回"
      report = Report.new()
      report.内容 = @report.内容
      report.manipulator = @report.manipulator
      report.comment = @report.comment
      report.状态 = params[:状态]
      @report.destroy
      respond_to do |format|
        if @notice.save and report.save
          format.html { redirect_to reports_url, message: "Report was successfully changed." }
          format.json { render :show, status: :ok, location: @report }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @report.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:内容)
    end

    def authenticate
      redirect_to user_login_manipulators_url, notice: '请先登录！' unless current_manipulatorid
    #  authenticate_or_request_with_http_basic "Please login" do |user_name, password| 
    #    user_name == "wty" && password == "wty" 
    #  end 
    end

    def authenticate_manager
      redirect_to manager_login_manipulators_url, notice: '请先登录！' if !current_manipulatorid or current_manipulatortype != "管理员"
    #  authenticate_or_request_with_http_basic "Please login" do |user_name, password| 
    #    user_name == "wty" && password == "wty" 
    #  end 
    end

end
