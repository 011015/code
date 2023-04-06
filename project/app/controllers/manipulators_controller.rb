class ManipulatorsController < ApplicationController
  before_action :set_manipulator, only: %i[ show edit update destroy ]
  before_action :authenticate, only: [ :index, :destroy ]
  before_action :authenticateDup, only: [ :update ]

  def my_page
    @manipulator = current_manipulatorid
  end

  def user_login
  end

  def manager_login
  end

  def do_login
    if params[:名称] == "" or params[:密码] == ""
      if params[:类型] == "管理员"
        redirect_to manager_login_manipulators_url, notice: 'Please fill out!'
        return
      else
        redirect_to user_login_manipulators_url, notice: 'Please fill out!'
        return
      end
    end
    manipulator = Manipulator.where({"名称": params[:名称], "密码": params[:密码], "类型": params[:类型]}).first
    if manipulator
      session[:current_manipulatorid] = manipulator.id
      session[:current_manipulatortype] = manipulator.类型
      if params[:类型] == "管理员"
        redirect_to reports_url
      else
        redirect_to songs_url, notice: 'Login successfully.'
      end
    else
      if params[:类型] == "管理员"
        redirect_to manager_login_manipulators_url, notice: 'Wrong username or password!'
      else
        redirect_to user_login_manipulators_url, notice: 'Wrong username or password!'
      end
    end
  end

  def logout
    type = current_manipulatortype
    session.delete(:current_manipulatortype)
    session.delete(:current_manipulatorid)
    if type == "管理员"
      redirect_to manager_login_manipulators_url, notice: 'Logout successfully!'
    else
      redirect_to user_login_manipulators_url, notice: 'Logout successfully!'
    end
  end

  def user_register
  end

  def manager_register
  end

  def do_register
    if params[:名称] == "" or params[:密码] == ""
      if params[:类型] == "管理员"
        redirect_to manager_register_manipulators_url, notice: 'Please fill out!'
        return
      else
        redirect_to user_register_manipulators_url, notice: 'Please fill out!'
        return
      end
    end
    manipulator = Manipulator.where("名称": params[:名称]).first
    if manipulator
      if params[:类型] == "管理员"
        redirect_to manager_register_manipulators_url, notice: 'Duplicate username!'
        return
      else
        redirect_to user_register_manipulators_url, notice: 'Duplicate username!'
        return
      end
    else
      @manipulator = Manipulator.new({"名称": params[:名称], "密码": params[:密码], "类型": params[:类型]})
      @picture = Picture.new({"图片": "default.jpg"})
      @manipulator.头像 = @picture
      respond_to do |format|
        if @manipulator.save
          if params[:类型] == "管理员"
            format.html { redirect_to manager_login_manipulators_url, notice: "Register successfully." }
          else
            format.html { redirect_to user_login_manipulators_url, notice: "Register successfully." }
          end
          format.json { render :show, status: :created, location: @manipulator }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @manipulator.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /manipulators or /manipulators.json
  def index
    @manipulators = Manipulator.all
  end

  # GET /manipulators/1 or /manipulators/1.json
  def show
  end

  # GET /manipulators/1/edit
  def edit
  end

  # PATCH/PUT /manipulators/1 or /manipulators/1.json
  def update
    if params[:manipulator][:头像]
      uploaded_io = params[:manipulator][:头像]
      suffix = File.extname(uploaded_io.original_filename)
      filename = Time.now.to_i.to_s + "_0" + suffix
      if suffix == '.jpg' or suffix == '.jpeg' or suffix == '.png'
        if @manipulator.头像.图片 != 'default.jpg'
          File.delete("#{Rails.root}/app/assets/images/#{@manipulator.头像.图片}")
        end
        @picture = Picture.new({"图片": filename})
        @picture.manipulator = @manipulator
        @manipulator.头像 = @picture
        File.open(Rails.root.join('app/assets/images', filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
        if @picture.save
        else
          respond_to do |format|
            format.html { redirect_to my_page_manipulators_url(@manipulator), notice: "图片保存失败" }
          end
          return
        end
      else
        respond_to do |format|
          format.html { redirect_to my_page_manipulators_url(@manipulator), notice: "图片必须为 .jpg 或 .jpeg 或 .png 格式." }
        end
        return
      end
    end
    respond_to do |format|
      if @manipulator.update(manipulator_params)
        format.html { redirect_to my_page_manipulators_url(@manipulator), notice: "Manipulator was successfully updated." }
        format.json { render :show, status: :ok, location: @manipulator }
      else
        format.html { redirect_to my_page_manipulators_url(@manipulator), notice: @manipulator.errors }
        format.json { render json: @manipulator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manipulators/1 or /manipulators/1.json
  def destroy
    if @manipulator.头像.图片 != 'default.jpg'
      File.delete("#{Rails.root}/app/assets/images/#{@manipulator.头像.图片}")
    end
    @manipulator.songs.each do |song|
      song.pictures.each do |picture|
        filename = picture.图片
        File.delete("#{Rails.root}/app/assets/images/#{filename}")
      end
    end
    if @manipulator.id == @current_manipulatorid.id
      session.delete(:current_manipulatortype)
      session.delete(:current_manipulatorid)
      @manipulator.destroy
      respond_to do |format|
        format.html { redirect_to manager_login_manipulators_url, notice: "Manipulator was successfully destroyed." }
        format.json { head :no_content }
      end
      return
    end
    @manipulator.destroy
    respond_to do |format|
      format.html { redirect_to manipulators_url, notice: "Manipulator was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manipulator
      @manipulator = Manipulator.find(params[:id])
    end

    def manipulator_params
      params.require(:manipulator).permit(:名称, :密码)
    end

    def authenticate
      redirect_to manager_login_manipulators_url, notice: '请先登录！' if !current_manipulatorid or current_manipulatortype != "管理员"
    end

    def authenticateDup
      redirect_to my_page_manipulators_url(@manipulator), notice: 'Duplicate username!' if current_manipulatorid.id != @manipulator.id and Manipulator.where("名称": params[:manipulator][:名称]).first
    end

end
