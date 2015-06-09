class FoldersController < ApplicationController
  before_action :set_folder, only: [:show, :edit, :update, :destroy]

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders
  def create
    @folder = Folder.new(path: [params[:path], folder_params[:name]].select(&:present?).join("/"))

    if @folder.save
      redirect_to upload_file_path(path: @folder.path), notice: 'Folder was successfully created.'
    else
      @folder.path = folder_params[:path]
      render :new
    end
  end

  # PATCH/PUT /folders/1
  def update
    if @folder.update(folder_params)
      redirect_to upload_file_path(path: @folder.path), notice: 'Folder was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /folders/1
  def destroy
    @folder.destroy
    redirect_to root_path, notice: 'Folder was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = Folder.find_or_initialize_by(id: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def folder_params
      params.require(:folder).permit(:name, :path)
    end
end
