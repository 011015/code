class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authenticate, except: [ :index, :show ]
  
  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
  def create
    @song = Song.find(params[:song_id])
    @comment = Comment.new(comment_params)
    @comment.manipulator = @current_manipulatorid
    @comment.song = @song
  
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @song, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { redirect_to @song, notice: @comment.errors }
        # format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to comment_url(@comment), notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @song = Song.find(params[:song_id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @song, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:内容)
    end

    def authenticate
      redirect_to user_login_manipulators_url, notice: '请先登录！' unless current_manipulatorid
    #  authenticate_or_request_with_http_basic "Please login" do |user_name, password| 
    #    user_name == "wty" && password == "wty" 
    #  end 
    end

end
