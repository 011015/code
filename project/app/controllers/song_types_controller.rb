class SongTypesController < ApplicationController
  before_action :set_song_type, only: %i[ show edit update destroy ]
  before_action :authenticate, except: [ :index, :show ]

  # GET /song_types or /song_types.json
  def index
    @song_types = SongType.all
  end

  # GET /song_types/1 or /song_types/1.json
  def show
  end

  # GET /song_types/new
  def new
    @song_type = SongType.new
  end

  # GET /song_types/1/edit
  def edit
  end

  # POST /song_types or /song_types.json
  def create
    @song_type = SongType.new(song_type_params)

    respond_to do |format|
      if @song_type.save
        format.html { redirect_to song_types_url, notice: "Song type was successfully created." }
        format.json { render :show, status: :created, location: @song_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /song_types/1 or /song_types/1.json
  def update
    respond_to do |format|
      if @song_type.update(song_type_params)
        format.html { redirect_to song_types_url, notice: "Song type was successfully updated." }
        format.json { render :show, status: :ok, location: @song_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /song_types/1 or /song_types/1.json
  def destroy
    @song_type.destroy

    respond_to do |format|
      format.html { redirect_to song_types_url, notice: "Song type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song_type
      @song_type = SongType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def song_type_params
      params.require(:song_type).permit(:名称)
    end

    def authenticate
      redirect_to user_login_manipulators_url, notice: '请先登录！' unless current_manipulatorid
    end

end
