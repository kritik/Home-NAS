class UserFilesController < ApplicationController
  before_action :set_folder
  before_action :set_user_file, only: [:show, :edit, :update, :destroy]


  # GET /user_files/1
  def show
  end

  # GET /user_files/new
  def new
    @user_file = @folder.files.new
  end

  # GET /user_files/1/edit
  def edit
  end

  # POST /user_files
  def create
    Folder.transaction do
      @folder.save!
      (Array(params[:user_file][:file]).each do |file|
        @folder.files.create!(file: file)
      end
      params[:user_file][:file_url].to_s.split("\n")).each do |link|
        @folder.files.create!(file_url: link)
      end
    end
    redirect_to folder_path, notice: 'User file was successfully created.'
  rescue ActiveRecord::RecordInvalid
    new
    render :new
  end

  # PATCH/PUT /user_files/1
  def update
    if @user_file.update(user_file_params)
      redirect_to @user_file, notice: 'User file was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_files/1
  def destroy
    @user_file.destroy
    redirect_to user_files_url, notice: 'User file was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_file
      @user_file = @folder.files.find(params[:id])
    end

    def set_folder
      @folder = Folder.find_or_initialize_by(path: params[:path].to_s)
      @folder.save! if @folder.root? # need always create it
    end

    # Only allow a trusted parameter "white list" through.
    def user_file_params
      params.require(:user_file).permit(:file, :file_url)
    end

    def folder_path
      params[:path].nil? ? root_upload_file_path : upload_file_path(params[:path])
    end
end
