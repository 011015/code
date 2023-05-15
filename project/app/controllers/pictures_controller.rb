class PicturesController < ApplicationController
  before_action :set_picture, only: %i[ show edit update destroy ]
  before_action :authenticate, except: [ :index, :show ]

  # GET /pictures or /pictures.json
  def index
    @pictures = Picture.all
  end

  # GET /pictures/1 or /pictures/1.json
  def show
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures or /pictures.json
  def create
    flag = true
    @song = Song.find(params[:song_id])
    params[:picture][:图片].each_with_index do |uploaded_io, index|
      if uploaded_io != ""
        suffix = File.extname(uploaded_io.original_filename)
        filename = Time.now.to_i.to_s + "_" + index.to_s + suffix
        if suffix == '.jpg' or suffix == '.jpeg' or suffix == '.png'
          @picture = Picture.new({"图片": filename})
          @picture.song = @song
          File.open(Rails.root.join('app/assets/images', filename), 'wb') do |file|
            file.write(uploaded_io.read)
          end
          if @picture.save
          else
            flag = false
            break
          end
        else
          flag = false
        end
      end
    end
    if params[:picture][:图片].length == 1
      respond_to do |format|
        format.html { redirect_to @song, alert: "图片必须上传" }
      end
      return
    end
    respond_to do |format|
      if flag
        format.html { redirect_to @song, alert: "Picture was successfully created." }
        format.json { render :show, status: :created, location: @picture }
      else
        format.html { redirect_to @song, alert: "图片必须为 .jpg 或 .jpeg 或 .png 格式." }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pictures/1 or /pictures/1.json
  def update
    @song.pictures.each do |file|
      filename = file.图片
      File.delete("#{Rails.root}/app/assets/images/#{filename}")
    end
    flag = false
    params[:picture][:图片].each_with_index do |uploaded_io, index|
      filename = Time.now.to_i.to_s + "_" + index.to_s + File.extname(uploaded_io.original_filename)
      File.open(Rails.root.join('app/assets/images', filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end
      if @picture.update({"图片": filename, song: @song})
        flag = true
      else
        flag = false
        break
      end
    end
    respond_to do |format|
      if flag
        format.html { redirect_to picture_url(@picture), alert: "Picture was successfully updated." }
        format.json { render :show, status: :ok, location: @picture }
      else
        format.html { redirect_to @song, alert: @picture.errors }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1 or /pictures/1.json
  def destroy
    @song = Song.find(params[:song_id])
    filename = @picture.图片
    File.delete("#{Rails.root}/app/assets/images/#{filename}")
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to @song, alert: "Picture was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def picture_params
      params.require(:picture).permit(:song_id, :图片)
    end

    def authenticate
      redirect_to user_login_manipulators_url, notice: '请先登录！' unless current_manipulatorid
    #  authenticate_or_request_with_http_basic "Please login" do |user_name, password| 
    #    user_name == "wty" && password == "wty" 
    #  end 
    end
    
end
